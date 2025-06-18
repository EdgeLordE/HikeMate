import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Logging.dart';
import 'User.dart';

class Activity {
  static final _log = LoggingService();

  static Future<List<Map<String, dynamic>>> fetchActivitiesByUserId(
      int userId, [http.Client? client]) async {
    final httpClient = client ?? http.Client();
    _log.i('Rufe Aktivitäten für User ID $userId ab.');
    final url = Uri.parse('${User.baseUrl}/Aktivitaet?user_id=$userId');
    try {
      final response =
      await httpClient.get(url, headers: {'Accept': 'application/json'});
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
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}