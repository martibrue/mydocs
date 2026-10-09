# Git-Spickzettel

Diese Zusammenstellung enthält die wichtigsten Git-Befehle für die tägliche
Arbeit mit einem Repository auf GitHub. Die Beispiele gehen davon aus, dass der
Hauptbranch `main` heisst.

## 1. Das Grundprinzip

Git unterscheidet vier Bereiche:

1. **Arbeitsordner:** Dateien, die lokal bearbeitet werden.
2. **Staging-Bereich:** Änderungen, die für den nächsten Commit ausgewählt sind.
3. **Lokales Repository:** Lokal gespeicherte Commits und deren Historie.
4. **Remote-Repository:** Das Repository auf GitHub oder einem anderen Server.

Der normale Ablauf lautet:

```bash
git pull
git status
git add .
git commit -m "Beschreibung der Änderung"
git push
```

## 2. Repository herunterladen oder neu erstellen

### Vorhandenes Repository herunterladen

```bash
git clone https://github.com/BENUTZER/REPOSITORY.git
```

Dabei werden das Repository, seine Commit-Historie und die Remote-Verknüpfung
`origin` eingerichtet.

### Neuen lokalen Ordner als Repository einrichten

```bash
git init
```

Danach kann ein Remote-Repository ergänzt werden:

```bash
git remote add origin https://github.com/BENUTZER/REPOSITORY.git
```

## 3. Aktuellen Zustand kontrollieren

### Status anzeigen

```bash
git status
```

Kompakte Anzeige:

```bash
git status --short
```

Typische Statuskürzel:

| Kürzel | Bedeutung |
|---|---|
| `M` | Datei wurde geändert |
| `A` | Datei wurde neu hinzugefügt |
| `D` | Datei wurde gelöscht |
| `??` | Neue, noch nicht von Git verwaltete Datei |

### Änderungen anzeigen

Noch nicht mit `git add` vorgemerkte Änderungen:

```bash
git diff
```

Für den nächsten Commit vorgemerkte Änderungen:

```bash
git diff --staged
```

Änderungen einer bestimmten Datei:

```bash
git diff dateiname.sql
```

## 4. Änderungen für einen Commit auswählen

Eine bestimmte Datei vormerken:

```bash
git add dateiname.sql
```

Mehrere Dateien vormerken:

```bash
git add datei1.sql datei2.sql
```

Alle Änderungen im aktuellen Ordner und seinen Unterordnern vormerken:

```bash
git add .
```

Eine Datei wieder aus dem Staging-Bereich entfernen, ohne ihre Änderungen zu
verwerfen:

```bash
git restore --staged dateiname.sql
```

Vor dem Commit empfiehlt sich eine Kontrolle:

```bash
git status
git diff --staged
```

## 5. Commit erstellen

```bash
git commit -m "Kurze und verständliche Beschreibung"
```

Beispiel:

```bash
git commit -m "Exportfunktion für MGDM 2026 korrigiert"
```

Ein Commit wird zunächst nur im **lokalen Repository** gespeichert. Erst
`git push` überträgt ihn nach GitHub.

### Letzten Commit ergänzen

Falls vor dem Push eine Datei vergessen wurde:

```bash
git add vergessene_datei.sql
git commit --amend --no-edit
```

Beschreibung des letzten Commits ändern:

```bash
git commit --amend -m "Neue Beschreibung"
```

`git commit --amend` sollte vorzugsweise nur für Commits verwendet werden, die
noch nicht nach GitHub übertragen wurden.

## 6. Änderungen mit GitHub synchronisieren

### Änderungen von GitHub herunterladen und integrieren

```bash
git pull
```

Dies sollte insbesondere vor Arbeitsbeginn oder vor dem Push ausgeführt werden,
wenn mehrere Personen am Repository arbeiten.

### Änderungen nur herunterladen

```bash
git fetch
```

`git fetch` aktualisiert die Informationen über das Remote-Repository, verändert
aber die lokalen Dateien nicht.

### Lokale Commits hochladen

```bash
git push
```

Den lokalen Branch `main` beim ersten Push mit `origin/main` verbinden:

```bash
git push -u origin main
```

Danach genügt normalerweise:

```bash
git push
```

## 7. Commit-Historie anzeigen

Vollständige Historie:

```bash
git log
```

Kompakte Historie:

```bash
git log --oneline
```

Übersicht mit Verzweigungen und Referenzen:

```bash
git log --oneline --graph --decorate --all
```

Die letzten fünf Commits:

```bash
git log --oneline -5
```

Historie einer bestimmten Datei:

```bash
git log -- dateiname.sql
```

Einen bestimmten Commit anzeigen:

```bash
git show COMMIT-ID
```

Beispiel:

```bash
git show a1b2c3d
```

## 8. Änderungen rückgängig machen

### Nicht vorgemerkte Dateiänderungen verwerfen

```bash
git restore dateiname.sql
```

Dabei gehen die nicht gespeicherten Änderungen dieser Datei verloren.

### Bereits veröffentlichten Commit rückgängig machen

```bash
git revert COMMIT-ID
```

