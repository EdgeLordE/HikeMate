import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Logging.dart';

class TrackingStorage {
  final _log = LoggingService();

  Future<void> saveTrackingData(
      double totalDistance, double totalAscent, List<LatLng> path) async {
    _log.i(
        'Speichere Tracking-Daten: Distanz=$totalDistance, Aufstieg=$totalAscent, Pfadlänge=${path.length}');
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('totalDistance', totalDistance);
    prefs.setDouble('totalAscent', totalAscent);
    prefs.setString('path',
        jsonEncode(path.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()));
  }

  Future<void> saveTrackingDuration(Duration duration) async {
    _log.i('Speichere Tracking-Dauer: ${duration.inSeconds}s');
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('duration', duration.inSeconds);
  }

  Future<Duration> loadTrackingDuration() async {
    _log.i('Lade Tracking-Dauer.');
    final prefs = await SharedPreferences.getInstance();
    return Duration(seconds: prefs.getInt('duration') ?? 0);
  }

  Future<void> saveAltitude(double altitude) async {
    _log.i('Speichere Höhe: $altitude');
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('altitude', altitude);
  }

  Future<void> saveTrackingState(bool isTracking) async {
    _log.i('Speichere Tracking-Status: $isTracking');
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isTracking', isTracking);
  }

  Future<bool> loadTrackingState() async {
    _log.i('Lade Tracking-Status.');
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isTracking') ?? false;
  }

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
      'path': path,
    };
  }

  Future<void> requestNotificationPermission() async {
    _log.i('Prüfe Benachrichtigungsberechtigung.');
    if (await Permission.notification.isDenied) {
      _log.i('Fordere Benachrichtigungsberechtigung an.');
      await Permission.notification.request();
    }
  }

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
    await FlutterBackground.enableBackgroundExecution();
    _log.i('Hintergrund-Tracking wurde aktiviert.');
  }

  Future<void> disableBackgroundTracking() async {
    _log.i('Deaktiviere Hintergrund-Tracking.');
    await FlutterBackground.disableBackgroundExecution();
  }

  Future<bool> wasTrackingActive() async {
    _log.i('Prüfe, ob Tracking beim letzten Mal aktiv war.');
    return await loadTrackingState();
  }
}