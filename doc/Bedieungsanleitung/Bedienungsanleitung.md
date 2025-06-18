# Bedienungsanleitung – HikeMate

## 0. Setup

1. **Android-Gerät**  
   - Smartphone per USB-Kabel mit dem PC verbinden.  
   - Im Geräte-Popup "Daten übertragen (File Transfer)" auswählen.  
   - Entwicklermodus am Android aktivieren (Einstellungen → Über das Telefon → Build-Nummer siebenmal antippen) und USB-Debugging einschalten.

2. **iOS-Gerät**  
   - iPhone per Lightning-Kabel mit dem Mac verbinden.  
   - Gerät in Xcode als vertrauenswürdig bestätigen.  
   - In den iOS-Einstellungen unter Entwickleroptionen USB-Debugging aktivieren (falls vorhanden).

3. **PC-Einstellungen**  
   - Flutter und Android SDK installiert und in PATH registriert.  
   - Bei Android: `adb devices` im Terminal ausführen, um Verbindung zu überprüfen.  
   - Bei iOS: `flutter devices` oder Xcode aufrufen, um das Gerät zu erkennen.
   - In den Einstellungen sollt der Entwicklermodus an aktiviert.

## 1. Installation

1. **Aus dem Quellcode**  
   - Repository klonen: `git clone https://github.com/EdgeLordE/HikeMate/`  
   - Abhängigkeiten installieren: `flutter pub get`  
   - App starten: `flutter run`  


## 2. Benutzeranmeldung

1. **Registrieren**  
   - Im Login-Screen auf „Registrieren“ tippen.  
   - E-Mail, Benutzernamen und Passwort eingeben.  
   - Auf „Konto erstellen“ tippen.  
2. **Anmelden**  
   - E-Mail und Passwort im Login-Screen eingeben.  
   - Auf „Anmelden“ tippen.  
3. **Passwort/Benutzername ändern**  
   - Profil öffnen, zu „Einstellungen“ navigieren.  
   - „Passwort ändern“ oder „Benutzername ändern“ auswählen.  
   - Neue Daten eingeben und speichern.  


## 3. Hauptnavigation

- **Bergsuche & Wetter**: Nach Bergen suchen und Wetterdaten anzeigen.  
- **Live-Tracking**: Tour starten, beenden und Messwerte in Echtzeit einsehen.  
- **Profil**: Persönliche Statistiken, DoneList und Einstellungen.
- **DonePage**: Liste der bereits bestiegenen und noch zu bestiegenden Berge


## 4. Bergsuche

1. Suchfeld oben in der Bergsuche-Seite nutzen.  
2. Bergnamen eingeben und aus der Liste auswählen.  
3. In der Detailansicht werden Höhe, Standort und Beschreibung angezeigt.
4. optional: Berg als gemacht markieren oder zur Watchlist hinzufügen indem man auf das Stern klickt  

## 5. Wetterbericht

1. Wetterseite öffnen.  
2. Stadt oder Standort nutzen.  
3. Aktuelle Wetterdaten und Mehrtagesprognose anzeigen lassen.  


## 6. Live-Tracking

1. **Tour starten**: Auf „Tour beginnen“ tippen.  
2. **Tour beenden**: Auf „Beenden“ tippen; Tour wird gespeichert und in DoneList übernommen.  
3. **Angezeigte Daten**:  
   - Dauer  
   - Distanz  
   - Höhenmeter  
   - Geschätzter Kalorienverbrauch  


## 7. DoneList & Statistiken

1. **DoneList**: Abgeschlossene Touren auflisten und abhaken.  
2. **Profil-Statistik**: Gesamtstrecke, Gesamtaufstieg und Anzahl der Touren einsehen.  


## 8. Einstellungen

- **Notfall-Telefonnummer** hinterlegen oder ändern.
- **Nutzername/Passwort** ändern.


