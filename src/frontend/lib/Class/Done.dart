/// Verwaltung erledigter Berge für die HikeMate App
///
/// Diese Klasse verwaltet alle Operationen rund um als "erledigt"
/// markierte Berge. Benutzer können Berge als bewältigt markieren,
/// ihre Liste erledigter Berge abrufen und Einträge wieder entfernen.
///
/// Features:
/// - Berg als erledigt markieren
/// - Prüfung ob Berg bereits erledigt
/// - Liste aller erledigten Berge abrufen
/// - Erledigte Berge wieder entfernen
/// - HTTP-Client Integration für Backend-Kommunikation
///
/// Alle Methoden unterstützen Dependency Injection für Tests
/// und bieten umfassendes Logging der API-Operationen.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Logging.dart';
import 'User.dart';

/// Statische Klasse für die Verwaltung erledigter Berge
class Done {
  /// Logger-Instanz für diese Klasse
  static final _log = LoggingService();

  /// Basis-URL für API-Aufrufe (von User-Klasse)
  static const String _baseUrl = User.baseUrl;

  /// Prüft ob ein Berg für einen Benutzer bereits als erledigt markiert ist
  ///
  /// [userId] - ID des Benutzers
  /// [mountainId] - ID des zu prüfenden Berges
  /// [client] - Optional: HTTP-Client für Tests (Dependency Injection)
  ///
  /// Returns: true wenn Berg erledigt, false sonst
  static Future<bool> isMountainDone(int userId, int mountainId,
      [http.Client? client]) async {
    final httpClient = client ?? http.Client();
    _log.i('Prüfe, ob Berg $mountainId für User $userId erledigt ist.');
    final url = Uri.parse(
        '$_baseUrl/DoneBerg/check?UserID=$userId&MountainID=$mountainId');
    try {
      final response =
      await httpClient.get(url, headers: {'Accept': 'application/json'});
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
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  /// Alternative einfache Prüfung ob Berg erledigt ist
  ///
  /// [userId] - ID des Benutzers
  /// [mountainId] - ID des zu prüfenden Berges
  /// [client] - Optional: HTTP-Client für Tests
  ///
  /// Returns: true wenn Berg erledigt, false sonst
  ///
  /// Nutzt vereinfachten API-Endpunkt für bessere Performance
  static Future<bool> isMountainDoneSimple(int userId, int mountainId,
      [http.Client? client]) async {
    final httpClient = client ?? http.Client();
    _log.i(
        'Prüfe (einfach), ob Berg $mountainId für User $userId erledigt ist.');
    final url = Uri.parse(
        '$_baseUrl/DoneBerg/is_done?UserID=$userId&MountainID=$mountainId');
    try {
      final response =
      await httpClient.get(url, headers: {'Accept': 'application/json'});
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
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  /// Markiert einen Berg als erledigt für einen Benutzer
  ///
  /// [userId] - ID des Benutzers
  /// [mountainId] - ID des Berges der als erledigt markiert werden soll
  /// [client] - Optional: HTTP-Client für Tests
  ///
  /// Returns: Map mit success-Flag und message
  /// Bei Erfolg: {"success": true, "message": "..."}
  /// Bei Fehler: {"success": false, "message": "Fehlermeldung"}
  static Future<Map<String, dynamic>> addMountainToDone(
      int userId, int mountainId,
      [http.Client? client]) async {
    final httpClient = client ?? http.Client();
    _log.i('Füge Berg $mountainId für User $userId zu Erledigt hinzu.');
    final url = Uri.parse('$_baseUrl/DoneBerghinzufuegen');
    try {
      final response = await httpClient.post(
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
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  /// Entfernt einen erledigten Berg aus der Done-Liste eines Benutzers
  ///
  /// [doneId] - ID des zu löschenden Done-Eintrags
  /// [userId] - ID des Benutzers (für Autorisierung)
  /// [client] - Optional: HTTP-Client für Tests
  ///
  /// Returns: Map mit success-Flag und ggf. message
  /// Bei Erfolg: {"success": true}
  /// Bei Fehler: {"success": false, "message": "Fehlermeldung"}
  static Future<Map<String, dynamic>> deleteDone(int doneId, int userId,
      [http.Client? client]) async {
    final httpClient = client ?? http.Client();
    _log.i('Lösche Erledigt-Eintrag $doneId für User $userId.');
    // KORREKTUR: URL mit Query-Parametern verwenden, nicht mit Path-Parametern.
    final url = Uri.parse('$_baseUrl/Done?DoneID=$doneId&UserID=$userId');
    try {
      // KORREKTUR: DELETE-Methode ohne Body verwenden.
      final response =
      await httpClient.delete(url, headers: {'Accept': 'application/json'});

      _log.i('Done.deleteDone() status: ${response.statusCode}');
      _log.d('Done.deleteDone() body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _log.i('Erledigt-Eintrag erfolgreich gelöscht.');
        return {"success": true};
      } else {
        _log.w(
            'Fehler beim Löschen des Erledigt-Eintrags, Statuscode: ${response.statusCode}');
        try {
          final data = jsonDecode(response.body);
          return {
            "success": false,
            "message": data["error"] ?? data["message"] ?? "Unbekannter Fehler"
          };
        } catch (_) {
          return {"success": false, "message": response.body};
        }
      }
    } catch (e) {
      _log.e('Fehler bei Done.deleteDone(): $e');
      return {"success": false, "message": "Client-Fehler: $e"};
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  /// Ruft die vollständige Liste aller erledigten Berge eines Benutzers ab
  ///
  /// [userId] - ID des Benutzers dessen Done-Liste abgerufen werden soll
  /// [client] - Optional: HTTP-Client für Tests
  ///
  /// Returns: Map mit success-Flag und data-Array
  /// Bei Erfolg: {"success": true, "data": [Liste der erledigten Berge]}
  /// Bei Fehler: {"success": false, "message": "Fehlermeldung"}
  ///
  /// Die data-Liste enthält Objekte mit Berg-Informationen und Done-IDs
  static Future<Map<String, dynamic>> fetchDoneList(int userId,
      [http.Client? client]) async {
    final httpClient = client ?? http.Client();
    _log.i('Rufe Erledigt-Liste für User $userId ab.');
    final url = Uri.parse('$_baseUrl/Done?UserID=$userId');
    try {
      final response =
      await httpClient.get(url, headers: {'Accept': 'application/json'});
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
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}