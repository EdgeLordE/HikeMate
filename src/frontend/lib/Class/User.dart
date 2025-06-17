import 'dart:convert';
import 'package:flutter/material.dart'; // Hinzugefügt für BuildContext und Navigator
import 'package:http/http.dart' as http;
import '../Pages/LoginPage.dart'; // Hinzugefügt für LoginPage

class User {
  static int _id = 0;
  static String _firstName = "";
  static String _lastName = "";
  static String _username = "";

  static const String baseUrl = "http://193.141.60.63:8080"; // Basis-URL hierher verschoben

  static int get id => _id;
  static String get firstName => _firstName;
  static String get lastName => _lastName;
  static String get username => _username;

  static set id(int value) => _id = value;
  static set firstName(String value) => _firstName = value;
  static set lastName(String value) => _lastName = value;
  static set username(String value) => _username = value;

  static void setUser(int id, String firstName, String lastName, String username) {
    User._id = id;
    User._firstName = firstName;
    User._lastName = lastName;
    User._username = username;
  }

  static void clearUser() {
    _id = 0;
    _firstName = "";
    _lastName = "";
    _username = "";
  }

  static Future<Map<String, dynamic>> login_User(String username, String password) async {
    const String apiUrl = "$baseUrl/Login"; // baseUrl verwenden

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Username": username, "Password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setUser(data["UserID"], data["FirstName"], data["LastName"], username);
        return {"success": true, "message": "Login erfolgreich"};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error["error"]};
      }
    } catch (e) {
      return {"success": false, "message": "Fehler: $e"};
    }
  }

  static Future<Map<String, dynamic>> register_User(String firstName, String lastName, String username, String password) async {
    const String apiUrl = "$baseUrl/Registrieren"; // baseUrl verwenden

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Username": username, "Password": password, "FirstName": firstName, "LastName": lastName}),
      );

      if (response.statusCode == 200) {
        // Nach erfolgreicher Registrierung den Benutzer nicht automatisch einloggen oder User-Daten setzen,
        // das sollte der Login-Flow übernehmen.
        return {"success": true, "message": "Registrierung erfolgreich"};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error["error"]};
      }
    } catch (e) {
      return {"success": false, "message": "Fehler: $e"};
    }
  }

  static Future<void> logout(BuildContext context) async {
    clearUser(); // Ruft die clearUser Methode dieser Klasse auf
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  static Future<bool> changeUsername(String oldUsername, String newUsername) async {
    final url = Uri.parse("$baseUrl/ChangeUsername"); // Korrigierter Endpunktname, falls nötig
    debugPrint('User.changeUsername() URL: $url');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Username": oldUsername, // oldUsername wird vom Aufrufer übergeben
          "NewUsername": newUsername,
        }),
      );
      debugPrint('User.changeUsername() status: ${response.statusCode}');
      debugPrint('User.changeUsername() body:   ${response.body}');
      if (response.statusCode == 200) {
        User.username = newUsername; // Aktualisiert den statischen Benutzernamen
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
    debugPrint('User.changePassword() URL: $url');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          // "UserID": User.id, // UserID wird im Backend nicht erwartet laut Swagger
          "Username": User.username, // Den aktuellen Benutzernamen verwenden
          "OldPassword": oldPassword,
          "NewPassword": newPassword,
        }),
      );
      debugPrint('User.changePassword() status: ${response.statusCode}');
      debugPrint('User.changePassword() body:   ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Fehler beim Passwort ändern: $e');
      return false;
    }
  }

  static Future<String?> loadPhoneNumber() async {
    final url = Uri.parse('$baseUrl/User/phone?UserID=${User.id}');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      debugPrint('User.loadPhoneNumber() status: ${response.statusCode}');
      debugPrint('User.loadPhoneNumber() body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ContactNumber'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Fehler beim Laden der Telefonnummer: $e');
      return null;
    }
  }

  static Future<bool> savePhoneNumber(String phone) async {
    final url = Uri.parse('$baseUrl/User/phone');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "UserID": User.id,
          "ContactNumber": phone,
        }),
      );
      debugPrint('User.savePhoneNumber() status: ${response.statusCode}');
      debugPrint('User.savePhoneNumber() body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Fehler beim Speichern der Telefonnummer: $e');
      return false;
    }
  }
}