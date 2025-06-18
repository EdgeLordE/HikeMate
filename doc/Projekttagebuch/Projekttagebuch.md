# Projekttagebuch

## Mathias

| Datum       | Was gemacht? |
|-------------|--------------|
| **18.06.2025** | • .exe build setup <br> • Merge des Remote-Branches `origin/main` und Konfliktlösung<br>• Bedienungsanleitung finalisiert (PDF & Markdown)<br>• Fix von `DonePage.dart`, Berge löschen nicht möglich <br>• Bugfix in `Watchlist.dart` <br>• Erweiterung der Unit-Tests um Logger-Klasse (`LoggerTest`) <br>• `pubspec.yaml`: Dependencies aktualisiert, Dev-Dependencies ergänzt und ungenutzte Pakete entfernt |
| **16.06.2025** | • **Frontend**: UI-Glitches in `SearchMountainPage.dart` (Filter-Reset) und `Done.dart` (Listen-Refresh) korrigiert<br>• **Logging**: Log in `Logging.dart` angepasst und Fehlermeldungen angepasst<br>• **Unit-Tests** gexit, kleiner bug beim testen  |
| **15.06.2025** | • **DonePage** gefixt und `DonePage.dart` überarbeitet (Performance-Optimierung beim Scrollen)<br>• `settings_page.dart`: Layout-Feinschliff und Button-Zustände ergänzt<br>• `AndroidManifest.xml`: SMS-Permission hinzugefügt und Berechtigungsdialog optimiert<br>• `checkin_service.dart` implementiert und Intervall-Tests angelegt<br>• `emergency_page.dart`: automatische Standortfreigabe & direkte SOS-Funktion integriert<br>• SOS-Button in `NavigationPage.dart` eingebaut<br>• **ProfilePage**: UI-Optimierung (Buttons & Menüs neu angeordnet) und Live-Refresh implementiert<br>• `pubspec.yaml`: Versionssperren aktualisiert<br>• Notfall-Nummer, Passwort-/Username-Änderung in `settings_page.dart` ergänzt<br>• `WeatherPage.dart`: Temperatur-Parsing-Fehler behoben |
| **14.06.2025** | • Neue Service-Klasse `UserService.dart` für Username-/Passwort-Logik erstellt<br>• **ProfilePage.dart**: Menüpunkte für Abmelden, Passwort- und Username-Änderung hinzugefügt, alte Buttons entfernt und UI-Tests ergänzt<br>• `ChangePasswordPage.dart` & `ChangeUsernamePage.dart` angelegt und Formular-Validierung umgesetzt<br>• Supabase-Integration in `supabase_client.dart` angepasst |
| **06.06.2025** | • **DonePage** hinzugefügt und Eintragslöschung optimiert (Teil-Fix)<br>• **ProfilePage.dart**: Anzeige von Distanz & Dauer korrigiert, Progress-Indicator ergänzt<br>• Gesamtstatistik & Aktivitätenverlauf im Profil implementiert <br>• Unit-Tests für Profil-Logik (`ProfileTest`) und Done-Feature (`DonePageTest`) hinzugefügt |
| **28.05.2025** | • Homepage um **ProfilePage.dart** erweitert und Routing optimiert<br>• Frontend für Gesamtstatistik und E-Mail/Passwort-Änderung erstellt<br>• Datenmodell `Mountain.dart` angepasst und Validierungs-Tests (`MountainModelTest`) ergänzt<br>• Unnötigen letzten Eintrag in `WeatherPage` entfernt |
| **27.05.2025** | • `WeatherPage.dart`: Suchfunktion & Standort-Default integriert<br>• Tagesansicht mit Uhrzeit und Mehrtagesprognose implementiert<br>• UI-Feinschliff (fehlende Uhrzeit, Farbvorschläge) und Performance-Optimierungen durchgeführt<br>• Daten-Klasse `WeatherData.dart` verfeinert und Tests (`WeatherDataTest`) erstellt |
| **26.05.2025** | • `WeatherPage` als Demo-Page mit API-Integration eingebunden<br>• **LocationTracker.dart** um Genauigkeits-Filter und Hintergrund-Tracking erweitert<br>• Tests für Wetter-API-Client (`WeatherApiTest`) implementiert |
| **05.05.2025** | • Klassendiagramm erstellt<br>• Projektvorschlag/Konzept aktualisiert (`Abgabe_Projektvorschlag_Konzept` angepasst)<br>• `create_db.py` Script hinzugefügt und Datenbankschema-Tests (`DbSchemaTest`) geschrieben |
| **28.04.2025** | • Flutter-Projekt initial aufgesetzt und erste Dateien ins Repo hochgeladen<br>• Grundstruktur in `lib/Class` und `lib/Pages` angelegt |






