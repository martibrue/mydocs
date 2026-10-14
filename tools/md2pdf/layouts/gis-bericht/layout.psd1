# layout.psd1 – Einstellungen für das Layout "gis-bericht"
#
# Wird von make-pdf.ps1 gelesen (Import-PowerShellDataFile).
# Alles, was hier nicht steht, nimmt das Skript aus seinen Standardwerten.
@{
    # Seitenränder wie in der Word-Vorlage (Kopfzeile liegt im oberen Rand)
    MarginTop    = '27.5mm'
    MarginRight  = '25mm'
    MarginBottom = '20mm'
    MarginLeft   = '26.5mm'

    # Abstand zwischen Kopfzeile und Text (mm)
    HeaderSpacing = 8

    # Titelseite: Abstand zwischen Logo (Kopfzeile) und Textbereich (mm).
    # Negativ = das Logo ragt in den Textbereich hinein, steht also tiefer.
    # Logo-Oberkante = ca. MarginTop - CoverHeaderSpacing - Logohoehe (ca. 26 mm)
    #   -10  ->  27.5 + 10 - 26 = ca. 11.5 mm unter der Blattkante (wie Word-Vorlage)
    CoverHeaderSpacing = -10

    # Titelseite: Abstand zwischen Textbereich und Fusszeile (mm).
    # Die Fusszeile (Verfasser-Block + Adressblock, ca. 33 mm hoch) ist hoeher
    # als der untere Rand (20 mm) und muss darum in den Textbereich hineinragen.
    # Groesserer Minuswert = Block steht hoeher.
    CoverFooterSpacing = -25

    # Kapitel nummerieren (1, 1.1, …) und die #-Überschrift als Titel verwenden
    NumberSections   = $true
    TitleFromHeading = $true
}
