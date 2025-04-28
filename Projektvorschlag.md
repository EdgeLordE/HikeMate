# Planung - HikeMate

## Wie werden die Mindestanforderungen umgesetzt?
- **Git**: Mit der aktiven Verwendung von GIT wird diese Mindesanforderung gedeckt. Auch wird hier die Planung durchgeführt mit den Tickets.
- **Klassendiagramme**: Werden davor geplant (z.B. Benutzer, Berg, Donelist).
- **Grafische Anwendung**: 3 Fenster werden wir auf jeden Fall haben (Login, Berge suchen, Wetterbericht, Live Tracking).
- **Vererbung & abstrakte Klassen**: Werden für gemeinsame Funktionalitäten verwendet.
- **Interfaces**: Werden für Services implementiert.
- **API Dokumentation**: Wird laufend von uns durchgeführt.
- **Unit Tests**: Tests werden nach Abschlüssen von Klassen/Methoden programmiert oder davor. Der Fokus liegt auf kritischen Methoden.
- **Logging**: Wird während dem Programmieren implementiert.
- **Bonus**: Hintergrund-Thread für Routing-Tracking.

**Datenbank**:
- **Tabellen**: Mind. 3 Tabellen (Berg, User, DoneList, Aktivitaet).
- **Select Joins**: Werden für Datenabfragen wie das Laden der DoneList verwendet.
- **2 Rollen (admin, user)**: 
  - Admin hat Lese-/Schreibzugriff auf alles.
  - User hat nur Leserechte und begrenzte Schreibrechte.
- **SQL Datenbank**: PostgreSQL (geplant/vorerst).
- **REST Interface/Swagger**: Wird für GET/POST-Operationen implementiert.
- **Unit Tests**: Werden nach Abschluss geschrieben, um die Funktionalität zu überprüfen.
- **Logging**: Wird während der Entwicklung implementiert.

## Welche Features sind ein Muss?
- **Live Tracking mit Karte** (Dauer, Höhenmeter, Distanz, Anstieg, kcal verbrannt).
- **Liste mit gemachten Bergen** (abhaken können).
- **UserLogin**.
- **Gesamtstatistik vom Account** (wie viel km gesamt gelaufen, Höhenmeter).
- **Aktivitäten speichern** (Wann war es, Dauer, Distanz, Anstieg).
- **Berge suchen können** (Daten wie Höhe des Berges).
- **Wetterbericht von Städten**.

## Welche Features sind Erweiterungen (nice-to-have), wenn genügend Zeit bleibt?
- **Lebensbestätigung** (alle zwei Stunden bestätigen, dass man lebt - Sound, Vibration).
- **Wetteranalyse** (Regen beginnt in 2 Stunden).
- **SOS-Knopf** (Notfall).
- **Achievements**.

## Wie möchten wir das Ganze grob umsetzen?
- **Framework**: Flutter
- **APIs für Funktionen**:
  - **Karten & GPS-Tracking**: OpenStreetMap API.
  - **Wetterdaten**: OpenWeather API.
- **Datenbank**: PostgreSQL.
- **Zusammenarbeit**: Über GitHub.