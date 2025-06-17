import 'dart:convert';
import 'package:flutter/material.dart'; // Für debugPrint
import 'package:http/http.dart' as http;
import 'User.dart'; // Um auf User.baseUrl und User.id zuzugreifen

class Watchlist {
  // Basis-URL von der User-Klasse übernehmen oder hier definieren, falls abweichend
  static const String _baseUrl = User.baseUrl;

  static Future<Map<String, dynamic>> addMountainToWatchlist(int userId, int mountainId) async {
    final String apiUrl = "$_baseUrl/PostWatchlist";
    debugPrint('Watchlist.addMountainToWatchlist() URL: $apiUrl');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UserID": userId,
          "MountainID": mountainId,
        }),
      );
      debugPrint('Watchlist.addMountainToWatchlist() status: ${response.statusCode}');
      debugPrint('Watchlist.addMountainToWatchlist() body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "message": responseBody["message"] ?? "Erfolgreich zur Watchlist hinzugefügt", "data": responseBody["response"]};
      } else {
        return {"success": false, "message": responseBody["error"] ?? responseBody["message"] ?? "Unbekannter Fehler"};
      }
    } catch (e) {
      debugPrint('Fehler beim Hinzufügen zur Watchlist: $e');
      return {"success": false, "message": "Fehler: $e"};
    }
  }

  static Future<Map<String, dynamic>> removeMountainFromWatchlist(int userId, int mountainId) async {
    final String apiUrl = "$_baseUrl/Watchlist";
    debugPrint('Watchlist.removeMountainFromWatchlist() URL: $apiUrl');
    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UserID": userId,
          "MountainID": mountainId,
        }),
      );
      debugPrint('Watchlist.removeMountainFromWatchlist() status: ${response.statusCode}');
      debugPrint('Watchlist.removeMountainFromWatchlist() body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": responseBody["message"] ?? "Erfolgreich von Watchlist entfernt"};
      } else {
        return {"success": false, "message": responseBody["error"] ?? responseBody["message"] ?? "Unbekannter Fehler"};
      }
    } catch (e) {
      debugPrint('Fehler beim Entfernen von der Watchlist: $e');
      return {"success": false, "message": "Fehler: $e"};
    }
  }


  static Future<Map<String, dynamic>> checkIfMountainIsOnWatchlist(int userId, int mountainId) async {
    final String apiUrl = "$_baseUrl/Watchlist/check?UserID=$userId&MountainID=$mountainId";
    debugPrint('Watchlist.checkIfMountainIsOnWatchlist() URL: $apiUrl');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      );

      debugPrint('Watchlist.checkIfMountainIsOnWatchlist() status: ${response.statusCode}');
      debugPrint('Watchlist.checkIfMountainIsOnWatchlist() body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody.containsKey("response") &&
            responseBody["response"] is Map &&
            responseBody["response"].containsKey("isOnWatchlist")) {
          return {"success": true, "isOnWatchlist": responseBody["response"]["isOnWatchlist"]};
        } else {
          debugPrint('Watchlist.checkIfMountainIsOnWatchlist() 200 OK but unexpected response structure: ${response.body}');
          return {"success": false, "message": "Ungültige Erfolgsantwort vom Server."};
        }
      } else {
        String errorMessage = "Fehler beim Überprüfen des Watchlist-Status";
        if (responseBody.containsKey("error") && responseBody["error"] != null) {
          errorMessage = responseBody["error"].toString();
        } else if (responseBody.containsKey("message") && responseBody["message"] != null) {
          errorMessage = responseBody["message"].toString();
        }
        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      debugPrint('Client-seitiger Fehler beim Überprüfen des Watchlist-Status: $e');
      return {"success": false, "message": "Client-seitiger Fehler: $e"};
    }
  }

  static Future<Map<String, dynamic>> fetchWatchlist(int userId) async {
    final String apiUrl = "$_baseUrl/Watchlist?UserID=$userId";
    debugPrint('Watchlist.fetchWatchlist() URL: $apiUrl');
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      debugPrint('Watchlist.fetchWatchlist() status: ${response.statusCode}');
      debugPrint('Watchlist.fetchWatchlist() body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": responseBody["response"]};
      } else {
        return {"success": false, "message": responseBody["error"] ?? "Fehler beim Abrufen der Watchlist"};
      }
    } catch (e) {
      return {"success": false, "message": "Fehler: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteWatchlistEntry(int watchlistId, int userId) async {
    final String apiUrl = "$_baseUrl/Watchlist/entry?WatchlistID=$watchlistId&UserID=$userId";
    debugPrint('Watchlist.deleteWatchlistEntry() URL: $apiUrl');
    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      debugPrint('Watchlist.deleteWatchlistEntry() status: ${response.statusCode}');
      debugPrint('Watchlist.deleteWatchlistEntry() body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {"success": true, "message": responseBody["message"] ?? "Watchlist-Eintrag erfolgreich gelöscht"};
      } else if (response.statusCode == 204) {
        return {"success": true, "message": "Watchlist-Eintrag erfolgreich gelöscht"};
      } else {
        final responseBody = jsonDecode(response.body);
        return {"success": false, "message": responseBody["error"] ?? "Fehler beim Löschen des Watchlist-Eintrags"};
      }
    } catch (e) {
      debugPrint('Fehler beim Löschen des Watchlist-Eintrags: $e');
      return {"success": false, "message": "Fehler: $e"};
    }
  }
}