import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Logging.dart';
import 'User.dart';

class Done {
  static final _log = LoggingService();
  static const String _baseUrl = User.baseUrl;

  static Future<bool> isMountainDone(int userId, int mountainId) async {
    _log.i('Prüfe, ob Berg $mountainId für User $userId erledigt ist.');
    final url =
    Uri.parse('$_baseUrl/DoneBerg/check?UserID=$userId&MountainID=$mountainId');
    try {
      final response =
      await http.get(url, headers: {'Accept': 'application/json'});
      _log.i('Done.isMountainDone() status: ${response.statusCode}');
      _log.d('Done.isMountainDone() body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] != null && data['response']['isDone'] != null) {
          return data['response']['isDone'] == true;
        }
      }
      _log.w('Prüfung fehlgeschlagen, Statuscode: ${response.statusCode}');
      return false;
    } catch (e) {
      _log.e('Fehler bei Done.isMountainDone(): $e');
      return false;
    }
  }

  static Future<bool> isMountainDoneSimple(int userId, int mountainId) async {
    _log.i('Prüfe (einfach), ob Berg $mountainId für User $userId erledigt ist.');
    final url =
    Uri.parse('$_baseUrl/DoneBerg/is_done?UserID=$userId&MountainID=$mountainId');
    try {
      final response =
      await http.get(url, headers: {'Accept': 'application/json'});
      _log.i('Done.isMountainDoneSimple() status: ${response.statusCode}');
      _log.d('Done.isMountainDoneSimple() body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['isDone'] != null) {
          return data['isDone'] == true;
        }
      }
      _log.w(
          'Einfache Prüfung fehlgeschlagen, Statuscode: ${response.statusCode}');
      return false;
    } catch (e) {
      _log.e('Fehler bei Done.isMountainDoneSimple(): $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> addMountainToDone(
      int userId, int mountainId) async {
    _log.i('Füge Berg $mountainId für User $userId zu Erledigt hinzu.');
    final url = Uri.parse('$_baseUrl/DoneBerghinzufuegen');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "UserID": userId,
          "MountainID": mountainId,
        }),
      );
      _log.i('Done.addMountainToDone() status: ${response.statusCode}');
      _log.d('Done.addMountainToDone() body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _log.i('Berg erfolgreich zu Erledigt hinzugefügt.');
        return {"success": true};
      } else {
        _log.w(
            'Fehler beim Hinzufügen des Berges zu Erledigt, Statuscode: ${response.statusCode}');
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data["error"] ?? data["message"] ?? "Unbekannter Fehler"
        };
      }
    } catch (e) {
      _log.e('Fehler bei Done.addMountainToDone(): $e');
      return {"success": false, "message": "Client-Fehler: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteDone(
      int doneId, int userId) async {
    _log.i('Lösche Erledigt-Eintrag $doneId für User $userId.');
    final url = Uri.parse('${User.baseUrl}/DeleteDone?DoneID=$doneId&UserID=$userId');
    try {
      final response =
      await http.delete(url, headers: {'Accept': 'application/json'});
      _log.i('Done.deleteDone() status: ${response.statusCode}');
      _log.d('Done.deleteDone() body: ${response.body}');
      if (response.statusCode == 200) {
        _log.i('Erledigt-Eintrag erfolgreich gelöscht.');
        final data = jsonDecode(response.body);
        return {"success": true, "message": data["message"] ?? "Done-Eintrag gelöscht."};
      } else {
        _log.w(
            'Fehler beim Löschen des Erledigt-Eintrags, Statuscode: ${response.statusCode}');
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data["error"] ?? data["message"] ?? "Unbekannter Fehler"
        };
      }
    } catch (e) {
      _log.e('Fehler bei Done.deleteDone(): $e');
      return {"success": false, "message": "Client-Fehler: $e"};
    }
  }

  static Future<Map<String, dynamic>> fetchDoneList(int userId) async {
    _log.i('Rufe Erledigt-Liste für User $userId ab.');
    final url = Uri.parse('$_baseUrl/Done?UserID=$userId');
    try {
      final response =
      await http.get(url, headers: {'Accept': 'application/json'});
      _log.i('Done.fetchDoneList() status: ${response.statusCode}');
      _log.d('Done.fetchDoneList() body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _log.i('Erledigt-Liste erfolgreich abgerufen.');
        return {"success": true, "data": data["data"] ?? []};
      } else {
        _log.w(
            'Fehler beim Abrufen der Erledigt-Liste, Statuscode: ${response.statusCode}');
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data["error"] ?? data["message"] ?? "Unbekannter Fehler"
        };
      }
    } catch (e) {
      _log.e('Fehler bei Done.fetchDoneList(): $e');
      return {"success": false, "message": "Client-Fehler: $e"};
    }
  }
}