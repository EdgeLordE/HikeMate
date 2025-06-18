import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Pages/LoginPage.dart';
import 'Logging.dart';

/// Klasse für Benutzerverwaltung in der HikeMate App
/// 
/// Diese Klasse verwaltet alle benutzerbezogenen Funktionen wie
/// Login, Registrierung, Logout und Profil-Updates. Sie hält auch
/// die aktuellen Benutzerdaten im Speicher.
/// 
/// Hauptfunktionen:
/// - Benutzer-Authentifizierung (Login/Logout/Registrierung)
/// - Profildaten verwalten (Name, Benutzername, Telefon)
/// - Passwort und Benutzername ändern
class User {
  /// Logger für diese Klasse
  static final _log = LoggingService();

  /// Private Variablen für Benutzerdaten
  static int _id = 0;
  static String _firstName = "";
  static String _lastName = "";
  static String _username = "";

  /// Basis-URL für alle API-Aufrufe an das Backend
  static const String baseUrl = "http://193.141.60.63:8080";

  /// Getter für die Benutzerdaten
  static int get id => _id;
  static String get firstName => _firstName;
  static String get lastName => _lastName;
  static String get username => _username;

  /// Setter für die Benutzerdaten
  static set id(int value) => _id = value;
  static set firstName(String value) => _firstName = value;
  static set lastName(String value) => _lastName = value;
  static set username(String value) => _username = value;

  /// Setzt alle Benutzerdaten auf einmal
  /// 
  /// [id] - Eindeutige Benutzer-ID vom Backend
  /// [firstName] - Vorname des Benutzers
  /// [lastName] - Nachname des Benutzers  
  /// [username] - Benutzername für Login
  static void setUser(
      int id, String firstName, String lastName, String username) {
    _log.i('Setze Benutzer: ID=$id, Name="$firstName $lastName", Benutzername="$username"');
    User._id = id;
    User._firstName = firstName;
    User._lastName = lastName;    
    User._username = username;
  }

  /// Löscht alle Benutzerdaten (für Logout)
  static void clearUser() {
    _log.i('Benutzerdaten werden gelöscht.');
    _id = 0;
    _firstName = "";
    _lastName = "";    
    _username = "";
  }

  /// Meldet einen Benutzer am System an
  /// 
  /// [username] - Der Benutzername für den Login
  /// [password] - Das Passwort des Benutzers
  /// 
  /// Rückgabe: Map mit "success" (bool) und "message" (String)
  /// Bei Erfolg werden die Benutzerdaten automatisch gesetzt
  static Future<Map<String, dynamic>> login_User(
      String username, String password) async {
    _log.i('Login-Versuch für Benutzer "$username".');
    const String apiUrl = "$baseUrl/Login";

    try {
      final response = await http.post(
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
      return {"success": false, "message": "Fehler: $e"};    }
  }

  /// Registriert einen neuen Benutzer im System
  /// 
  /// [firstName] - Vorname des neuen Benutzers
  /// [lastName] - Nachname des neuen Benutzers
  /// [username] - Gewünschter Benutzername (muss eindeutig sein)
  /// [password] - Passwort für den neuen Account
  /// 
  /// Rückgabe: Map mit "success" (bool) und "message" (String)
  /// Bei Erfolg kann sich der Benutzer danach einloggen
  static Future<Map<String, dynamic>> register_User(String firstName,
      String lastName, String username, String password) async {
    _log.i('Registrierungsversuch für Benutzer "$username".');
    const String apiUrl = "$baseUrl/Registrieren";

    try {
      final response = await http.post(
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
      return {"success": false, "message": "Fehler: $e"};    }
  }

  /// Meldet den aktuellen Benutzer ab und navigiert zur Login-Seite
  /// 
  /// [context] - BuildContext für Navigation zwischen Seiten
  /// 
  /// Diese Methode löscht alle Benutzerdaten und leitet zur Login-Seite weiter
  static Future<void> logout(BuildContext context) async {
    _log.i('Benutzer wird ausgeloggt.');
    clearUser();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,    );
  }

  /// Ändert den Benutzernamen des aktuellen Benutzers
  /// 
  /// [oldUsername] - Der aktuelle Benutzername
  /// [newUsername] - Der gewünschte neue Benutzername
  /// 
  /// Rückgabe: true bei Erfolg, false bei Fehlern
  /// Bei Erfolg wird der neue Benutzername automatisch gesetzt
  static Future<bool> changeUsername(
      String oldUsername, String newUsername) async {
    _log.i(
        'Ändere Benutzernamen von "$oldUsername" zu "$newUsername".');
    final url = Uri.parse("$baseUrl/ChangeUsername");
    try {
      final response = await http.post(
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
      return false;    }
  }

  /// Ändert das Passwort des aktuellen Benutzers
  /// 
  /// [oldPassword] - Das aktuelle Passwort zur Verifikation
  /// [newPassword] - Das gewünschte neue Passwort
  /// 
  /// Rückgabe: true bei Erfolg, false bei Fehlern
  /// Das alte Passwort wird zur Sicherheit überprüft
  static Future<bool> changePassword(
      String oldPassword, String newPassword) async {
    _log.i('Ändere Passwort für Benutzer "${User.username}".');
    final url = Uri.parse("$baseUrl/ChangePassword");
    try {
      final response = await http.post(
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
      return false;    }
  }

  /// Lädt die Telefonnummer des aktuellen Benutzers
  /// 
  /// Rückgabe: String mit der Telefonnummer oder null wenn keine gespeichert ist
  /// Diese Methode wird für das Laden der Profildaten verwendet
  static Future<String?> loadPhoneNumber() async {
    _log.i('Lade Telefonnummer für User ID ${User.id}.');
    final url = Uri.parse('$baseUrl/User/phone?UserID=${User.id}');
    try {
      final response =
      await http.get(url, headers: {'Accept': 'application/json'});
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
      return null;    }
  }

  /// Speichert eine neue Telefonnummer für den aktuellen Benutzer
  /// 
  /// [phone] - Die neue Telefonnummer als String
  /// 
  /// Rückgabe: true bei Erfolg, false bei Fehlern
  /// Die Telefonnummer wird im Benutzerprofil gespeichert
  static Future<bool> savePhoneNumber(String phone) async {
    _log.i('Speichere Telefonnummer für User ID ${User.id}.');
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
    }
  }
}