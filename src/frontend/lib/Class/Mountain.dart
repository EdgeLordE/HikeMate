import 'dart:convert';
import 'package:http/http.dart' as http;

class Mountain{
  static Future<Map<String, dynamic>> SearchMountainByName(String name) async {
    final String apiUrl = "http://193.141.60.63:8080/Berg?mountain_name=${Uri.encodeComponent(name)}";
    // Alternativ, falls der Server /Mountain erwartet:
    // final String apiUrl = "http://193.141.60.63:8080/Mountain?mountain_name=${Uri.encodeComponent(name)}";

    try {
      // Verwende http.get gemäß Swagger-Definition
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Accept": "application/json"}, // "Content-Type" ist für GET nicht unbedingt nötig, "Accept" kann nützlich sein
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Der Python-Controller gibt zurück: {"response": response.data}
        // response.data von Supabase ist eine Liste.
        // data['response'] wird also eine Liste von Bergen sein.
        return {"success": true, "data": data['response']};
      } else if (response.statusCode == 404) {
        final error = jsonDecode(response.body);
        // Der Python-Controller gibt zurück: {"message": "No mountains found with that name"}
        return {"success": false, "message": error["message"] ?? "Berg nicht gefunden"};
      } else {
        final error = jsonDecode(response.body);
        // Für andere Server-Fehler (z.B. 500)
        return {"success": false, "message": error["error"] ?? "Ein unbekannter Fehler ist aufgetreten"};
      }
    } catch (e) {
      return {"success": false, "message": "Netzwerkfehler oder Client-Fehler: $e"};
    }
  }
}