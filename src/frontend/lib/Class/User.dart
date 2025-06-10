import 'dart:convert';
import 'package:http/http.dart' as http;

class User{
  static int _id = 0;
  static String _firstName = "";
  static String _lastName = "";
  static String _username = "";

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
    const String apiUrl = "http://193.141.60.63:8080/Login";

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

  static Future<Map<String, dynamic>> register_User(String firstName, String lastName, String username, String password) async{
    const String apiUrl = "http://193.141.60.63:8080/Registrieren";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Username": username, "Password": password, "FirstName": firstName, "LastName": lastName}),
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

}