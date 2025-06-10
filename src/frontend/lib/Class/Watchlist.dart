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
          "user_id": userId,
          "mountain_id": mountainID,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "message": "Erfolgreich zur Watchlist hinzugefügt", "data": data['response']};
      } else if (response.statusCode == 404) {
        String msg;
        try {
          final error = jsonDecode(response.body);
          // Versuche, die spezifische Nachricht "message" zu erhalten.
          // Wenn nicht vorhanden oder null, verwende den gesamten Antwortkörper, falls dieser nicht leer ist.
          // Andernfalls ein Fallback.
          msg = error["message"]?.toString() ?? (response.body.isNotEmpty ? response.body : "Element konnte nicht zur Watchlist hinzugefügt werden (Fehlercode: 404).");
        } catch (e) {
          // Wenn JSON-Parsing fehlschlägt, verwende den Antwortkörper, falls nicht leer, sonst Fallback.
          msg = response.body.isNotEmpty ? response.body : "Fehlerhafte Antwort vom Server (Fehlercode: 404).";
        }
        return {"success": false, "message": msg};
      } else { // Andere Fehlercodes (z.B. 500, 400, 401 etc.)
        String msg;
        try {
          final error = jsonDecode(response.body);
          // Versuche, die spezifische Nachricht "error" oder "message" zu erhalten.
          // Wenn nicht vorhanden oder null, verwende den gesamten Antwortkörper, falls dieser nicht leer ist.
          // Andernfalls ein Fallback.
          msg = error["error"]?.toString() ?? error["message"]?.toString() ?? (response.body.isNotEmpty ? response.body : "Ein Serverfehler ist aufgetreten (Fehlercode: ${response.statusCode}).");
        } catch (e) {
          // Wenn JSON-Parsing fehlschlägt, verwende den Antwortkörper, falls nicht leer, sonst Fallback.
          msg = response.body.isNotEmpty ? response.body : "Fehlerhafte Antwort vom Server (Fehlercode: ${response.statusCode}).";
        }
        return {"success": false, "message": msg};
      }
    } catch (e) {
      // Netzwerkfehler oder andere Fehler bei der Anfrageverarbeitung
      return {"success": false, "message": "Kommunikationsfehler oder interner Fehler: ${e.toString()}"};
    }
  }
}