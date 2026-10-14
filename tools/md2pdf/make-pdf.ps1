<#
.SYNOPSIS
    Wandelt eine Markdown-Datei in ein PDF um – mit wählbarem Layout.

.DESCRIPTION
    Ablauf:
      1. pandoc:      Markdown -> HTML (Lua-Filter, Stylesheets, Bilder eingebettet)
                      bei Layout-Ordnern zusätzlich Titelseite und Kopfzeile
      2. wkhtmltopdf: HTML -> PDF
    Das PDF wird neben der Markdown-Datei abgelegt (gleicher Name, Endung .pdf).

    ARTEN VON LAYOUTS
      layouts\<name>.css   Einfaches Layout: nur Stylesheet (z. B. kompakt)
      layouts\<name>\      Layout-Ordner, kann enthalten:
                             style.css          Stylesheet
                             layout.psd1        Einstellungen (Ränder, Nummerierung, …)
                             header.html        Kopfzeile (pandoc-Vorlage)
                             cover.html         Titelseite (pandoc-Vorlage)
                             cover-header.html  Kopfzeile nur auf der Titelseite (z. B. Logo)
                             cover-footer.html  Fusszeile nur auf der Titelseite (pandoc-Vorlage)
                             toc.xsl            Inhaltsverzeichnis
      Titelseite und Inhaltsverzeichnis werden NUR erstellt, wenn die md-Datei
      mit einem YAML-Kopfblock (--- … ---) beginnt.

    STYLESHEETS werden gestapelt:
      1. layouts\standard.css   -> immer (Grundlayout)
      2. Zusatz-Layout          -> überschreibt nur, was es selbst enthält

    WELCHES ZUSATZ-LAYOUT
      a) -Layout <Name>        -> Ordner layouts\<Name>\ oder Datei layouts\<Name>.css
      b) -Layout <Pfad>.css    -> beliebige CSS-Datei
      c) ohne -Layout / auto   -> pdf.css im Ordner der md-Datei oder darüber,
                                  bis zur Repo-Grenze (.git)

.PARAMETER Markdown
    Pfad zur Markdown-Datei, absolut oder relativ zum aktuellen Ordner.

.PARAMETER Layout
    Name eines Layouts (Ordner oder .css in layouts) oder Pfad zu einer CSS-Datei.
    "auto" oder leer: projektspezifische pdf.css suchen.

.EXAMPLE
    make-pdf.ps1 04_prozesse\rechnungsstellung.md
    make-pdf.ps1 04_prozesse\rechnungsstellung.md -Layout kompakt
    make-pdf.ps1 bericht.md -Layout gis-bericht
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Markdown,

    [string]$Layout = ""
)

# Bei einem Fehler sofort abbrechen statt weiterzumachen
$ErrorActionPreference = "Stop"

# =============================================================================
# 1. Pfade
# =============================================================================

$mdFile = (Resolve-Path $Markdown).Path              # bricht ab, wenn die Datei fehlt
$mdDir  = Split-Path $mdFile -Parent
$name   = [IO.Path]::GetFileNameWithoutExtension($mdFile)

$layoutDir = Join-Path $PSScriptRoot "layouts"
$lua       = Join-Path $PSScriptRoot "keep-with-next.lua"
$titleLua  = Join-Path $PSScriptRoot "title-from-heading.lua"
$pdf       = Join-Path $mdDir "$name.pdf"

# Zwischendateien im Temp-Ordner (werden am Schluss gelöscht)
$html       = Join-Path $env:TEMP "$name.html"
$coverHtml  = Join-Path $env:TEMP "$name-cover.html"
$headerHtml = Join-Path $env:TEMP "$name-header.html"
$coverFootHtml = Join-Path $env:TEMP "$name-cover-footer.html"
$hideCss    = Join-Path $env:TEMP "$name-hide-title.css"
$tempFiles  = @($html, $coverHtml, $headerHtml, $coverFootHtml, $hideCss)

# =============================================================================
# 2. Layout bestimmen
# =============================================================================

# Sucht vom Ordner der md-Datei aufwärts nach pdf.css, höchstens bis zum
# Repo-Hauptordner (.git), damit keine Datei aus einem fremden Projekt greift.
function Find-ProjectCss([string]$startDir) {
    $dir = Get-Item $startDir
    while ($dir) {
        $kandidat = Join-Path $dir.FullName "pdf.css"
        if (Test-Path $kandidat) { return $kandidat }
        if (Test-Path (Join-Path $dir.FullName ".git")) { return $null }
        $dir = $dir.Parent
    }
    return $null
}

