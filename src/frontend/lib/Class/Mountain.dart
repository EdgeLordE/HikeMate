/// Berg-Suchfunktionalität für die HikeMate App
/// 
/// Diese Klasse stellt Funktionen zur Verfügung um Berge aus der
/// Datenbank zu suchen und deren Informationen abzurufen.
/// 
/// Features:
/// - Berg-Suche nach Namen (Teilstring-Matching)
/// - Rückgabe von Berg-Details (ID, Name, Höhe, Bundesland, Bild-URL)
/// - HTTP-Client Unterstützung für Tests
/// - Umfassendes Logging aller API-Aufrufe
/// 
/// Die Klasse arbeitet mit dem Backend über REST-API
/// und unterstützt Dependency Injection für Tests.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Logging.dart';

/// Statische Klasse für Berg-Suchoperationen
class Mountain {
  /// Logger-Instanz für diese Klasse
  static final _log = LoggingService();
  /// Basis-URL für API-Aufrufe
  static const String baseUrl = "http://193.141.60.63:8080";

  /// Sucht nach Bergen anhand des Namens (Teilstring-Suche)
  /// 
  /// [name] - Suchbegriff für den Bergnamen (auch Teilstrings möglich)
  /// [client] - Optional: HTTP-Client für Tests (Dependency Injection)
  /// 
  /// Returns: Map mit success-Flag und data (Liste gefundener Berge)
  /// oder Fehlermeldung bei Problemen

  // prompt: mache alle Fehlermeldungen in der Funktion
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