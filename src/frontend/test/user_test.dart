import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:HikeMate/Class/User.dart';

import 'user_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  const String baseUrl = User.baseUrl;

  setUp(() {
    mockClient = MockClient();
    User.clearUser();
  });

  group('User-Klasse Tests', () {
    group('login_User', () {
      test('gibt bei erfolgreichem Login success: true zurück', () async {
        final username = 'gaul';
        final password = 'gaul';
        final apiUrl = '$baseUrl/Login';
        final responsePayload = {
          "UserID": 1,
          "FirstName": "gaul",
          "LastName": "gauliger"
        };

        when(mockClient.post(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

        final result = await User.login_User(username, password, mockClient);

        expect(result['success'], isTrue);
        expect(result['message'], 'Login erfolgreich');
        expect(User.id, 1);
        expect(User.username, 'gaul');
      });

      test('gibt bei fehlerhaftem Login success: false zurück', () async {
        final username = 'TestUser';
        final password = 'wrongpassword';
        final apiUrl = '$baseUrl/Login';
        final responsePayload = {'error': 'Ungültige Anmeldeinformationen'};

        when(mockClient.post(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 401));

        final result = await User.login_User(username, password, mockClient);

        expect(result['success'], isFalse);
        expect(result['message'], 'Ungültige Anmeldeinformationen');
      });
    });

    group('register_User', () {
      test('gibt bei erfolgreicher Registrierung success: true zurück', () async {
        final apiUrl = '$baseUrl/Registrieren';
        final responsePayload = {"success": true};

        when(mockClient.post(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

        final result = await User.register_User('New', 'User', 'NewUser', 'pw123', mockClient);

        expect(result['success'], isTrue);
        expect(result['message'], 'Registrierung erfolgreich');
      });

      test('gibt bei einem Fehler success: false zurück', () async {
        final apiUrl = '$baseUrl/Registrieren';
        final responsePayload = {'error': 'Benutzername bereits vergeben'};

        when(mockClient.post(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 409));

        final result = await User.register_User('gaul', 'User', 'TestUser', 'pw123', mockClient);

        expect(result['success'], isFalse);
        expect(result['message'], 'Benutzername bereits vergeben');
      });
    });

    group('changeUsername', () {
      test('gibt bei Erfolg true zurück', () async {
        final apiUrl = '$baseUrl/ChangeUsername';
        when(mockClient.post(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('', 200));

        final result = await User.changeUsername('oldUser', 'newUser', mockClient);
        expect(result, isTrue);
        expect(User.username, 'newUser');
      });

      test('gibt bei Fehler false zurück', () async {
        final apiUrl = '$baseUrl/ChangeUsername';
        when(mockClient.post(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('', 400));

        final result = await User.changeUsername('oldUser', 'newUser', mockClient);
        expect(result, isFalse);
      });
    });

    group('changePassword', () {
      test('gibt bei Erfolg true zurück', () async {
        User.username = 'gaul';
        final apiUrl = '$baseUrl/ChangePassword';
        when(mockClient.post(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('', 200));

        final result = await User.changePassword('oldPw', 'newPw', mockClient);
        expect(result, isTrue);
      });
    });

    group('loadPhoneNumber', () {
      test('gibt bei Erfolg die Telefonnummer zurück', () async {
        User.id = 1;
        final apiUrl = '$baseUrl/User/phone?UserID=1';
        final responsePayload = {'ContactNumber': '123456789'};

        when(mockClient.get(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

        final result = await User.loadPhoneNumber(mockClient);
        expect(result, '123456789');
      });

      test('gibt bei Fehler null zurück', () async {
        User.id = 1;
        final apiUrl = '$baseUrl/User/phone?UserID=1';
        when(mockClient.get(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 404));

        final result = await User.loadPhoneNumber(mockClient);
        expect(result, isNull);
      });
    });

    group('savePhoneNumber', () {
      test('gibt bei Erfolg true zurück', () async {
        User.id = 1;
        final apiUrl = '$baseUrl/User/phone';
        when(mockClient.put(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('', 200));

        final result = await User.savePhoneNumber('123456789', mockClient);
        expect(result, isTrue);
      });
    });
  });
}