$layoutFolder = $null      # gesetzt, wenn ein Layout-Ordner verwendet wird
$extraCss     = $null      # Zusatz-Stylesheet über standard.css

if ($Layout -and $Layout -ne "auto") {
    $ordner = Join-Path $layoutDir $Layout
    $datei  = Join-Path $layoutDir "$Layout.css"

    if ($Layout -like "*.css") {
        $extraCss = (Resolve-Path $Layout).Path                     # b) Pfad
    }
    elseif (Test-Path $ordner -PathType Container) {
        $layoutFolder = $ordner                                     # a) Ordner
        $style = Join-Path $ordner "style.css"
        if (Test-Path $style) { $extraCss = $style }
    }
    elseif (Test-Path $datei) {
        $extraCss = $datei                                          # a) Datei
    }
    else {
        $verfuegbar = (Get-ChildItem $layoutDir |
                       ForEach-Object { if ($_.PSIsContainer) { $_.Name } else { $_.BaseName } }) -join ", "
        throw "Layout '$Layout' nicht gefunden. Verfügbar: $verfuegbar"
    }
}
else {
    $extraCss = Find-ProjectCss $mdDir                              # c) Projekt
}

# --- Einstellungen: Standardwerte, bei Layout-Ordnern aus layout.psd1 überschrieben ---

$cfg = @{
    MarginTop        = '18mm'
    MarginRight      = '18mm'
    MarginBottom     = '18mm'
    MarginLeft       = '18mm'
    HeaderSpacing    = 5
    CoverHeaderSpacing = 0
    CoverFooterSpacing = 0
    NumberSections   = $false
    TitleFromHeading = $false
}
if ($layoutFolder) {
    $psd = Join-Path $layoutFolder "layout.psd1"
    if (Test-Path $psd) {
        $eigene = Import-PowerShellDataFile $psd
        foreach ($k in $eigene.Keys) { $cfg[$k] = $eigene[$k] }
    }
}

# Hilfsfunktion: Datei aus dem Layout-Ordner, falls vorhanden, sonst $null
function Get-LayoutFile([string]$datei) {
    if (-not $layoutFolder) { return $null }
    $p = Join-Path $layoutFolder $datei
    if (Test-Path $p) { return $p } else { return $null }
}

# --- Hat die md-Datei einen YAML-Kopfblock? (erste nicht-leere Zeile = ---) ---

$ersteZeile  = Get-Content $mdFile -Encoding UTF8 | Where-Object { $_.Trim() -ne "" } | Select-Object -First 1
$hatKopfblock = ($ersteZeile -and $ersteZeile.Trim() -eq "---")

# Titelseite und Inhaltsverzeichnis nur mit Kopfblock
$coverTpl    = if ($hatKopfblock) { Get-LayoutFile "cover.html" } else { $null }
$coverHeader = if ($coverTpl)     { Get-LayoutFile "cover-header.html" } else { $null }
$coverFooter = if ($coverTpl)     { Get-LayoutFile "cover-footer.html" } else { $null }
$tocXsl      = if ($coverTpl)     { Get-LayoutFile "toc.xsl" } else { $null }
$headerTpl   = Get-LayoutFile "header.html"

# =============================================================================
# 3. Gemeinsame pandoc-Optionen
# =============================================================================

$pandocBasis = @("-f", "gfm", "--resource-path=$mdDir")
if ($cfg.TitleFromHeading) { $pandocBasis += "--lua-filter=$titleLua" }        # # wird Titel, ## wird Kapitel 1
if ($cfg.NumberSections)   { $pandocBasis += "--number-sections" }            # 1, 1.1, …

# Titel für <title> des HTML: erste #-Überschrift, sonst Dateiname
$titelZeile = Get-Content $mdFile -Encoding UTF8 | Where-Object { $_ -match '^# ' } | Select-Object -First 1
$titel = if ($titelZeile) { $titelZeile.Substring(2).Trim() } else { $name }

# Stylesheets zusammenstellen
$cssFiles = @(Join-Path $layoutDir "standard.css")
if ($extraCss) { $cssFiles += $extraCss }
if ($coverTpl) {
    # Mit Titelseite den Titelblock im Text ausblenden (steht schon auf der Titelseite)
    Set-Content $hideCss "#title-block-header { display: none; }" -Encoding UTF8
    $cssFiles += $hideCss
}
$cssArgs = $cssFiles | ForEach-Object { "--css=$_" }

# --- Übersicht ausgeben ---

