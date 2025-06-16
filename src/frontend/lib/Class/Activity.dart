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

}