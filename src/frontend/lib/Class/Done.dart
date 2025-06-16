import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'User.dart';

class Done {
  static const String _baseUrl = User.baseUrl;

  /// Prüft, ob ein Berg für einen User als erledigt markiert ist.
  static Future<bool> isMountainDone(int userId, int mountainId) async {
    final url = Uri.parse('$_baseUrl/DoneBerg/check?UserID=$userId&MountainID=$mountainId');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      debugPrint('Done.isMountainDone() status: ${response.statusCode}');
      debugPrint('Done.isMountainDone() body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] != null && data['response']['isDone'] != null) {
          return data['response']['isDone'] == true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Fehler bei Done.isMountainDone(): $e');
      return false;
    }
  }

  static Future<bool> isMountainDoneSimple(int userId, int mountainId) async {
    final url = Uri.parse('$_baseUrl/DoneBerg/is_done?UserID=$userId&MountainID=$mountainId');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      debugPrint('Done.isMountainDoneSimple() status: ${response.statusCode}');
      debugPrint('Done.isMountainDoneSimple() body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['isDone'] != null) {
          return data['isDone'] == true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Fehler bei Done.isMountainDoneSimple(): $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> addMountainToDone(int userId, int mountainId) async {
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
      debugPrint('Done.addMountainToDone() status: ${response.statusCode}');
      debugPrint('Done.addMountainToDone() body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data["error"] ?? data["message"] ?? "Unbekannter Fehler"
        };
      }
    } catch (e) {
      debugPrint('Fehler bei Done.addMountainToDone(): $e');
      return {"success": false, "message": "Client-Fehler: $e"};
    }
  }

}