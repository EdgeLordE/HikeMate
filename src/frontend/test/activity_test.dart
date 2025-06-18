import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:HikeMate/Class/Activity.dart';
import 'package:HikeMate/Class/User.dart';

import 'activity_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  group('Activity.fetchActivitiesByUserId', () {
    const userId = 1;
    final url = Uri.parse('${User.baseUrl}/Aktivitaet?user_id=$userId');

    test('gibt bei erfolgreichem Abruf eine Liste von Aktivitäten zurück', () async {
      final responsePayload = {
        "activities": [
          {"id": 1, "name": "Wanderung zum Gipfel"},
          {"id": 2, "name": "Spaziergang am See"}
        ]
      };

      when(mockClient.get(
        url,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

      final result = await Activity.fetchActivitiesByUserId(userId, mockClient);

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['name'], "Wanderung zum Gipfel");
    });

    test('gibt eine leere Liste bei einem Serverfehler zurück', () async {
      when(mockClient.get(
        url,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Serverfehler', 500));

      final result = await Activity.fetchActivitiesByUserId(userId, mockClient);

      expect(result, isEmpty);
    });

    test('gibt eine leere Liste bei einem Netzwerkfehler zurück', () async {
      when(mockClient.get(
        url,
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Netzwerkproblem'));

      final result = await Activity.fetchActivitiesByUserId(userId, mockClient);

      expect(result, isEmpty);
    });
  });
}