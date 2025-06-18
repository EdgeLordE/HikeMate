import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:HikeMate/Class/Watchlist.dart';
import 'package:HikeMate/Class/User.dart';

import 'watchlist_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  const String baseUrl = User.baseUrl;

  setUp(() {
    mockClient = MockClient();
  });

  group('Watchlist Tests', () {
    group('addMountainToWatchlist', () {
      test('gibt success true zurück, wenn erfolgreich', () async {
        final userId = 1;
        final mountainId = 10;
        final apiUrl = "$baseUrl/PostWatchlist";
        final responsePayload = {"success": true, "message": "Erfolgreich", "response": {}};

        when(mockClient.post(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 201));

        final result = await Watchlist.addMountainToWatchlist(userId, mountainId, mockClient);
        expect(result['success'], isTrue);
      });
    });

    group('removeMountainFromWatchlist', () {
      test('gibt success true zurück, wenn erfolgreich', () async {
        final userId = 1;
        final mountainId = 10;
        final apiUrl = "$baseUrl/Watchlist/entry?UserID=$userId&MountainID=$mountainId";
        final responsePayload = {"success": true, "message": "Erfolgreich entfernt"};

        when(mockClient.delete(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

        final result = await Watchlist.removeMountainFromWatchlist(userId, mountainId, mockClient);
        expect(result['success'], isTrue);
      });
    });

    group('checkIfMountainIsOnWatchlist', () {
      test('gibt isOnWatchlist true zurück, wenn auf der Watchlist', () async {
        final userId = 1;
        final mountainId = 10;
        final apiUrl = "$baseUrl/Watchlist/check?UserID=$userId&MountainID=$mountainId";
        final responsePayload = {"response": {"isOnWatchlist": true}};

        when(mockClient.get(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

        final result = await Watchlist.checkIfMountainIsOnWatchlist(userId, mountainId, mockClient);
        expect(result['success'], isTrue);
        expect(result['isOnWatchlist'], isTrue);
      });
    });

    group('fetchWatchlist', () {
      test('gibt Watchlist-Daten zurück, wenn erfolgreich', () async {
        final userId = 1;
        final apiUrl = "$baseUrl/Watchlist?UserID=$userId";
        final responsePayload = {"response": [{"id": 1, "name": "Berg"}]};

        when(mockClient.get(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

        final result = await Watchlist.fetchWatchlist(userId, mockClient);
        expect(result['success'], isTrue);
        expect(result['data'], isA<List>());
      });

      test('gibt success false zurück, wenn ein Fehler auftritt', () async {
        final userId = 1;
        final apiUrl = "$baseUrl/Watchlist?UserID=$userId";
        final responsePayload = {"error": "Nicht gefunden"};

        when(mockClient.get(
          Uri.parse(apiUrl),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 404));

        final result = await Watchlist.fetchWatchlist(userId, mockClient);
        expect(result['success'], isFalse);
        expect(result['message'], "Nicht gefunden");
      });
    });
  });
}