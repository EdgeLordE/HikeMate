import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:HikeMate/Class/Mountain.dart';

import 'mountain_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  group('Mountain.SearchMountainByName', () {
    test('gibt bei erfolgreicher Suche success: true und Daten zurück', () async {
      final mountainName = 'Dachstein';
      final apiUrl =
          '${Mountain.baseUrl}/Berg?mountain_name=${Uri.encodeComponent(mountainName)}';
      final responsePayload = {
        "response": [
          {"name": "Hoher Dachstein", "height": 2995}
        ]
      };

      when(mockClient.get(
        Uri.parse(apiUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

      final result =
      await Mountain.SearchMountainByName(mountainName, mockClient);

      expect(result['success'], isTrue);
      expect(result['data'], isA<List>());
      expect(result['data'][0]['name'], 'Hoher Dachstein');
    });

    test('gibt bei nicht gefundenem Berg (404) success: false zurück', () async {
      final mountainName = 'NichtExistent';
      final apiUrl =
          '${Mountain.baseUrl}/Berg?mountain_name=${Uri.encodeComponent(mountainName)}';
      final responsePayload = {'message': 'Berg nicht gefunden'};

      when(mockClient.get(
        Uri.parse(apiUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 404));

      final result =
      await Mountain.SearchMountainByName(mountainName, mockClient);

      expect(result['success'], isFalse);
      expect(result['message'], 'Berg nicht gefunden');
    });

    test('gibt bei einem Serverfehler (500) success: false zurück', () async {
      final mountainName = 'Fehlerberg';
      final apiUrl =
          '${Mountain.baseUrl}/Berg?mountain_name=${Uri.encodeComponent(mountainName)}';
      final responsePayload = {'error': 'Interner Serverfehler'};

      when(mockClient.get(
        Uri.parse(apiUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 500));

      final result =
      await Mountain.SearchMountainByName(mountainName, mockClient);

      expect(result['success'], isFalse);
      expect(result['message'], 'Interner Serverfehler');
    });

    test('gibt bei einem Netzwerkfehler success: false zurück', () async {
      final mountainName = 'Netzwerkproblem';
      final apiUrl =
          '${Mountain.baseUrl}/Berg?mountain_name=${Uri.encodeComponent(mountainName)}';

      when(mockClient.get(
        Uri.parse(apiUrl),
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Verbindung fehlgeschlagen'));

      final result =
      await Mountain.SearchMountainByName(mountainName, mockClient);

      expect(result['success'], isFalse);
      expect(result['message'], contains('Netzwerkfehler oder Client-Fehler'));
    });
  });
}