import 'dart:convert';
import 'package:http/http.dart' as http;
import 'User.dart';
import 'Logging.dart';

class Watchlist {
  static final _log = LoggingService();
  static const String _baseUrl = User.baseUrl;

  static Future<Map<String, dynamic>> addMountainToWatchlist(
      int userId, int mountainId) async {
    _log.i('Füge Berg $mountainId zur Watchlist für User $userId hinzu.');
    final String apiUrl = "$_baseUrl/PostWatchlist";
    _log.d('Watchlist.addMountainToWatchlist() URL: $apiUrl');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UserID": userId,
          "MountainID": mountainId,
        }),
      );
      _log.i(
          'Watchlist.addMountainToWatchlist() status: ${response.statusCode}');
      _log.d('Watchlist.addMountainToWatchlist() body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _log.i('Berg erfolgreich zur Watchlist hinzugefügt.');
        return {
          "success": true,
          "message": responseBody["message"] ??
              "Erfolgreich zur Watchlist hinzugefügt",
          "data": responseBody["response"]
        };
      } else {
        _log.w(
            'Fehler beim Hinzufügen zur Watchlist, Status: ${response.statusCode}');
        return {
          "success": false,
          "message":
          responseBody["error"] ?? responseBody["message"] ?? "Unbekannter Fehler"
        };
      }
    } catch (e) {
      _log.e('Fehler beim Hinzufügen zur Watchlist: $e');
      return {"success": false, "message": "Fehler: $e"};
    }
  }

  static Future<Map<String, dynamic>> removeMountainFromWatchlist(
      int userId, int mountainId) async {
    _log.i('Entferne Berg $mountainId von der Watchlist für User $userId.');
    final String apiUrl =
        "$_baseUrl/Watchlist/entry?UserID=$userId&MountainID=$mountainId";
    _log.d('Watchlist.removeMountainFromWatchlist() URL: $apiUrl');
    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      _log.i(
          'Watchlist.removeMountainFromWatchlist() status: ${response.statusCode}');
      _log.d('Watchlist.removeMountainFromWatchlist() body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _log.i('Berg erfolgreich von Watchlist entfernt.');
        return {
          "success": true,
          "message":
          responseBody["message"] ?? "Erfolgreich von Watchlist entfernt"
        };
      } else {
        _log.w(
            'Fehler beim Entfernen von der Watchlist, Status: ${response.statusCode}');
        return {
          "success": false,
          "message":
          responseBody["error"] ?? responseBody["message"] ?? "Unbekannter Fehler"
        };
      }
    } catch (e) {
      _log.e('Fehler beim Entfernen von der Watchlist: $e');
      return {"success": false, "message": "Fehler: $e"};
    }
  }

  static Future<Map<String, dynamic>> checkIfMountainIsOnWatchlist(
      int userId, int mountainId) async {
    _log.i('Prüfe, ob Berg $mountainId auf der Watchlist von User $userId ist.');
    final String apiUrl =
        "$_baseUrl/Watchlist/check?UserID=$userId&MountainID=$mountainId";
    _log.d('Watchlist.checkIfMountainIsOnWatchlist() URL: $apiUrl');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      );

      _log.i(
          'Watchlist.checkIfMountainIsOnWatchlist() status: ${response.statusCode}');
      _log.d('Watchlist.checkIfMountainIsOnWatchlist() body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody.containsKey("response") &&
            responseBody["response"] is Map &&
            responseBody["response"].containsKey("isOnWatchlist")) {
          _log.i('Watchlist-Status erfolgreich geprüft.');
          return {
            "success": true,
            "isOnWatchlist": responseBody["response"]["isOnWatchlist"]
          };
        } else {
          _log.w(
              'Watchlist.checkIfMountainIsOnWatchlist() 200 OK but unexpected response structure: ${response.body}');
          return {
            "success": false,
            "message": "Ungültige Erfolgsantwort vom Server."
          };
        }
      } else {
        _log.w(
            'Fehler beim Überprüfen des Watchlist-Status, Status: ${response.statusCode}');
        String errorMessage = "Fehler beim Überprüfen des Watchlist-Status";
        if (responseBody.containsKey("error") &&
            responseBody["error"] != null) {
          errorMessage = responseBody["error"].toString();
        } else if (responseBody.containsKey("message") &&
            responseBody["message"] != null) {
          errorMessage = responseBody["message"].toString();
        }
        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      _log.e('Client-seitiger Fehler beim Überprüfen des Watchlist-Status: $e');
      return {"success": false, "message": "Client-seitiger Fehler: $e"};
    }
  }

  static Future<Map<String, dynamic>> fetchWatchlist(int userId) async {
    _log.i('Rufe Watchlist für User $userId ab.');
    final String apiUrl = "$_baseUrl/Watchlist?UserID=$userId";
    _log.d('Watchlist.fetchWatchlist() URL: $apiUrl');
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      _log.i('Watchlist.fetchWatchlist() status: ${response.statusCode}');
      _log.d('Watchlist.fetchWatchlist() body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _log.i('Watchlist erfolgreich abgerufen.');
        return {"success": true, "data": responseBody["response"]};
      } else {
        _log.w(
            'Fehler beim Abrufen der Watchlist, Status: ${response.statusCode}');
        return {
          "success": false,
          "message":
          responseBody["error"] ?? "Fehler beim Abrufen der Watchlist"
        };
      }
    } catch (e) {
      _log.e('Fehler beim Abrufen der Watchlist: $e');
      return {"success": false, "message": "Fehler: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteWatchlistEntry(
      int watchlistId, int userId) async {
    _log.i('Lösche Watchlist-Eintrag $watchlistId für User $userId.');
    final String apiUrl =
        "$_baseUrl/DeleteWatchlist?WatchlistID=$watchlistId&UserID=$userId";
    _log.d('Watchlist.deleteWatchlistEntry() URL: $apiUrl');
    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      _log.i('Watchlist.deleteWatchlistEntry() status: ${response.statusCode}');
      _log.d('Watchlist.deleteWatchlistEntry() body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        _log.i('Watchlist-Eintrag erfolgreich gelöscht.');
        return {
          "success": true,
          "message": responseBody["message"] ??
              "Watchlist-Eintrag erfolgreich gelöscht"
        };
      } else if (response.statusCode == 204) {
        _log.i('Watchlist-Eintrag erfolgreich gelöscht (Status 204).');
        return {
          "success": true,
          "message": "Watchlist-Eintrag erfolgreich gelöscht"
        };
      } else {
        _log.w(
            'Fehler beim Löschen des Watchlist-Eintrags, Status: ${response.statusCode}');
        final responseBody = jsonDecode(response.body);
        return {
          "success": false,
          "message": responseBody["error"] ??
              "Fehler beim Löschen des Watchlist-Eintrags"
        };
      }
    } catch (e) {
      _log.e('Fehler beim Löschen des Watchlist-Eintrags: $e');
      return {"success": false, "message": "Fehler: $e"};
    }
  }
}