## Emil
| Datum | Was gemacht? |
|-------|--------------|
| 18.06.2025 | API Dokumentation komplett erstellt, Doxygen für Backend generiert und HTML-Dokumentation erstellt, UML-Klassendiagramm automatisch generiert, Swagger-Dokumentation stark verbessert mit besseren Beschreibungen und Beispielen, Logger optimiert (Datei wird täglich auf 10 Zeilen reduziert), Dokumentationsstruktur komplett überarbeitet |
| 17.06.2025 | Doxygen und Logging System komplett fertiggestellt mit ausführlichen Tests, Watchlist Controller Bug komplett gefixt, YAML Swagger Datei nachträglich gepusht, Doxygen bei allen Controllern implementiert und Tests dokumentiert, Start Server entfernt (nicht mehr benötigt), Watchlist remove Funktion mit watchlistID komplett eingeführt, Remove to Watchlist Funktion erstellt und alle Bugs behoben, AddToWatchlist Funktion komplett implementiert, Berge bei DoneList löschen Bug definitiv gefixt, Watchlist Controller fetch all Watchlist Funktion hinzugefügt, kleine Verbesserungen bei allen Dateien durchgeführt |
| 16.06.2025 | Watchlist Controller Bug endgültig gefixt, Done Page fast komplett auf Swagger umgestellt, Swagger YAML Datei vergessen nachzupushen, Done Bereich um wichtigen Endpunkt erweitert, Activity Bereich komplett auf Swagger umgestellt, Einrückungsfehler in Swagger YAML korrigiert, Profile Page komplett mit Swagger Backend verbunden, Settings Page vollständig auf Swagger umgestellt, kleinen Package-Fehler behoben, Done Swagger komplett fertiggestellt, weiteren Bug in Watchlist Controller entdeckt und behoben, Watchlist Controller Funktionen mehrfach hinzugefügt und Bugs systematisch behoben, ID zu Integer Konvertierung Problem gelöst |
| 15.06.2025 | Weitere wichtige Funktionen für Backend implementiert, Swagger Funktionen systematisch erstellt, komplettes Design für DonePage erstellt, wichtigen Bug gefixt (Berg kann nicht mehr auf Watchlist wenn bereits erledigt), komplettes Design für Profile Page fertiggestellt, Watchlist Funktionalität komplett fertiggestellt, nur noch Anzeige fehlt |
| 13.06.2025 | Mountain Controller erweitert sodass auch Bild-URLs ausgegeben werden (musste für Server commiten) |
| 12.06.2025 | Username und Passwort ändern komplett bei Swagger implementiert, Watchlist ebenfalls mit Swagger verbunden, wichtigen Bug bei Registrieren und Login Page gefixt (Eingaben verschwanden nach Tastatur-Ausblendung) |
| 10.06.2025 | Namen in Projekt geändert, JSON-Integration implementiert, Umbenennungen durchgeführt, Watchlist Swagger Fehler behoben, Watchlist komplett erstellt, Swagger Server grundlegend verändert, komplette Swagger Integration durchgeführt |
| 07.06.2025 | Alle Controller zum Backend hinzugefügt, Login über Server komplett implementiert, REST-API Server Ausgabe verbessert für bessere Lesbarkeit, mountain_controller.py Datei hinzugefügt, mountain_controller.py Abfrage geändert sodass Bundesland mitgeliefert wird |
| 04.06.2025 | Umfangreiche Skripte geschrieben um alle Bergdaten aus Österreich zu sammeln, SearchMountainPage komplett erstellt, Funktion zum Hinzufügen von Bergen zur Done-Liste implementiert (Design noch ausstehend) |
| 02.06.2025 | Statische User Klasse komplett erstellt, Aktivitäts-Speicherung in Datenbank implementiert |
| 31.05.2025 | Login und Registrierung mit Datenbank-Anbindung und Passwort-Hash komplett implementiert |
| 30.05.2025 | Swagger Framework zum Projekt hinzugefügt |
| 29.05.2025 | Hintergrund-Tracking Funktionalität getestet und implementiert |
| 28.05.2025 | Distanz- und Anstiegsberechnung implementiert, Pfadanzeige für Wanderroute erstellt, Button für aktuelle Position hinzugefügt, Merge mit main Branch durchgeführt |
| 26.05.2025 | NavigationsPage um Timer-Funktionalität erweitert, Seehöhen-Anzeige implementiert, komplettes Design überarbeitet |
| 23.05.2025 | ER-Diagramm Bilder erstellt, alle wichtigen Diagramme für Dokumentation generiert |
| 19.05.2025 | Komplettes UI für LoginPage erstellt, Registration Page UI komplett implementiert |
| 18.05.2025 | Navigation Page mit interaktiver Karte erstellt, Live-Standort Tracking implementiert |
| 09.05.2025 | Erste Projektdateien und Programmstruktur erstellt, alle Dokumentations-Dateien angelegt, erste Tests und Experimente durchgeführt |
| 05.05.2025 | Projektvorschlag komplett erstellt und ausführlich dokumentiert, PDF-Version generiert, Projektkonzept finalisiert |
| 15.06.2025 | Noch mehr Funktionen gemacht<br>Swagger Funktionen gemacht<br>Design DonePage gemacht<br>Bug gefixt: Man kann nicht mehr den Berg auf die Watchlist machen, wenn er schon erledigt ist<br>Design für Profile Page fertig<br>Watchlist fertig gemacht, jetzt nur noch anzeigen |
| 13.06.2025 | Mountain Controller gemacht, sodass auch die URL ausgegeben wird (musste commiten wegen dem Server) |
| 12.06.2025 | Username und Passwort ändern bei Swagger gemacht sowie Watchlist mit Swagger<br>Bugfix bei Registrieren- und Login-Page (Eingaben verschwanden nach Tastatur-Ausblendung) |
| 10.06.2025 | Namen geändert<br>Mit JSON jetzt<br>Rename<br>Watchlist auf Swagger Fehler behoben<br>Watchlist erstellt<br>Swagger Server verändert<br>Mit Swagger alles gemacht |
| 07.06.2025 | mountain_controller.py bei der Abfrage geändert, dass das Bundesland mitgeht<br>mountain_controller.py hinzugefügt<br>Die Controller hinzugefügt<br>Login über Server gemacht |
