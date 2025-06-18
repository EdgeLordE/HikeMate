import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Logging.dart';
import 'User.dart';

/// Klasse für die Verwaltung von erledigten Bergen in der HikeMate App
/// 
/// Diese Klasse stellt Methoden zur Verfügung, um zu prüfen welche Berge
/// ein Benutzer bereits erwandert hat, neue Berge als "erledigt" zu markieren
/// und die Liste der erledigten Berge zu verwalten.
class Done {
  /// Logger für diese Klasse - wird für alle Log-Nachrichten verwendet
  static final _log = LoggingService();
  
  /// Basis-URL für alle API-Aufrufe, übernommen von der User-Klasse
  static const String _baseUrl = User.baseUrl;

  /// Prüft ob ein bestimmter Berg für einen Benutzer bereits erledigt ist
  /// 
  /// Diese Methode verwendet den detaillierten "/check" Endpoint und
  /// liefert umfangreichere Informationen zurück.
  /// 
  /// [userId] - Die ID des Benutzers
  /// [mountainId] - Die ID des Berges, der geprüft werden soll
  /// 
  /// Rückgabe: true wenn der Berg erledigt ist, false wenn nicht oder bei Fehlern
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
      return false;    }
  }

  /// Einfache Prüfung ob ein Berg für einen Benutzer erledigt ist
  /// 
  /// Diese Methode ist eine vereinfachte Version von isMountainDone()
  /// und verwendet den "/is_done" Endpoint für schnellere Abfragen.
  /// 
  /// [userId] - Die ID des Benutzers
  /// [mountainId] - Die ID des Berges, der geprüft werden soll
  /// 
  /// Rückgabe: true wenn der Berg erledigt ist, false wenn nicht oder bei Fehlern
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
      return false;    }
  }

  /// Fügt einen Berg zur Liste der erledigten Berge hinzu
  /// 
  /// Diese Methode sendet eine POST-Anfrage an das Backend um einen
  /// Berg als "erledigt" für einen bestimmten Benutzer zu markieren.
  /// 
  /// [userId] - Die ID des Benutzers, der den Berg erledigt hat
  /// [mountainId] - Die ID des Berges, der als erledigt markiert werden soll
  /// 
  /// Rückgabe: Map mit "success" (bool) und optional "message" (String)
  /// Bei Erfolg: {"success": true}
  /// Bei Fehler: {"success": false, "message": "Fehlerbeschreibung"}
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
      return {"success": false, "message": "Client-Fehler: $e"};    }
  }

  /// Löscht einen Eintrag aus der Liste der erledigten Berge
  /// 
  /// Diese Methode sendet eine DELETE-Anfrage an das Backend um einen
  /// Berg wieder aus der "Erledigt"-Liste zu entfernen.
  /// 
  /// [doneId] - Die eindeutige ID des Done-Eintrags, der gelöscht werden soll
  /// [userId] - Die ID des Benutzers (für Berechtigung)
  /// 
  /// Rückgabe: Map mit "success" (bool) und "message" (String)
  /// Bei Erfolg: {"success": true, "message": "Erfolgsmeldung"}
  /// Bei Fehler: {"success": false, "message": "Fehlerbeschreibung"}
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
      return {"success": false, "message": "Client-Fehler: $e"};    }
  }

  /// Lädt die komplette Liste aller erledigten Berge für einen Benutzer
  /// 
  /// Diese Methode holt alle Berge, die ein Benutzer als erledigt markiert hat,
  /// vom Backend und gibt sie als strukturierte Daten zurück.
  /// 
  /// [userId] - Die ID des Benutzers, dessen Erledigt-Liste abgerufen werden soll
  /// 
  /// Rückgabe: Map mit "success" (bool) und optional "data" oder "message"
  /// Bei Erfolg: {"success": true, "data": [Liste der erledigten Berge]}
  /// Bei Fehler: {"success": false, "message": "Fehlerbeschreibung"}
  /// 
  /// Die "data" enthält eine Liste von Maps, wobei jede Map einen erledigten Berg
  /// mit Informationen wie Berg-ID, Name, Datum der Erledigung, etc. repräsentiert.
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