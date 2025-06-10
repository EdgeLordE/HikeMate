import 'dart:convert';
import 'package:http/http.dart' as http;
// Stelle sicher, dass User.id zugänglich ist, ggf. importieren
// import 'User.dart'; // Falls User.id hier benötigt wird und nicht als Parameter übergeben wird

class Watchlist {
  static Future<Map<String, dynamic>> AddToWatchlist(int userId, int mountainID) async {
    // Annahme: Der Endpunkt für das Hinzufügen zur Watchlist ist /Watchlist
    // Passe dies an, falls dein Swagger-File einen anderen Pfad definiert.
    const String apiUrl = "http://193.141.60.63:8080/Watchlist";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        // Der Python-Controller erwartet user_id und mountain_id,
        // die im Body als JSON gesendet werden.
        body: jsonEncode({
          "user_id": userId,
          "mountain_id": mountainID,
        }),
      );

      if (response.statusCode == 200) {
        // Erfolgreich zur Watchlist hinzugefügt
        final data = jsonDecode(response.body);
        // Der Python-Controller gibt {"response": response.data} zurück
        return {"success": true, "message": "Erfolgreich zur Watchlist hinzugefügt", "data": data['response']};
      } else if (response.statusCode == 404) {
        // Fehlerfall vom Server (z.B. "Failed to add item to watchlist")
        final error = jsonDecode(response.body);
        return {"success": false, "message": error["message"] ?? "Element konnte nicht zur Watchlist hinzugefügt werden."};
      }
      else {
        // Andere Fehler vom Server (z.B. 500)
        final error = jsonDecode(response.body);
        return {"success": false, "message": error["error"] ?? "Ein unbekannter Fehler ist aufgetreten."};
      }
    } catch (e) {
      // Netzwerkfehler oder Fehler beim Parsen
      return {"success": false, "message": "Fehler: $e"};
    }
  }
}