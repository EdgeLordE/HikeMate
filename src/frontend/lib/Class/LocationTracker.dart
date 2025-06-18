/// GPS-Tracking Service für die HikeMate App
/// 
/// Diese Klasse implementiert einen Singleton-Service für kontinuierliches
/// GPS-Tracking während Wanderungen. Sie verwaltet Position, Entfernung,
/// Höhengewinn und Zeitdauer der Aktivität.
/// 
/// Features:
/// - Singleton Pattern für App-weite Verwendung
/// - Kontinuierliches GPS-Tracking im Hintergrund
/// - Berechnung von Distanz und Höhengewinn
/// - Persistente Speicherung der Tracking-Daten
/// - Stream-basierte Updates für UI-Komponenten
/// - Timer für Zeitdauer-Tracking
/// - Pfad-Aufzeichnung für Routenanzeige
/// 
/// Die Klasse unterstützt sowohl Vordergrund- als auch Hintergrund-Tracking
/// und bietet umfassendes Logging aller Operationen.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background/flutter_background.dart';
import 'Logging.dart';
import 'TrackingStorage.dart';

/// Singleton-Service für GPS-Tracking und Aktivitätsdatenerfassung
class TrackingService {
  /// Singleton-Instanz des TrackingService
  static final TrackingService _instance = TrackingService._internal();
  /// Factory Constructor für Singleton-Pattern
  factory TrackingService() => _instance;

  /// Logger-Instanz für diese Klasse
  final _log = LoggingService();

  /// Private Constructor für Singleton-Pattern
  TrackingService._internal() {
    _log.i('TrackingService initialisiert.');
  }

  /// Zeigt an ob gerade getrackt wird
  bool isTracking = false;
  /// Gesamtdistanz der aktuellen Aktivität in Metern
  double totalDistance = 0.0;
  /// Gesamter Höhengewinn in Metern
  double totalAscent = 0.0;
  /// Aktuelle Höhe in Metern
  double altitude = 0.0;
  /// Dauer der aktuellen Aktivität
  Duration duration = Duration.zero;

  /// Vorherige Position für Distanzberechnung
  LatLng? _previousPosition;
  /// Vorherige Höhe für Höhengewinn-Berechnung
  double? _previousAltitude;
  /// Timer für Dauer-Tracking
  Timer? _durationTimer;
  /// Timer für Höhen-Updates
  Timer? _altitudeTimer;
  /// Stream für kontinuierliche Positionsabfragen
  StreamSubscription<Position>? _positionStream;
  /// Liste aller Positionspunkte für Pfadanzeige
  final List<LatLng> path = [];

  /// Stream Controller für UI-Updates
  final _onUpdate = StreamController<void>.broadcast();
  /// Stream für UI-Updates bei Tracking-Änderungen
  Stream<void> get onUpdate => _onUpdate.stream;

  /// Stopwatch für präzise Zeitmessung
  final Stopwatch _stopwatch = Stopwatch();

  /// Storage-Service für persistente Datenspeicherung
  var trackingStorage = TrackingStorage();

  /// Setzt einen anderen TrackingStorage (für Tests)
  /// 
  /// [storage] - Alternative TrackingStorage-Implementierung
  @visibleForTesting
  void setTrackingStorage(TrackingStorage storage) {
    trackingStorage = storage;
  }

  Future<void> start() async {
    if (isTracking) {
      _log.w('Tracking wird bereits ausgeführt. Start-Anfrage ignoriert.');
      return;
    }
    _log.i('Starte Tracking-Service.');
    isTracking = true;

    _log.i(
        'Fordere Benachrichtigungsberechtigung an und aktiviere Hintergrund-Tracking.');
    await trackingStorage.requestNotificationPermission();
    await trackingStorage.enableBackgroundTracking();

    _stopwatch.start();
    _log.i('Stopwatch gestartet.');

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
      _log.d(
          'Neue Position empfangen: Lat=${position.latitude}, Lon=${position.longitude}, Alt=${position.altitude}, Acc=${position.accuracy}');
      final currentPosition = LatLng(position.latitude, position.longitude);
      if (position.accuracy > 25) {
        _log.w(
            'Position ignoriert wegen geringer Genauigkeit: ${position.accuracy}');
        return;
      }
      if (position.speed != null && position.speed! < 0.5) {
        _log.d(
            'Position ignoriert wegen geringer Geschwindigkeit: ${position.speed}');
        return;
      }

      if (_previousPosition != null) {
        final distance =
        const Distance().as(LengthUnit.Meter, _previousPosition!, currentPosition);
        if (distance > 3) {
          totalDistance += distance;
          path.add(currentPosition);
          _previousPosition = currentPosition;
          _log.d(
              'Distanz hinzugefügt: $distance m. Gesamtdistanz: $totalDistance m.');
        }
      } else {
        _log.i('Erste Position gesetzt.');
        _previousPosition = currentPosition;
        path.add(currentPosition);
      }

      if (_previousAltitude != null) {
        final altitudeDifference =
            position.altitude.round() - _previousAltitude!.round();
        if (altitudeDifference > 0) {
          totalAscent += altitudeDifference;
          _log.d(
              'Aufstieg hinzugefügt: $altitudeDifference m. Gesamtaufstieg: $totalAscent m.');
        }
      }

      _previousAltitude = position.altitude.roundToDouble();
      altitude = position.altitude.roundToDouble();
      _onUpdate.add(null);
    });
    _log.i('Positions-Stream-Listener gestartet.');
  }

  Future<void> stop() async {
    _log.i('Stoppe Tracking-Service.');
    isTracking = false;
    _durationTimer?.cancel();
    _altitudeTimer?.cancel();
    await _positionStream?.cancel();
    _log.d('Timer und Positions-Stream gestoppt.');

    await FlutterBackground.disableBackgroundExecution();
    _log.i('Hintergrundausführung deaktiviert.');

    _stopwatch.stop();
    _stopwatch.reset();
    _log.i('Stopwatch gestoppt und zurückgesetzt.');

    path.clear();
    _previousPosition = null;
    _previousAltitude = null;
    _log.i('Tracking-Daten zurückgesetzt.');

    _onUpdate.add(null);
  }

  Future<Position?> _checkAndRequestPermissions() async {
    _log.i('Prüfe Standortdienste und Berechtigungen.');
    if (!await Geolocator.isLocationServiceEnabled()) {
      _log.w('Standortdienste sind deaktiviert.');
      return null;
    }

    var permission = await Geolocator.checkPermission();
    _log.d('Aktueller Berechtigungsstatus: $permission');
    if (permission == LocationPermission.denied) {
      _log.i('Fordere Standortberechtigung an.');
      permission = await Geolocator.requestPermission();
      _log.i('Neuer Berechtigungsstatus: $permission');
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _log.e('Standortberechtigung verweigert.');
      return null;
    }

    _log.i('Standortberechtigung erteilt. Rufe aktuelle Position ab.');
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void dispose() {
    _log.i('TrackingService wird disposed.');
    _durationTimer?.cancel();
    _altitudeTimer?.cancel();
    _positionStream?.cancel();
    _onUpdate.close();
    _log.i('Alle Streams und Timer wurden geschlossen.');
  }
}