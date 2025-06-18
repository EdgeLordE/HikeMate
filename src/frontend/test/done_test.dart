import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:HikeMate/Class/Done.dart';
import 'package:HikeMate/Class/User.dart';

import 'done_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  const baseUrl = User.baseUrl;

  setUp(() {
    mockClient = MockClient();
  });

  group('Done.isMountainDone', () {
    const userId = 1;
    const mountainId = 10;
    final url =
    Uri.parse('$baseUrl/DoneBerg/check?UserID=$userId&MountainID=$mountainId');

    test('gibt true zurück, wenn der Berg als erledigt markiert ist', () async {
      when(mockClient.get(url, headers: anyNamed('headers'))).thenAnswer(
              (_) async =>
              http.Response('{"response": {"isDone": true}}', 200));

      final result = await Done.isMountainDone(userId, mountainId, mockClient);
      expect(result, isTrue);
    });

    test('gibt false zurück, wenn der Berg nicht als erledigt markiert ist',
            () async {
          when(mockClient.get(url, headers: anyNamed('headers'))).thenAnswer(
                  (_) async =>
                  http.Response('{"response": {"isDone": false}}', 200));

          final result = await Done.isMountainDone(userId, mountainId, mockClient);
          expect(result, isFalse);
        });

    test('gibt false bei einem Serverfehler zurück', () async {
      when(mockClient.get(url, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Serverfehler', 500));

      final result = await Done.isMountainDone(userId, mountainId, mockClient);
      expect(result, isFalse);
    });
  });

  group('Done.addMountainToDone', () {
    const userId = 1;
    const mountainId = 10;
    final url = Uri.parse('$baseUrl/DoneBerghinzufuegen');

    test('gibt success: true bei erfolgreichem Hinzufügen zurück', () async {
      when(mockClient.post(url,
          headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{}', 201));

      final result =
      await Done.addMountainToDone(userId, mountainId, mockClient);
      expect(result['success'], isTrue);
    });

    test('gibt success: false bei einem Fehler zurück', () async {
      when(mockClient.post(url,
          headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async =>
          http.Response('{"error": "Bereits vorhanden"}', 409));

      final result =
      await Done.addMountainToDone(userId, mountainId, mockClient);
      expect(result['success'], isFalse);
      expect(result['message'], 'Bereits vorhanden');
    });
  });

  group('Done.deleteDone', () {
    const userId = 1;
    const doneId = 5;
    final url = Uri.parse('$baseUrl/Done?DoneID=$doneId&UserID=$userId');

    test('gibt success: true bei erfolgreichem Löschen zurück', () async {
      when(mockClient.delete(url, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{}', 200));

      final result = await Done.deleteDone(doneId, userId, mockClient);
      expect(result['success'], isTrue);
    });

    test('gibt success: false bei einem Fehler zurück', () async {
      when(mockClient.delete(url, headers: anyNamed('headers'))).thenAnswer(
              (_) async => http.Response('{"error": "Nicht gefunden"}', 404));

      final result = await Done.deleteDone(doneId, userId, mockClient);
      expect(result['success'], isFalse);
      expect(result['message'], 'Nicht gefunden');
    });
  });

  group('Done.fetchDoneList', () {
    const userId = 1;
    final url = Uri.parse('$baseUrl/Done?UserID=$userId');

    test('gibt bei Erfolg eine Liste von erledigten Einträgen zurück', () async {
      final payload = {
        "data": [
          {"DoneID": 1, "MountainName": "Dachstein"}
        ]
      };
      when(mockClient.get(url, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(payload), 200));

      final result = await Done.fetchDoneList(userId, mockClient);
      expect(result['success'], isTrue);
      expect(result['data'], isA<List>());
      expect(result['data'][0]['MountainName'], 'Dachstein');
    });

    test('gibt bei einem Fehler success: false zurück', () async {
      when(mockClient.get(url, headers: anyNamed('headers'))).thenAnswer(
              (_) async => http.Response('{"error": "Serverfehler"}', 500));

      final result = await Done.fetchDoneList(userId, mockClient);
      expect(result['success'], isFalse);
      expect(result['message'], 'Serverfehler');
    });
  });
}