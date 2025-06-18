import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background/flutter_background.dart';
import 'Logging.dart';
import 'TrackingStorage.dart';

/// Service für GPS-Tracking von Wanderungen in der HikeMate App
/// 
/// Diese Klasse implementiert ein Singleton-Pattern und verwaltet das
/// GPS-Tracking während Wanderungen. Sie misst Distanz, Höhenunterschiede,
/// Zeit und speichert den Wanderweg.
/// 
/// Hauptfunktionen:
/// - GPS-Position kontinuierlich verfolgen
/// - Distanz und Höhenmeter berechnen
/// - Zeit messen (Stopwatch)
/// - Hintergrund-Tracking ermöglichen
class TrackingService {
  /// Singleton-Instanz des TrackingService
  static final TrackingService _instance = TrackingService._internal();
  
  /// Factory Constructor für Singleton-Pattern
  factory TrackingService() => _instance;

  /// Logger für diese Klasse
  final _log = LoggingService();

  /// Privater Constructor für Singleton-Pattern
  TrackingService._internal() {
    _log.i('TrackingService initialisiert.');
  }

  /// Zeigt an ob gerade ein Tracking läuft
  bool isTracking = false;
  
  /// Gesamte zurückgelegte Distanz in Metern
  double totalDistance = 0.0;
  
  /// Gesamter Aufstieg in Metern (nur positive Höhenunterschiede)
  double totalAscent = 0.0;
  
  /// Aktuelle Höhe in Metern
  double altitude = 0.0;
  
  /// Verstrichene Zeit seit Start des Trackings
  Duration duration = Duration.zero;

  /// Vorherige GPS-Position für Distanzberechnung
  LatLng? _previousPosition;
  
  /// Vorherige Höhe für Aufstiegsberechnung
  double? _previousAltitude;
  
  /// Timer für die Zeitmessung (jede Sekunde)
  Timer? _durationTimer;
  
  /// Timer für Höhenmessungen
  Timer? _altitudeTimer;
  
  /// Stream für kontinuierliche GPS-Updates
  StreamSubscription<Position>? _positionStream;
  
  /// Liste aller GPS-Punkte des Wanderwegs
  final List<LatLng> path = [];

  /// Stream Controller für UI-Updates
  final _onUpdate = StreamController<void>.broadcast();
  
  /// Stream für UI-Updates - andere Widgets können darauf hören
  Stream<void> get onUpdate => _onUpdate.stream;

  /// Stopwatch für genaue Zeitmessung
  final Stopwatch _stopwatch = Stopwatch();

  /// Storage-Service für Benachrichtigungen und Hintergrund-Tracking
  final trackingStorage = TrackingStorage();

  /// Startet das GPS-Tracking
  /// 
  /// Diese Methode aktiviert das Hintergrund-Tracking, startet die Zeitmessung
  /// und beginnt mit der kontinuierlichen GPS-Positionserfassung.
  /// 
  /// Funktionen beim Start:
  /// - Berechtigungen für Hintergrund-Tracking anfordern
  /// - Stopwatch starten
  /// - GPS-Stream aktivieren
  /// - Timer für UI-Updates starten
  Future<void> start() async {
    if (isTracking) {
      _log.w('Tracking wird bereits ausgeführt. Start-Anfrage ignoriert.');
      return;
    }
    _log.i('Starte Tracking-Service.');
    isTracking = true;

    _log.i('Fordere Benachrichtigungsberechtigung an und aktiviere Hintergrund-Tracking.');
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
      _log.d('Neue Position empfangen: Lat=${position.latitude}, Lon=${position.longitude}, Alt=${position.altitude}, Acc=${position.accuracy}');
      final currentPosition = LatLng(position.latitude, position.longitude);
      if (position.accuracy > 25) {
        _log.w('Position ignoriert wegen geringer Genauigkeit: ${position.accuracy}');
        return;
      }
      if (position.speed != null && position.speed! < 0.5) {
        _log.d('Position ignoriert wegen geringer Geschwindigkeit: ${position.speed}');
        return;
      }

      if (_previousPosition != null) {
        final distance = Distance().as(LengthUnit.Meter, _previousPosition!, currentPosition);
        if (distance > 3) {
          totalDistance += distance;
          path.add(currentPosition);
          _previousPosition = currentPosition;
          _log.d('Distanz hinzugefügt: $distance m. Gesamtdistanz: $totalDistance m.');
        }
      } else {
        _log.i('Erste Position gesetzt.');
        _previousPosition = currentPosition;
        path.add(currentPosition);
      }

      if (_previousAltitude != null) {
        final altitudeDifference = position.altitude.round() - _previousAltitude!.round();
        if (altitudeDifference > 0) {
          totalAscent += altitudeDifference;
          _log.d('Aufstieg hinzugefügt: $altitudeDifference m. Gesamtaufstieg: $totalAscent m.');
        }
      }

      _previousAltitude = position.altitude.roundToDouble();
      altitude = position.altitude.roundToDouble();
      _onUpdate.add(null);
    });    _log.i('Positions-Stream-Listener gestartet.');
  }

  /// Stoppt das GPS-Tracking und setzt alle Werte zurück
  /// 
  /// Diese Methode beendet das Tracking vollständig:
  /// - Deaktiviert Hintergrund-Tracking
  /// - Stoppt alle Timer und GPS-Streams
  /// - Setzt Tracking-Daten zurück
  /// - Benachrichtigt UI über Updates
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
    _log.i('Tracking-Daten zurückgesetzt.');    _onUpdate.add(null);
  }

  /// Prüft Standort-Berechtigungen und fordert sie an falls nötig
  /// 
  /// Diese private Methode überprüft:
  /// - Ob Standortdienste aktiviert sind
  /// - Ob die App Standort-Berechtigung hat
  /// - Fordert Berechtigung an falls sie fehlt
  /// 
  /// Rückgabe: Aktuelle GPS-Position wenn erfolgreich, null bei Fehlern
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

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      _log.e('Standortberechtigung verweigert.');
      return null;
    }

    _log.i('Standortberechtigung erteilt. Rufe aktuelle Position ab.');    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// Räumt alle Ressourcen auf und schließt Streams
  /// 
  /// Diese Methode sollte aufgerufen werden wenn der TrackingService
  /// nicht mehr benötigt wird. Sie stoppt alle Timer und schließt
  /// alle Streams um Memory Leaks zu vermeiden.
  void dispose() {
    _log.i('TrackingService wird disposed.');
    _durationTimer?.cancel();
    _altitudeTimer?.cancel();
    _positionStream?.cancel();
    _onUpdate.close();
    _log.i('Alle Streams und Timer wurden geschlossen.');
  }
}