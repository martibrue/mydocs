# md2pdf

Markdown-Dateien als PDF ausgeben, mit wählbarem Layout.
Werkzeuge: pandoc (Markdown → HTML) und wkhtmltopdf (HTML → PDF).

## PDF erstellen

**In VS Code (empfohlen)**

1. md-Datei öffnen
2. `Ctrl+Shift+P` → *Tasks: Run Task* → **PDF aus Markdown erstellen**
3. Layout wählen

Das PDF liegt danach neben der md-Datei.

**In PowerShell**

```powershell
make-pdf.ps1 datei.md                        # auto: pdf.css im Projekt, sonst standard
make-pdf.ps1 datei.md -Layout kompakt
make-pdf.ps1 datei.md -Layout gis-bericht
```

### Layouts

| Layout | Wofür |
|---|---|
| `standard` | normale Doku-Seiten |
| `kompakt` | kleinere Schrift und Bilder, z. B. Arbeitspapiere |
| `gis-bericht` | offizielles Berichtslayout GIS Daten AG |

### Nützlich in der md-Datei

Seitenumbruch (vor einer Überschrift einfügen, mit Leerzeilen davor und danach):

```markdown
<div class="pagebreak"></div>
```

**Titelseite und Inhaltsverzeichnis** (nur `gis-bericht`): Kopfblock ganz an den Anfang der md-Datei.

```yaml
---
title: Titel des Dokuments
dokumenttyp: Dokumentation
verfasser: Vorname Name (GIS Daten AG)
version: 1.0
erstellung: 14.10.2026
revision: 14.10.2026
---
```

Ohne Kopfblock: keine Titelseite, der Titel steht oben auf Seite 1.
Bei `gis-bericht` wird `#` zum Dokumenttitel, `##` zu Kapitel 1, 2, … und `###` zu 1.1, 1.2, …

## Neues Layout erstellen

Ein Layout enthält nur die **Abweichungen** vom Grundlayout `layouts\standard.css`.
Das Grundlayout wird immer zuerst geladen.

### A) Einfaches Layout (nur Aussehen)

1. `layouts\kompakt.css` kopieren, z. B. als `layouts\praesentation.css`
2. Regeln anpassen (Schrift, Farben, Bildgrösse …)
3. In VS Code: Name in den Benutzer-Aufgaben unter `"options"` ergänzen
   (`Ctrl+Shift+P` → *Tasks: Open User Tasks*)
4. Aufruf: `-Layout praesentation`

### B) Layout nur für ein Projekt

Eine Datei `pdf.css` in den Projektordner legen (z. B. `docs\pdf.css`).
Sie wird automatisch verwendet, wenn das Layout `auto` gewählt ist
(gesucht wird vom Ordner der md-Datei aufwärts bis zum Repo-Hauptordner).

### C) Layout mit Titelseite, Kopfzeile oder eigenen Rändern

Den Ordner `layouts\gis-bericht\` kopieren und anpassen. Alle Dateien sind optional:

| Datei | Inhalt |
|---|---|
| `style.css` | Aussehen |
| `layout.psd1` | Ränder, Position Logo / Fussblock, Kapitelnummern |
| `header.html` | Kopfzeile ab Seite 2 |
| `cover.html` | Titelseite: Dokumenttyp und Titel |
| `cover-header.html` | Titelseite: Logo |
| `cover-footer.html` | Titelseite: Verfasser-Block und Adressblock |
| `toc.xsl` | Inhaltsverzeichnis |

## Stolpersteine

- **Masse wirken kleiner als eingestellt:** wkhtmltopdf verkleinert um ca. Faktor 0.84.
  Ein Element soll 10 mm gross sein → 12 mm einstellen.
- **Abstand oben auf einer Seite wird ignoriert:** `padding-top` statt `margin-top` verwenden.
- **Ränder und Papierformat** stehen in `layout.psd1`, nicht im CSS.
- **In `*.html`-Vorlagen keine Dollarzeichen in Kommentaren** (pandoc liest sie als Platzhalter),
  **in `toc.xsl` keine zwei Bindestriche in Kommentaren** (ungültiges XML).
- **`make-pdf.ps1` als „UTF-8 with BOM“ speichern** (VS Code: Statusleiste unten rechts → *Save with Encoding*),
  sonst erscheinen Umlaute falsch.
- **„Skripte sind deaktiviert“** in PowerShell: einmal pro Sitzung
  `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned`.
- Titelseite, Inhaltsverzeichnis und Kopfzeilen funktionieren nur mit der **Windows-Version** von wkhtmltopdf.

## Einrichtung (einmalig)

1. pandoc und wkhtmltopdf installieren (`winget install JohnMacFarlane.Pandoc` / `wkhtmltopdf.wkhtmltox`)
2. Diesen Ordner und `C:\Program Files\wkhtmltopdf\bin` in den Benutzer-PATH aufnehmen
3. Inhalt von `vscode-user-tasks.json` in die VS-Code-Benutzer-Aufgaben kopieren