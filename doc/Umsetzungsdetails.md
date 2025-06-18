## Probleme und Herausforderungen

1. **Unit Tests für existierende Klassen**  
   - Klassen mussten umgebaut werden (z.B. Abhängigkeiten injizierbar machen) um Tests schreiben zu können.  
   - Aufwand: Refactoring vor Test-Implementierung.

2. **Permission-Handling (SMS & Standort)**  
   - Android Runtime Permissions für SMS (SOS) und GPS (Tracking) korrekt anfordern und handhaben.  
   - iOS: Einschränkungen im Hintergrundmodus und strikte Datenschutzrichtlinien führten dazu, dass Berechtigungen extra und oft erneut vom Nutzer bestätigt werden müssen.  
   - Apple lässt etwa keinen dauerhaften Hintergrund-Standortzugriff zu, ohne dass der Nutzer in den Systemeinstellungen manuell aktiviert.  
   - Sicherheit: Explizite Erklärungen (Privacy Usage Descriptions) müssen aussagekräftig sein.  
   - Besonderheit: Nutzer kann Berechtigungen jederzeit entziehen – App muss dies runtime inaktivitätsgesteuert erkennen und den Nutzer zur Wiederaktivierung hinweisen.

3. **SOS-Funktionalität**  
   - Intervall-Trigger und direkte Notruf-Funktion im Hintergrund-Service.  
   - Probleme: Android Doze-Mode blockierte Alarme, Testing auf verschiedenen Geräten unterschiedlich.  