## 9. App

   ### 9.1 Benutzeranmeldung

   - **Regristrieren/Login:**
      - Im Login-Screen auf "Registrieren" klicken
      - Vorname, Nachname, Nutzername und Passwort eingeben, und bestätigen.
      - Dann wird man auf die LoginPage zurückgeleitet und kann sich mit seinem erstellten Account einloggen.
       
      ![image](https://github.com/user-attachments/assets/3e61dbc7-bc8d-4fec-8ccf-23fba8e9f5e9)
     
      ![image](https://github.com/user-attachments/assets/dafca294-3523-4ab5-b91e-d600c929590d)

   - Notfallnummer/Benutzername/Passwort ändern:
      - Profil öffnen (4. Symbol in der Navigation), oben rechts auf die 3 Menüpunkte.
      - auf "Einstellungen klicken"
      - hier kann man dann die gewünschten Änderungen vornehmen.

       ![image](https://github.com/user-attachments/assets/79bf45c6-9ece-46a5-8eb4-daf98d27896b)

   ### 9.2 Hauptnavigation

   - **Bergsuche:** Hier kann man nach Bergen suchen, sowie Berge als "gemacht" markieren oder auf die Watchlist packen.
   - Wetter: Hier kann man sich die Wetterdaten von heute und den nächsten Tagen anzeigen lassen.
   - Live-Tracking: Tour starten, pausieren, beenden und Messwerte in Echtzeit einsehen.
   - Profil: Persöhnliche Statistiken, sowie Einstellungen vornehmen
   - DoneList: Hier kann man die gemachten Berge, sowie Watchlist verwalten. Mit Filter funktion

   ![image](https://github.com/user-attachments/assets/43398932-4752-445b-9766-3131cf9a0d78)

   ## 9.3 Bergsuche:
   
   - Suchfeld oben in der Bergsuche-Seite nutzen.
   - Bergname eingeben
   - In der Detailansicht werden Höhe, Standort und Beschreibung angezeigt.
   - optional: Berg abhaken oder auf die zu machende Berge Liste hinzufügen.
   
   ![image](https://github.com/user-attachments/assets/52d20921-053f-451d-a9a9-9a5ee2e76b66)

   ### 9.4 Wetterbericht

   - Wetterseite öffnen.
   - Stadt oder Standort nutzen.
   - Aktuelle Wetterdaten und Mehrtagesprognose anzeigen lassen.

   ![image](https://github.com/user-attachments/assets/7ba736c0-260b-4943-b675-89ded1ef8397)

   ### 9.5 Live-Tracking
   
   - Tour starten: Auf „Tour beginnen“ tippen.
   - Tour beenden: Auf „Beenden“ tippen; Tour wird gespeichert und im Profil unter "Aktivitätenverlauf angezeigt.
   - Angezeigte Daten:
      - Dauer
      - Distanz
      - Höhenmeter
      - Geschätzter Kalorienverbrauch
   - Auf der rechten Seite findet man ein Icon zum zentrieren der Karte.

   ![image](https://github.com/user-attachments/assets/b06fb609-e62a-44de-a2b9-3d5d729d3260)

   ### 9.6 Profil

   - Oben Links wird der Benutzername angezeigt.
   - Oben Rechts kommt man zu den Einstellungen bzw. kann man sich da auch Abmelden.
   - Gesamtstatistik: Hier findet man den Durchschnitt aller Aktivitäten
   - Aktivitätenverlauf, hier wird folgendes angezeigt:
      - Datum
      - Distanz
      - Dauer
      - Anstieg
      - Kalorienverbrauch
      - Maximale Höhe

   ![image](https://github.com/user-attachments/assets/fd4a858c-f44e-42fa-adfd-cad23920ae9d)

   ## 9.7 DonePage & Watchlist

   - DonePage:
      - Hier findet man eine Übersicht aller Berge, die unter „SearchMountain“ angelegt wurden.
Die Liste lässt sich nach Bundesland, alphabetisch sowie nach Hinzufügungsdatum (neu → alt bzw. alt → neu) sortieren. Diese können auch entfernt werden.

   ![image](https://github.com/user-attachments/assets/4cae9d09-335f-4d57-97b1-e3788e83741a)

   - Watchlist
      - Hier kann man Berge abhaken, also zu den gemachten Bergen hinzufügen oder entfernen

   ![image](https://github.com/user-attachments/assets/e2b682df-c982-4fa3-b204-0ef4ebee134f)


