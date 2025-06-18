import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:HikeMate/Class/TrackingStorage.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrackingStorage Tests', () {
    late TrackingStorage trackingStorage;
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      trackingStorage = TrackingStorage();
    });

    test('sollte Tracking-Daten korrekt speichern und laden', () async {
      final path = [LatLng(47.0, 15.0), LatLng(47.1, 15.1)];
      const totalDistance = 1234.5;
      const totalAscent = 56.7;

      await trackingStorage.saveTrackingData(totalDistance, totalAscent, path);
      final loadedData = await trackingStorage.loadTrackingData();

      expect(loadedData['totalDistance'], totalDistance);
      expect(loadedData['totalAscent'], totalAscent);
      expect(loadedData['path'], isA<List<LatLng>>());
      expect(loadedData['path'].length, 2);
      expect(loadedData['path'][0].latitude, 47.0);
    });

    test('sollte eine leere Liste zurückgeben, wenn kein Pfad gespeichert ist', () async {
      final loadedData = await trackingStorage.loadTrackingData();

      expect(loadedData['totalDistance'], 0.0);
      expect(loadedData['totalAscent'], 0.0);
      expect(loadedData['path'], isEmpty);
    });

    test('sollte Tracking-Dauer korrekt speichern und laden', () async {
      const duration = Duration(minutes: 10, seconds: 30);
      await trackingStorage.saveTrackingDuration(duration);
      final loadedDuration = await trackingStorage.loadTrackingDuration();

      expect(loadedDuration, duration);
    });

    test('sollte Höhe korrekt speichern', () async {
      await trackingStorage.saveAltitude(1500.0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('altitude'), 1500.0);
    });

    test('sollte Tracking-Status korrekt speichern und laden', () async {
      await trackingStorage.saveTrackingState(true);
      bool isTracking = await trackingStorage.loadTrackingState();
      expect(isTracking, isTrue);

      await trackingStorage.saveTrackingState(false);
      isTracking = await trackingStorage.loadTrackingState();
      expect(isTracking, isFalse);
    });

    test('sollte den Standard-Tracking-Status (false) laden, wenn nichts gesetzt ist', () async {
      final isTracking = await trackingStorage.loadTrackingState();
      expect(isTracking, isFalse);
    });

    test('wasTrackingActive sollte den letzten Tracking-Status zurückgeben', () async {
      SharedPreferences.setMockInitialValues({'isTracking': true});
      final wasActive = await trackingStorage.wasTrackingActive();
      expect(wasActive, isTrue);
    });
  });
}