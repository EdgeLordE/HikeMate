import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background/flutter_background.dart';
import 'TrackingStorage.dart';

class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;

  TrackingService._internal();

  bool isTracking = false;
  double totalDistance = 0.0;
  double totalAscent = 0.0;
  double altitude = 0.0;
  Duration duration = Duration.zero;

  LatLng? _previousPosition;
  double? _previousAltitude;
  Timer? _durationTimer;
  Timer? _altitudeTimer;
  StreamSubscription<Position>? _positionStream;
  final List<LatLng> path = [];

  final _onUpdate = StreamController<void>.broadcast();
  Stream<void> get onUpdate => _onUpdate.stream;

  final Stopwatch _stopwatch = Stopwatch();

  final trackingStorage = TrackingStorage();

  Future<void> start() async {
    if (isTracking) return;
    isTracking = true;

    await trackingStorage.requestNotificationPermission();
    await trackingStorage.enableBackgroundTracking();


    _stopwatch.start();

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      duration = _stopwatch.elapsed;
      _onUpdate.add(null);
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      final currentPosition = LatLng(position.latitude, position.longitude);
      if (position.accuracy > 25) return;
      if (position.speed != null && position.speed < 0.5) return;

      if (_previousPosition != null) {
        final distance = Distance().as(LengthUnit.Meter, _previousPosition!, currentPosition);
        if (distance > 3) {
          totalDistance += distance;
          path.add(currentPosition);
          _previousPosition = currentPosition;
        }
      } else {
        _previousPosition = currentPosition;
        path.add(currentPosition);
      }

      if (_previousAltitude != null && position.altitude > _previousAltitude!) {
        totalAscent += (position.altitude - _previousAltitude!);
      }

      _previousAltitude = position.altitude;
      altitude = position.altitude;
      _onUpdate.add(null);
    });
  }


  Future<void> stop() async {
    isTracking = false;
    _durationTimer?.cancel();
    _altitudeTimer?.cancel();
    await _positionStream?.cancel();

    await FlutterBackground.disableBackgroundExecution();

    _stopwatch.stop();
    _stopwatch.reset();

    _onUpdate.add(null);
  }

  Future<Position?> _checkAndRequestPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever)
      return null;

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void dispose() {
    _durationTimer?.cancel();
    _altitudeTimer?.cancel();
    _positionStream?.cancel();
    _onUpdate.close();
  }
}
