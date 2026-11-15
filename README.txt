VPN Menu Bar v5 – Apple Silicon

Neu: Farbwahl per macOS-Farbpalette, größere 18px-Punktanzeige, Autostart-Schalter in Einstellungen.

Installation:
1. Alte VPN Menu Bar über Menü > Beenden schließen.
2. Im entpackten Ordner Terminal öffnen und bash build.command ausführen.
3. Die erzeugte App unter build/VPN Menu Bar.app in den Ordner Programme (/Applications) kopieren.
4. Die App aus Programme starten und über den Menüleistenpunkt Einstellungen öffnen.
5. Autostart per Checkbox aktivieren. Je nach macOS-Sicherheitseinstellungen kann eine Bestätigung nötig sein.

WICHTIG: App nicht aus dem temporären Build-Ordner für Autostart registrieren.
Die Anmeldung wird mit Apples SMAppService.mainApp verwaltet; die Funktion kann bei lokal ad-hoc-signierten Apps je nach macOS-Konfiguration abgelehnt werden. In diesem Fall unter Systemeinstellungen > Allgemein > Anmeldeobjekte und Erweiterungen die App manuell hinzufügen.

Farben werden lokal über UserDefaults gespeichert. Das Programm wurde hier nicht auf macOS kompiliert oder getestet.

Status-Erkennung: scutil --nc list; andere Tunnel können unentdeckt bleiben. Grün bedeutet keine aktive, dort gemeldete VPN-Verbindung.
