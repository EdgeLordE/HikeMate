import 'dart:convert';
import 'package:http/http.dart' as http;

class Watchlist {

  static Future<Map<String, dynamic>> AddToWatchlist(int userId, int mountainID) async {
    const String apiUrl = "http://193.141.60.63:8080/Watchlist";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UserID": userId,
          "MountainID": mountainID,
        }),
      );

      if (response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          // Der Python-Controller gibt zurück: {"response": response.data}
          return {
            "success": true,
            "message": "Erfolgreich zur Watchlist hinzugefügt",
            "data": data['response'] // Die tatsächlichen Daten vom Server weitergeben
          };
        } catch (e) {
          // Dieser Fall bedeutet, dass der Server 201 gesendet hat, aber der Body kein valides JSON war
          return {
            "success": true, // Gemäß Statuscode trotzdem als Erfolg werten
            "message": "Erfolgreich zur Watchlist hinzugefügt (Serverantwort war nicht lesbar)"
          };
        }
      } else {
        // Alle anderen Statuscodes (400, 404, 500, etc.) als Fehler behandeln
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          // Versuchen, eine spezifische Fehlermeldung aus JSON zu extrahieren
          if (errorData != null) {
            if (errorData["error"] != null) {
              errorMessage = errorData["error"].toString();
            } else if (errorData["message"] != null) {
              errorMessage = errorData["message"].toString();
            } else {
              // Valides JSON, aber keine 'error' oder 'message' Schlüssel
              errorMessage = "Unbekannte Fehlerstruktur vom Server (Code: ${response.statusCode}).";
            }
          } else {
            // Sollte für eine gültige JSON-Zeichenkette nicht passieren, aber als Fallback
            errorMessage = "Ungültige oder leere Fehlerantwort vom Server (Code: ${response.statusCode}).";
          }
        } catch (e) {
          // JSON-Parsing fehlgeschlagen (z.B. Server sendet HTML für 404 oder nicht-JSON Fehler)
          if (response.statusCode == 404) {
            errorMessage = "Der angeforderte Endpunkt (/Watchlist) wurde nicht gefunden (Fehlercode: 404).";
          } else {
            errorMessage = "Fehlerhafte oder unerwartete Antwort vom Server (Code: ${response.statusCode}). Die Antwort konnte nicht verarbeitet werden.";
          }
        }
        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      // Netzwerkfehler oder andere Ausnahme während der HTTP-Anfrage
      return {"success": false, "message": "Kommunikationsfehler mit dem Server: ${e.toString()}"};
    }
  }

}