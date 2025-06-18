import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Logging.dart';

class Mountain {
  static final _log = LoggingService();
  static const String baseUrl = "http://193.141.60.63:8080";

  static Future<Map<String, dynamic>> SearchMountainByName(String name,
      [http.Client? client]) async {
    _log.i('Suche nach Berg mit Namen: "$name"');
    final httpClient = client ?? http.Client();
    final String apiUrl =
        "$baseUrl/Berg?mountain_name=${Uri.encodeComponent(name)}";
    _log.d('API URL: $apiUrl');

    try {
      final response = await httpClient.get(
        Uri.parse(apiUrl),
        headers: {"Accept": "application/json"},
      );

      _log.i('Mountain.SearchMountainByName() status: ${response.statusCode}');
      _log.d('Mountain.SearchMountainByName() body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _log.i('Berg(e) erfolgreich gefunden und geparst.');
        return {"success": true, "data": data['response']};
      } else if (response.statusCode == 404) {
        final error = jsonDecode(response.body);
        _log.w('Kein Berg mit dem Namen "$name" gefunden.');
        return {
          "success": false,
          "message": error["message"] ?? "Berg nicht gefunden"
        };
      } else {
        final error = jsonDecode(response.body);
        _log.w('Fehler bei der Bergsuche, Status: ${response.statusCode}');
        return {
          "success": false,
          "message": error["error"] ?? "Ein unbekannter Fehler ist aufgetreten"
        };
      }
    } catch (e) {
      _log.e('Fehler bei Mountain.SearchMountainByName(): $e');
      return {"success": false, "message": "Netzwerkfehler oder Client-Fehler: $e"};
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}