`git revert` erstellt einen neuen Commit, der die Änderungen des ausgewählten
Commits rückgängig macht. Das ist für bereits nach GitHub übertragene Commits
die sicherste Methode.

### Letzten lokalen Commit entfernen, Änderungen aber behalten

```bash
git reset --soft HEAD~1
```

Die Änderungen bleiben dabei im Staging-Bereich erhalten.

### Vorsicht bei `reset --hard`

```bash
git reset --hard
```

Dieser Befehl verwirft lokale Änderungen. Er sollte nur verwendet werden, wenn
genau bekannt ist, welche Änderungen dadurch verloren gehen.

## 9. Änderungen vorübergehend zwischenspeichern

Lokale Änderungen beiseitelegen:

```bash
git stash
```

Auch noch nicht von Git verwaltete Dateien einbeziehen:

```bash
git stash -u
```

Gespeicherte Änderungen anzeigen:

```bash
git stash list
```

Zuletzt gespeicherte Änderungen wiederherstellen und aus dem Stash entfernen:

```bash
git stash pop
```

Änderungen wiederherstellen, aber im Stash behalten:

```bash
git stash apply
```

## 10. Remote-Repositories verwalten

Verknüpfte Remote-Repositories anzeigen:

```bash
git remote -v
```

Remote hinzufügen:

```bash
git remote add origin https://github.com/BENUTZER/REPOSITORY.git
```

Adresse eines Remotes ändern:

```bash
git remote set-url origin https://github.com/BENUTZER/REPOSITORY.git
```

Remote umbenennen:

```bash
git remote rename origin azure
```

Remote-Verknüpfung entfernen:

```bash
git remote remove azure
```

Das Entfernen einer Remote-Verknüpfung löscht weder die lokalen Dateien noch das
Repository auf dem Server.

## 11. Branches

Vorhandene lokale Branches anzeigen:

```bash
git branch
```

Lokale und entfernte Branches anzeigen:

```bash
git branch -a
```

Neuen Branch erstellen und direkt dorthin wechseln:

```bash
git switch -c neuer-branch
```

Zu `main` wechseln:

```bash
git switch main
```

Branch in den aktuell geöffneten Branch integrieren:

```bash
git merge branchname
```

Lokalen Branch löschen:

```bash
git branch -d branchname
```

Auch wenn aktuell nur mit `main` gearbeitet wird, kann ein separater Branch
später für grössere oder riskantere Änderungen hilfreich sein.

## 12. Tags

Tag für den aktuellen Commit erstellen:

```bash
git tag v1.0
```

Tags anzeigen:

```bash
git tag
```

Einen Tag nach GitHub übertragen:

```bash
git push origin v1.0
```

Alle Tags übertragen:

```bash
git push origin --tags
```

## 13. Dateien mit `.gitignore` ausschliessen

Dateien und Ordner, die Git nicht verwalten soll, werden in einer Datei namens
`.gitignore` eingetragen:

```gitignore
*.log
*.tmp
.env
temp/
output/
```

Typische Inhalte für `.gitignore` sind:

- temporäre Dateien,
- Logdateien,
- automatisch erzeugte Exportdateien,
- lokale Programmeinstellungen,
- Dateien mit Passwörtern oder Zugangsdaten.

Passwörter, Tokens und andere Geheimnisse sollten grundsätzlich nie in ein
Git-Repository committed werden.

## 14. Git-Konfiguration

Benutzername festlegen:

```bash
git config --global user.name "Vorname Nachname"
```

E-Mail-Adresse festlegen:

```bash
git config --global user.email "name@example.com"
```

Aktuelle Konfiguration anzeigen:

```bash
git config --list
```

## 15. Empfohlener täglicher Ablauf

### Vor dem Bearbeiten

```bash
git pull
git status
```

### Nach dem Bearbeiten

```bash
git status
git diff
git add .
git diff --staged
git commit -m "Beschreibung der Änderung"
git push
```

## 16. Die wichtigsten Befehle auf einen Blick

| Befehl | Zweck |
|---|---|
| `git status` | Aktuellen Zustand anzeigen |
| `git diff` | Lokale Änderungen kontrollieren |
| `git add .` | Alle Änderungen für den Commit vormerken |
| `git commit -m "Text"` | Commit erstellen |
| `git pull` | Änderungen herunterladen und integrieren |
| `git push` | Lokale Commits hochladen |
| `git log --oneline` | Commit-Historie kompakt anzeigen |
| `git show COMMIT-ID` | Inhalt eines Commits anzeigen |
| `git restore DATEI` | Nicht vorgemerkte Dateiänderungen verwerfen |
| `git restore --staged DATEI` | Datei aus dem Staging-Bereich entfernen |
| `git revert COMMIT-ID` | Veröffentlichten Commit sicher rückgängig machen |
| `git stash` | Änderungen vorübergehend beiseitelegen |
| `git remote -v` | Remote-Verknüpfungen anzeigen |

## Kurzfassung

Für die normale Arbeit reichen meistens diese Befehle:

```bash
git pull
git status
git diff
git add .
git diff --staged
git commit -m "Beschreibung"
git push
git log --oneline
```
