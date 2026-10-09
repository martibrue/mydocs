# GitHub-Repository und Zensical einrichten

Neues Doku-Repo mit Zensical aufsetzen

**Umgebung:** Windows 11, Python 3.12.6, Zensical 0.0.69

## Voraussetzungen

- python installiert

## Schritte

### 1. Voraussetzungen prüfen
Öffne in VS Code ein Terminal und prüfe:

```powershell
# Zeigt die installierte Python-Version (sollte 3.10 oder neuer sein)
python --version

# Zeigt die installierte Git-Version
git --version
```

### 2. Repo auf GitHub anlegen und klonen
Auf GitHub ein neues Repo in deinem persönlichen Konto anlegen (ohne .gitignore, README oder Lizenz)

```powershell
# In den Ordner wechseln, in dem deine Repos liegen (Pfad anpassen)
cd C:\_Daten

# Leeres Repo klonen (Git meldet "cloned an empty repository", das ist normal)
git clone https://github.com/<dein-github-name>/wissen.git

# In den neuen Ordner wechseln und ihn in VS Code öffnen
cd wissen
code .
```

### 3. Virtuelle Umgebung anlegen und aktivieren
```powershell
# Virtuelle Umgebung im Ordner .venv anlegen
python -m venv .venv

# Umgebung aktivieren; danach steht "(.venv)" vor der Eingabezeile
.venv\Scripts\Activate.ps1
```

### 4. Zensical installieren und Projekte erzeugen
```powershell
# Zensical in die aktive Umgebung installieren
pip install zensical

# Grundgerüst im aktuellen Ordner erzeugen
zensical new .
```

### 5. GitHub-Workflow entfernen
Den Ordner .github enthält den Workflow für die Erstellung der GitHub-Pages. Da in einem privaten Free-Repo nicht auf Pages veröffentlicht werden kann, sollte dieser Ordner entfernt werden, da es sonst bei jedem Push fehlschlägt

```powershell
# Ordner .github mit dem Workflow komplett löschen
Remove-Item -Recurse -Force .github
```

### 6. Konfiguration anpassen
Öffne zensical.toml. Folgende zwei Sachen anpassen: 
```toml
[project]
# Name der Doku, erscheint im Seitenkopf und im Browser-Tab
site_name = "Mein Wissen"

[project.theme]
# Oberfläche auf Deutsch (Suche, Navigation, Buttons)
language = "de"
```

### 7. Version festhalten und .gitignore anlegen
```powershell
# Installierte Version anzeigen (Zeile "Version: ...")
pip show zensical
```

Neue Datei requirements.txt im Hauptordner anlegen. Und folgendes mit der aktuellen Version einfügen: 

```text
# Feste Zensical-Version; Updates bewusst hier ändern und testen
zensical==0.0.68
```

Neue Datei .gitignore im Hauptordner: 
```powershell
# Virtuelle Umgebung: wird auf jedem Rechner selbst erzeugt
.venv/

# Gebaute Website, wird bei Bedarf aus docs/ neu erzeugt
site/
```

### 8. Erste Struktur und Vorschau

md-Files anlegen mit Themenordner.

Ohne eigene Navigationsangabe baut Zensical die Navigation aus deiner Ordnerstruktur. Ordner werden zu Abschnitten, Dateien zu Seiten. Das reicht lange.

```powershell
# Vorschau starten; baut bei jeder Änderung automatisch neu
zensical serve
```
Im Browser http://localhost:8000 öffnen. Beenden mit Strg+C.

### 9. Comitten und pushen
```powershell
# Alle neuen Dateien vormerken (.venv und site/ ignoriert Git dank .gitignore)
git add .

# Kontrollieren, was committet wird: .venv darf hier NICHT auftauchen
git status

# Commit erstellen und hochladen
git commit -m "Grundgerüst mit Zensical"
git push -u origin main
```
Das -u origin main brauchst du nur beim ersten Push. Es verknüpft deinen lokalen Branch mit GitHub; danach reicht git push.

### 10. Statische Website erstellen
Wenn die Bearbeitung der MD-Dateien abgeschlossen ist, kann mit folgendem Befehl eine statische Website erstellt werden. Diese wird unter /site/.. abgelegt.

```powershell
zensical build
``` 

## Prüfen



## Hinweise



## Quellen

- [Zensical: Get started](https://zensical.org/docs/get-started/)
- [Zensical: Create you site](https://zensical.org/docs/create-your-site/)
