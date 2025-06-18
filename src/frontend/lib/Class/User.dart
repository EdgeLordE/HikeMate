import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Pages/LoginPage.dart';
import 'Logging.dart';

class User {
  static final _log = LoggingService();

  static int _id = 0;
  static String _firstName = "";
  static String _lastName = "";
  static String _username = "";

  static const String baseUrl = "http://193.141.60.63:8080";

  static int get id => _id;
  static String get firstName => _firstName;
  static String get lastName => _lastName;
  static String get username => _username;

  static set id(int value) => _id = value;
  static set firstName(String value) => _firstName = value;
  static set lastName(String value) => _lastName = value;
  static set username(String value) => _username = value;

  static void setUser(
      int id, String firstName, String lastName, String username) {
    _log.i(
        'Setze Benutzer: ID=$id, Name="$firstName $lastName", Benutzername="$username"');
    User._id = id;
    User._firstName = firstName;
    User._lastName = lastName;
    User._username = username;
  }

  static void clearUser() {
    _log.i('Benutzerdaten werden gelöscht.');
    _id = 0;
    _firstName = "";
    _lastName = "";
    _username = "";
  }

  static Future<Map<String, dynamic>> login_User(
      String username, String password, [http.Client? client]) async {
    _log.i('Login-Versuch für Benutzer "$username".');
    const String apiUrl = "$baseUrl/Login";
    final httpClient = client ?? http.Client();

    try {
      final response = await httpClient.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Username": username, "Password": password}),
      );

      _log.i('User.login_User() status: ${response.statusCode}');
      _log.d('User.login_User() body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setUser(data["UserID"], data["FirstName"], data["LastName"], username);
        _log.i('Login erfolgreich für Benutzer "$username".');
        return {"success": true, "message": "Login erfolgreich"};
      } else {
        final error = jsonDecode(response.body);
        _log.w(
            'Login fehlgeschlagen für "$username", Status: ${response.statusCode}, Fehler: ${error["error"]}');
        return {"success": false, "message": error["error"]};
      }
    } catch (e) {
      _log.e('Fehler bei User.login_User(): $e');
      return {"success": false, "message": "Fehler: $e"};
    } finally {
      if (client == null) httpClient.close();
    }
  }

  static Future<Map<String, dynamic>> register_User(String firstName,
      String lastName, String username, String password, [http.Client? client]) async {
    _log.i('Registrierungsversuch für Benutzer "$username".');
    const String apiUrl = "$baseUrl/Registrieren";
    final httpClient = client ?? http.Client();

    try {
      final response = await httpClient.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Username": username,
          "Password": password,
          "FirstName": firstName,
          "LastName": lastName
        }),
      );

      _log.i('User.register_User() status: ${response.statusCode}');
      _log.d('User.register_User() body: ${response.body}');

      if (response.statusCode == 200) {
        _log.i('Registrierung erfolgreich für "$username".');
        return {"success": true, "message": "Registrierung erfolgreich"};
      } else {
        final error = jsonDecode(response.body);
        _log.w(
            'Registrierung fehlgeschlagen für "$username", Status: ${response.statusCode}, Fehler: ${error["error"]}');
        return {"success": false, "message": error["error"]};
      }
    } catch (e) {
      _log.e('Fehler bei User.register_User(): $e');
      return {"success": false, "message": "Fehler: $e"};
    } finally {
      if (client == null) httpClient.close();
    }
  }

  static Future<void> logout(BuildContext context) async {
    _log.i('Benutzer wird ausgeloggt.');
    clearUser();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  static Future<bool> changeUsername(
      String oldUsername, String newUsername, [http.Client? client]) async {
    _log.i(
        'Ändere Benutzernamen von "$oldUsername" zu "$newUsername".');
    final url = Uri.parse("$baseUrl/ChangeUsername");
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Username": oldUsername,
          "NewUsername": newUsername,
        }),
      );
      _log.i('User.changeUsername() status: ${response.statusCode}');
      _log.d('User.changeUsername() body:   ${response.body}');
      if (response.statusCode == 200) {
        User.username = newUsername;
        _log.i('Benutzername erfolgreich geändert.');
        return true;
      }
      _log.w(
          'Benutzernamenänderung fehlgeschlagen, Status: ${response.statusCode}');
      return false;
    } catch (e) {
      _log.e('Fehler beim Benutzernamen ändern: $e');
      return false;
    } finally {
      if (client == null) httpClient.close();
    }
  }

  static Future<bool> changePassword(
      String oldPassword, String newPassword, [http.Client? client]) async {
    _log.i('Ändere Passwort für Benutzer "${User.username}".');
    final url = Uri.parse("$baseUrl/ChangePassword");
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Username": User.username,
          "OldPassword": oldPassword,
          "NewPassword": newPassword,
        }),
      );
      _log.i('User.changePassword() status: ${response.statusCode}');
      _log.d('User.changePassword() body:   ${response.body}');
      if (response.statusCode == 200) {
        _log.i('Passwort erfolgreich geändert.');
        return true;
      }
      _log.w('Passwortänderung fehlgeschlagen, Status: ${response.statusCode}');
      return false;
    } catch (e) {
      _log.e('Fehler beim Passwort ändern: $e');
      return false;
    } finally {
      if (client == null) httpClient.close();
    }
  }

  static Future<String?> loadPhoneNumber([http.Client? client]) async {
    _log.i('Lade Telefonnummer für User ID ${User.id}.');
    final url = Uri.parse('$baseUrl/User/phone?UserID=${User.id}');
    final httpClient = client ?? http.Client();
    try {
      final response =
      await httpClient.get(url, headers: {'Accept': 'application/json'});
      _log.i('User.loadPhoneNumber() status: ${response.statusCode}');
      _log.d('User.loadPhoneNumber() body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _log.i('Telefonnummer erfolgreich geladen.');
        return data['ContactNumber'] as String?;
      }
      _log.w(
          'Laden der Telefonnummer fehlgeschlagen, Status: ${response.statusCode}');
      return null;
    } catch (e) {
      _log.e('Fehler beim Laden der Telefonnummer: $e');
      return null;
    } finally {
      if (client == null) httpClient.close();
    }
  }

  static Future<bool> savePhoneNumber(String phone, [http.Client? client]) async {
    _log.i('Speichere Telefonnummer für User ID ${User.id}.');
    final url = Uri.parse('$baseUrl/User/phone');
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "UserID": User.id,
          "ContactNumber": phone,
        }),
      );
      _log.i('User.savePhoneNumber() status: ${response.statusCode}');
      _log.d('User.savePhoneNumber() body: ${response.body}');
      if (response.statusCode == 200) {
        _log.i('Telefonnummer erfolgreich gespeichert.');
        return true;
      }
      _log.w(
          'Speichern der Telefonnummer fehlgeschlagen, Status: ${response.statusCode}');
      return false;
    } catch (e) {
      _log.e('Fehler beim Speichern der Telefonnummer: $e');
      return false;
    } finally {
      if (client == null) httpClient.close();
    }
  }
}