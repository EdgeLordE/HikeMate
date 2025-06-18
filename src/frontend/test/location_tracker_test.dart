
// 2 Test failen(start,stop) vermutlich weil es nicht funktioniert, dass der Mock die Positionen sendet. (wegen pc oder so idk)

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:latlong2/latlong.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:HikeMate/Class/LocationTracker.dart';
import 'package:HikeMate/Class/TrackingStorage.dart';

class MockTrackingStorage extends Mock implements TrackingStorage {
  @override
  Future<void> requestNotificationPermission() => (super.noSuchMethod(
    Invocation.method(#requestNotificationPermission, []),
    returnValue: Future.value(null),
    returnValueForMissingStub: Future.value(null),
  ) as Future<void>);

  @override
  Future<void> enableBackgroundTracking() => (super.noSuchMethod(
    Invocation.method(#enableBackgroundTracking, []),
    returnValue: Future.value(null),
    returnValueForMissingStub: Future.value(null),
  ) as Future<void>);

  @override
  Future<void> disableBackgroundTracking() => (super.noSuchMethod(
    Invocation.method(#disableBackgroundTracking, []),
    returnValue: Future.value(null),
    returnValueForMissingStub: Future.value(null),
  ) as Future<void>);
}

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {
  // Wichtig: Der Controller muss für jeden Test neu erstellt werden.
  // Dies wird durch die Instanziierung in setUp() sichergestellt.
  late StreamController<Position> _positionController;

  MockGeolocatorPlatform() {
    _positionController = StreamController<Position>.broadcast();
  }

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;

  @override
  Future<Position> getCurrentPosition(
      {LocationSettings? locationSettings}) async {
    return Position(
        latitude: 47.0,
        longitude: 8.0,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 450.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0);
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    return _positionController.stream;
  }

  void sendPosition(Position position) {
    if (!_positionController.isClosed) {
      _positionController.add(position);
    }
  }

  void close() {
    _positionController.close();
  }
}

void main() {
  // Stellt eine saubere Testumgebung sicher
  TestWidgetsFlutterBinding.ensureInitialized();

  late TrackingService trackingService;
  late MockTrackingStorage mockTrackingStorage;
  late MockGeolocatorPlatform mockGeolocatorPlatform;

  Position createPosition(
      double lat, double lon, double alt, double speed, double acc) {
    return Position(
      latitude: lat,
      longitude: lon,
      timestamp: DateTime.now(),
      accuracy: acc,
      altitude: alt,
      altitudeAccuracy: 1.0,
      heading: 0.0,
      headingAccuracy: 1.0,
      speed: speed,
      speedAccuracy: 1.0,
    );
  }

  setUp(() {
    mockTrackingStorage = MockTrackingStorage();
    mockGeolocatorPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocatorPlatform;

    trackingService = TrackingService();
    trackingService.setTrackingStorage(mockTrackingStorage);

    when(mockTrackingStorage.requestNotificationPermission())
        .thenAnswer((_) async {});
    when(mockTrackingStorage.enableBackgroundTracking())
        .thenAnswer((_) async {});
    when(mockTrackingStorage.disableBackgroundTracking())
        .thenAnswer((_) async {});
  });

  tearDown(() {
    // Korrigierte Reihenfolge: Zuerst den Service beenden, der die Mocks
    // verwendet, dann die Mocks selbst aufräumen.
    trackingService.dispose();
    mockGeolocatorPlatform.close();
  });

  test('Initial state is correct', () {
    expect(trackingService.isTracking, isFalse);
    expect(trackingService.totalDistance, 0.0);
    expect(trackingService.totalAscent, 0.0);
    expect(trackingService.path, isEmpty);
    expect(trackingService.duration, Duration.zero);
  });

  test('start() begins tracking and processes positions', () async {
    await trackingService.start();

    expect(trackingService.isTracking, isTrue);
    verify(mockTrackingStorage.enableBackgroundTracking()).called(1);

    final pos1 = createPosition(47.0, 8.0, 500.0, 5.0, 10.0);
    mockGeolocatorPlatform.sendPosition(pos1);
    await Future.delayed(Duration.zero);

    expect(trackingService.path.length, 1);
    expect(trackingService.altitude, 500.0);

    final pos2 = createPosition(47.0001, 8.0, 510.0, 5.0, 10.0);
    mockGeolocatorPlatform.sendPosition(pos2);
    await Future.delayed(Duration.zero);

    expect(trackingService.path.length, 2);
    expect(trackingService.totalDistance, greaterThan(10.0));
    expect(trackingService.totalAscent, 10.0);
  });

  test('stop() ends tracking and resets data', () async {
    await trackingService.start();
    final pos1 = createPosition(47.0, 8.0, 500.0, 5.0, 10.0);
    mockGeolocatorPlatform.sendPosition(pos1);
    await Future.delayed(Duration.zero);

    await trackingService.stop();

    expect(trackingService.isTracking, isFalse);
    expect(trackingService.totalDistance, 0.0);
    expect(trackingService.totalAscent, 0.0);
    expect(trackingService.path, isEmpty);
    // Dieser Verify-Aufruf funktioniert, sobald der App-Code angepasst wurde.
    verify(mockTrackingStorage.disableBackgroundTracking()).called(1);
  });

  test('dispose() cancels streams and timers', () async {
    await trackingService.start();
    expect(() => trackingService.dispose(), returnsNormally);
  });
}