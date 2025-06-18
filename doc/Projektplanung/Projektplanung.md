# Projektplanung

## Aufbau der GUI (Skizzen)


### Welche Fenster wird es geben?
- Registrieren Page
- Login Page
- Home Page
- Berg suchen Page
- Wetter Page
- Profil Page
- Berge gemacht Page

### Wie sehen diese grob aus?
- Registrieren Page
![Registrieren Page](Abgabe_05_05_2025/image-9.png)
- Login Page
![Login Page](Abgabe_05_05_2025/image-7.png)
- Home Page
![Home Page](Abgabe_05_05_2025/image.png)
- Tracking gestartet Page
![Tracking gestartet Page](Abgabe_05_05_2025/image-1.png)
- Berg suchen Page
![Berg suchen Page](Abgabe_05_05_2025/image-2.png)
- Wetter Page
![Wetter Page](Abgabe_05_05_2025/image-6.png)
- Profil Page
![Profil Page](Images/Screenshot%202025-05-09%20093956.png)
- Berge gemacht Page
Diese Skizze haben wir noch nicht erstellt, braucht aber auch keine richtige SKizze, da es nur eine Liste ist

### Wie ist die Benutzernavigation geplant?
- Von der Login Page gelang man zu der Home Page (Und die Page wo direkt angezeigt wird ist entweder die Berge suchen Page oder die Navigation Page)
- Bei der Page angekommen kann man unten navigieren zwischen den verschiedenen Seiten (Home, Berge suchen, Wetter, Profil, Berge gemacht)
- Auf der Navigation Page kann man auf tracking starten und dann kommt ein grauer bereich mit den Informationen (siehe skizze)
- Bei WetterPage kann man die Stadt auswählen und dann wird das Wetter angezeigt
- Bei der Search Mountain Page kann man einen berg eingeben und dann wird ein Bild von diesem angezeigt die höhe und der Ort des Berges auch gibt es ein button um den Berg zu der DoneList hinzuzufügen
- Bei der Profile Page sieht man seine Aktivitäten und kann sachen machen wie den Namen ändern, das Passwort ändern
- Bei der Done Page sieht man einfach nur welche berge man gemacht hat und kann diese auch löschen

## Aufbau des Programms/der Datenbank

![ER-Diagramm](Abgabe_05_05_2025/ER.png)
hier ist das ER-Diagramm zu sehen.

![Klassendiagramm](Abgabe_05_05_2025/Klassendiagramm.png)
hier ist das Klassendiagramm zu sehen.

### wie arbeiten sie zusammen?
Mit Supabase oder postgreSQL wird die Datenbank online erstellt und mit Swagger wird auf die Datenbank zugegriffen, am Anfang werden wir direkt von flutter auf die Datenbank zugreifen da es schneller geht und währenddessen werden die Endpunkte nach und nach erstellt.
- Mit einem öffentlichen Server der als Rest-API fungiert, wird die Kommunikation zwischen der App und der Datenbank ermöglicht.
- Die App sendet Anfragen an den Server, auf dem Server läuft die ganze zeit die swagger python Datei, die die Anfragen entgegennimmt und die Datenbank abfragt.
- Der server hat eine öffentliche IP-Adresse, die in der App hinterlegt ist, um so die Abfragen zu ermöglichen.



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



