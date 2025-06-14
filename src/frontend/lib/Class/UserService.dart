import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'User.dart';
import '../Pages/LoginPage.dart';

class UserService {
  static const String baseUrl = "http://193.141.60.63:8080";

  static Future<void> logout(BuildContext context) async {
    User.clearUser();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }


  static Future<bool> changeUsername(String oldUsername, String newUsername) async {
    final url = Uri.parse("$baseUrl/ChnageUsername");
    debugPrint('changeUsername() URL: $url');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Username": oldUsername,
          "NewUsername": newUsername,
        }),
      );
      debugPrint('changeUsername() status: ${response.statusCode}');
      debugPrint('changeUsername() body:   ${response.body}');
      if (response.statusCode == 200) {
        User.username = newUsername;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fehler beim Benutzernamen ändern: $e');
      return false;
    }
  }

  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    final url = Uri.parse("$baseUrl/ChangePassword");
    debugPrint('changePassword() URL: $url');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UserID": User.id,
          "Username": User.username,
          "OldPassword": oldPassword,
          "NewPassword": newPassword,
        }),
      );
      debugPrint('changePassword() status: ${response.statusCode}');
      debugPrint('changePassword() body:   ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Fehler beim Passwort ändern: $e');
      return false;
    }
  }
}