Write-Host "Datei:      $mdFile"
Write-Host "Layout:     $(($cssFiles | Where-Object { $_ -ne $hideCss } | ForEach-Object { Split-Path $_ -Leaf }) -join ' + ')"
if ($layoutFolder) {
    Write-Host "Titelseite: $(if ($coverTpl) { 'ja' } elseif ($hatKopfblock) { 'nein (keine Vorlage)' } else { 'nein (kein Kopfblock)' })"
    Write-Host "Kopfzeile:  $(if ($headerTpl) { 'ja' } else { 'nein' })"
}

# =============================================================================
# 4. pandoc: Inhalt, Titelseite, Kopfzeile
# =============================================================================

Write-Host "1/2  pandoc"

# Inhalt
& pandoc $mdFile @pandocBasis -t html5 -s `
    -V pagetitle="$titel" `
    --lua-filter="$lua" `
    @cssArgs --embed-resources `
    -o $html
if ($LASTEXITCODE -ne 0) { throw "pandoc (Inhalt) ist fehlgeschlagen" }

# Titelseite: Vorlage mit Werten aus dem Kopfblock füllen, Logo einbetten
if ($coverTpl) {
    & pandoc $mdFile @pandocBasis -t html5 `
        --template="$coverTpl" --resource-path="$layoutFolder" --embed-resources `
        -o $coverHtml
    if ($LASTEXITCODE -ne 0) { throw "pandoc (Titelseite) ist fehlgeschlagen" }
}

# Fusszeile der Titelseite: Vorlage mit Verfasser, Version, Datum füllen, Bild einbetten
if ($coverFooter) {
    & pandoc $mdFile @pandocBasis -t html5 `
        --template="$coverFooter" --resource-path="$layoutFolder" --embed-resources `
        -o $coverFootHtml
    if ($LASTEXITCODE -ne 0) { throw "pandoc (Fusszeile Titelseite) ist fehlgeschlagen" }
}

# Kopfzeile: Vorlage mit Titel und Dokumenttyp füllen
if ($headerTpl) {
    & pandoc $mdFile @pandocBasis -t html5 --template="$headerTpl" -o $headerHtml
    if ($LASTEXITCODE -ne 0) { throw "pandoc (Kopfzeile) ist fehlgeschlagen" }
}

# =============================================================================
# 5. wkhtmltopdf: PDF zusammensetzen
# =============================================================================

$wk = (Get-Command wkhtmltopdf -ErrorAction SilentlyContinue).Source
if (-not $wk) { $wk = "C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" }
if (-not (Test-Path $wk)) { throw "wkhtmltopdf nicht gefunden: $wk" }

# Optionen für Inhaltsseiten (und Inhaltsverzeichnis):
# mit Kopfzeile -> Seitenzahl steht dort; sonst Seitenzahl in der Fusszeile
if ($headerTpl) {
    $seitenOptionen = @("--header-html", $headerHtml, "--header-spacing", $cfg.HeaderSpacing)
} else {
    $seitenOptionen = @("--footer-center", "Seite [page] von [topage]", "--footer-font-size", "8")
}

# Globale Optionen
$wkArgs = @(
    "--quiet", "--enable-local-file-access", "-s", "A4",
    "-T", $cfg.MarginTop, "-R", $cfg.MarginRight, "-B", $cfg.MarginBottom, "-L", $cfg.MarginLeft
)

# Titelseite als normale Seite (nicht als "cover"-Objekt: dieses kennt keine
# Kopf- und Fusszeilen). Eigene Kopfzeile (Logo) und Fusszeile (Adressblock).
if ($coverTpl) {
    $wkArgs += @($coverHtml)
    if ($coverHeader) { $wkArgs += @("--header-html", $coverHeader, "--header-spacing", $cfg.CoverHeaderSpacing) }
    if ($coverFooter) { $wkArgs += @("--footer-html", $coverFootHtml, "--footer-spacing", $cfg.CoverFooterSpacing) }
}

# Inhaltsverzeichnis
if ($tocXsl) {
    $wkArgs += @("toc", "--xsl-style-sheet", $tocXsl) + $seitenOptionen
}

# Inhalt und Ausgabedatei
$wkArgs += @($html) + $seitenOptionen + @($pdf)

Write-Host "2/2  wkhtmltopdf"
& $wk @wkArgs
if ($LASTEXITCODE -ne 0) { throw "wkhtmltopdf ist fehlgeschlagen (Exit-Code $LASTEXITCODE)" }

# =============================================================================
# 6. Aufräumen
# =============================================================================

$tempFiles | ForEach-Object { Remove-Item $_ -ErrorAction SilentlyContinue }
Write-Host "Fertig:     $pdf" -ForegroundColor Green
