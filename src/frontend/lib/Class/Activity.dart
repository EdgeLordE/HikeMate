import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Logging.dart';
import 'User.dart';

/// Klasse für die Verwaltung von Wanderaktivitäten in der HikeMate App
/// 
/// Diese Klasse stellt Methoden zur Verfügung, um Aktivitätsdaten
/// vom Backend-Server zu laden und zu verwalten.
class Activity {
  /// Logger für diese Klasse - wird für alle Log-Nachrichten verwendet
  static final _log = LoggingService();

  /// Lädt alle Aktivitäten für einen bestimmten Benutzer vom Server
  /// 
  /// Diese Methode sendet eine HTTP GET-Anfrage an das Backend,
  /// um alle Wanderaktivitäten eines Benutzers zu bekommen.
  /// 
  /// [userId] - Die eindeutige ID des Benutzers (muss größer als 0 sein)
  /// 
  /// Rückgabe: Eine Liste mit Maps, die jeweils eine Aktivität enthalten.
  /// Jede Map hat Felder wie 'id', 'name', 'date', 'distance', etc.
  /// 
  /// Bei Fehlern oder wenn der Server nicht antwortet, wird eine
  /// leere Liste zurückgegeben.
  static Future<List<Map<String, dynamic>>> fetchActivitiesByUserId(
      int userId) async {
    _log.i('Rufe Aktivitäten für User ID $userId ab.');
    final url = Uri.parse('${User.baseUrl}/Aktivitaet?user_id=$userId');
    try {
      final response =
      await http.get(url, headers: {'Accept': 'application/json'});
      _log.i('Activity.fetchActivitiesByUserId() status: ${response.statusCode}');
      _log.d('Activity.fetchActivitiesByUserId() body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _log.i('Aktivitäten erfolgreich geladen und geparst.');
        return List<Map<String, dynamic>>.from(data['activities'] as List);
      }
      _log.w(
          'Aktivitäten konnten nicht geladen werden, Statuscode: ${response.statusCode}');
      return [];
    } catch (e) {
      _log.e('Fehler beim Laden der Aktivitäten: $e');
      return [];
    }
  }
}