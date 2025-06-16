import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'User.dart';


class Activity{

  static Future<List<Map<String, dynamic>>> fetchActivitiesByUserId(int userId) async {
    final url = Uri.parse('${User.baseUrl}/Aktivitaet?user_id=$userId');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      debugPrint('Activity.fetchActivitiesByUserId() status: ${response.statusCode}');
      debugPrint('Activity.fetchActivitiesByUserId() body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['activities'] as List);
      }
      return [];
    } catch (e) {
      debugPrint('Fehler beim Laden der Aktivitäten: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> saveActivity({
    required int userId,
    required double distance,
    required int increase,
    required int duration,
    required String date,
  }) async {
    final url = Uri.parse('${User.baseUrl}/Aktivitaet');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "UserID": userId,
          "Distance": distance,
          "Increase": increase,
          "Duration": duration,
          "Date": date,
        }),
      );
      debugPrint('Activity.saveActivity() status: ${response.statusCode}');
      debugPrint('Activity.saveActivity() body: ${response.body}');
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {"success": true, "calories": data["Calories"]};
      } else {
        final data = jsonDecode(response.body);
        return {"success": false, "message": data["error"] ?? "Unbekannter Fehler"};
      }
    } catch (e) {
      debugPrint('Fehler beim Speichern der Aktivität: $e');
      return {"success": false, "message": "Fehler: $e"};
    }
  }
}