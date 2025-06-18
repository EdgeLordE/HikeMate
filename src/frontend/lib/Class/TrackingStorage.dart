import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Logging.dart';

/// Service für die Speicherung von Tracking-Daten
/// 
/// Diese Klasse verwaltet die Speicherung und das Laden von GPS-Tracking-Daten
/// zwischen App-Sessions. Sie verwendet SharedPreferences für lokale Datenspeicherung
/// und verwaltet Berechtigungen für Hintergrund-Tracking.
/// 
/// Hauptfunktionen:
/// - Tracking-Daten zwischen App-Starts speichern/laden
/// - Hintergrund-Tracking mit Benachrichtigungen ermöglichen
/// - GPS-Pfade und Statistiken persistent speichern
class TrackingStorage {
  /// Logger für diese Klasse
  final _log = LoggingService();

  /// Speichert die wichtigsten Tracking-Daten persistent
  /// 
  /// [totalDistance] - Gesamte zurückgelegte Distanz in Metern
  /// [totalAscent] - Gesamter Aufstieg in Metern
  /// [path] - Liste aller GPS-Punkte des Wanderwegs
  Future<void> saveTrackingData(
      double totalDistance, double totalAscent, List<LatLng> path) async {
    _log.i(
        'Speichere Tracking-Daten: Distanz=$totalDistance, Aufstieg=$totalAscent, Pfadlänge=${path.length}');
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('totalDistance', totalDistance);
    prefs.setDouble('totalAscent', totalAscent);
    prefs.setString('path',        jsonEncode(path.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()));
  }

  /// Speichert die verstrichene Tracking-Zeit
  /// [duration] - Die Dauer des aktuellen Trackings
  Future<void> saveTrackingDuration(Duration duration) async {
    _log.i('Speichere Tracking-Dauer: ${duration.inSeconds}s');
    final prefs = await SharedPreferences.getInstance();    prefs.setInt('duration', duration.inSeconds);
  }

  /// Lädt die gespeicherte Tracking-Dauer
  /// Rückgabe: Duration-Objekt mit der gespeicherten Zeit
  Future<Duration> loadTrackingDuration() async {
    _log.i('Lade Tracking-Dauer.');
    final prefs = await SharedPreferences.getInstance();    return Duration(seconds: prefs.getInt('duration') ?? 0);
  }

  /// Speichert die aktuelle Höhe
  /// [altitude] - Aktuelle Höhe in Metern
  Future<void> saveAltitude(double altitude) async {
    _log.i('Speichere Höhe: $altitude');
    final prefs = await SharedPreferences.getInstance();    prefs.setDouble('altitude', altitude);
  }

  /// Speichert den aktuellen Tracking-Status
  /// [isTracking] - true wenn Tracking aktiv ist, false wenn nicht
  Future<void> saveTrackingState(bool isTracking) async {
    _log.i('Speichere Tracking-Status: $isTracking');
    final prefs = await SharedPreferences.getInstance();    prefs.setBool('isTracking', isTracking);
  }

  /// Lädt den gespeicherten Tracking-Status
  /// Rückgabe: true wenn Tracking beim letzten Mal aktiv war
  Future<bool> loadTrackingState() async {
    _log.i('Lade Tracking-Status.');
    final prefs = await SharedPreferences.getInstance();    return prefs.getBool('isTracking') ?? false;
  }

  /// Lädt alle gespeicherten Tracking-Daten
  /// 
  /// Rückgabe: Map mit 'totalDistance', 'totalAscent' und 'path'
  /// Wird verwendet um ein unterbrochenes Tracking fortzusetzen
  Future<Map<String, dynamic>> loadTrackingData() async {
    _log.i('Lade Tracking-Daten.');
    final prefs = await SharedPreferences.getInstance();
    final totalDistance = prefs.getDouble('totalDistance') ?? 0.0;
    final totalAscent = prefs.getDouble('totalAscent') ?? 0.0;
    final pathString = prefs.getString('path');
    final path = pathString != null
        ? (jsonDecode(pathString) as List)
        .map((p) => LatLng(p['lat'], p['lng']))
        .toList()
        : <LatLng>[];
    return {
      'totalDistance': totalDistance,
      'totalAscent': totalAscent,
      'path': path,    };
  }

  /// Fordert Berechtigung für Benachrichtigungen an
  /// 
  /// Wird für Hintergrund-Tracking benötigt um den Benutzer über
  /// das laufende Tracking zu informieren
  Future<void> requestNotificationPermission() async {
    _log.i('Prüfe Benachrichtigungsberechtigung.');
    if (await Permission.notification.isDenied) {
      _log.i('Fordere Benachrichtigungsberechtigung an.');
      await Permission.notification.request();    }
  }

  /// Aktiviert das Hintergrund-Tracking mit Benachrichtigung
  /// 
  /// Konfiguriert eine persistente Benachrichtigung die anzeigt,
  /// dass das GPS-Tracking auch bei geschlossener App weiterläuft.
  /// Wichtig für kontinuierliche Wegaufzeichnung.
  Future<void> enableBackgroundTracking() async {
    _log.i('Aktiviere Hintergrund-Tracking.');
    await requestNotificationPermission();
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: 'Tracking läuft',
      notificationText: 'Das Tracking läuft im Hintergrund.',
      enableWifiLock: true,
      notificationIcon: AndroidResource(
        name: 'ic_launcher',
        defType: 'mipmap',
      ),
      notificationImportance: AndroidNotificationImportance.max,
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    await FlutterBackground.enableBackgroundExecution();    _log.i('Hintergrund-Tracking wurde aktiviert.');
  }

  /// Deaktiviert das Hintergrund-Tracking
  Future<void> disableBackgroundTracking() async {
    _log.i('Deaktiviere Hintergrund-Tracking.');    await FlutterBackground.disableBackgroundExecution();
  }

  /// Prüft ob beim letzten App-Start ein Tracking aktiv war
  /// 
  /// Wird beim App-Start verwendet um zu entscheiden, ob ein
  /// unterbrochenes Tracking automatisch fortgesetzt werden soll.
  Future<bool> wasTrackingActive() async {
    _log.i('Prüfe, ob Tracking beim letzten Mal aktiv war.');
    return await loadTrackingState();
  }
}