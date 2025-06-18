import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Logging.dart';

/// Klasse für die Verwaltung von Berg-Daten in der HikeMate App
/// 
/// Diese Klasse stellt Methoden zur Verfügung, um Informationen
/// über Berge vom Backend-Server zu laden und zu durchsuchen.
class Mountain {
  /// Logger für diese Klasse
  static final _log = LoggingService();

  /// Sucht nach Bergen anhand des Namens
  /// 
  /// Diese Methode sendet eine GET-Anfrage an das Backend um Berge
  /// zu finden, die dem angegebenen Namen entsprechen oder ihn enthalten.
  /// 
  /// [name] - Der Name oder Teil des Namens des gesuchten Berges
  /// 
  /// Rückgabe: Map mit "success" (bool) und entweder "data" oder "message"
  /// Bei Erfolg: {"success": true, "data": [Liste der gefundenen Berge]}
  /// Bei Fehler: {"success": false, "message": "Fehlerbeschreibung"}
  /// 
  /// Die "data" enthält eine Liste von Berg-Objekten mit Informationen
  /// wie ID, Name, Höhe, Koordinaten, Bundesland, etc.
  static Future<Map<String, dynamic>> SearchMountainByName(String name) async {
    _log.i('Suche nach Berg mit Namen: "$name"');
    final String apiUrl =
        "http://193.141.60.63:8080/Berg?mountain_name=${Uri.encodeComponent(name)}";
    _log.d('API URL: $apiUrl');

    try {
      final response = await http.get(
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
    }
  }
}