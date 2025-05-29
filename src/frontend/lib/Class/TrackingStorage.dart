import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';

class TrackingStorage {
  Future<void> saveTrackingData(double totalDistance, double totalAscent, List<LatLng> path) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('totalDistance', totalDistance);
    prefs.setDouble('totalAscent', totalAscent);
    prefs.setString('path', jsonEncode(path.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()));
  }

  Future<void> saveTrackingDuration(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('duration', duration.inSeconds);
  }
  Future<Duration> loadTrackingDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return Duration(seconds: prefs.getInt('duration') ?? 0);
  }
  Future<void> saveAltitude(double altitude) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('altitude', altitude);
  }
  Future<void> saveTrackingState(bool isTracking) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isTracking', isTracking);
  }

  Future<bool> loadTrackingState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isTracking') ?? false;
  }

  Future<Map<String, dynamic>> loadTrackingData() async {
    final prefs = await SharedPreferences.getInstance();
    final totalDistance = prefs.getDouble('totalDistance') ?? 0.0;
    final totalAscent   = prefs.getDouble('totalAscent')   ?? 0.0;
    final pathString    = prefs.getString('path');
    final path = pathString != null
        ? (jsonDecode(pathString) as List)
        .map((p) => LatLng(p['lat'], p['lng'])).toList()
        : <LatLng>[];
    return {
      'totalDistance': totalDistance,
      'totalAscent'  : totalAscent,
      'path'         : path,
    };
  }


  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> enableBackgroundTracking() async {
    await requestNotificationPermission();
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: 'Tracking läuft',
      notificationText: 'Das Tracking läuft im Hintergrund.',
      enableWifiLock: true,
      notificationIcon: AndroidResource(
        name: 'ic_launcher', // genaues Icon in drawable
        defType: 'mipmap',
      ),
      notificationImportance: AndroidNotificationImportance.max,
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    await FlutterBackground.enableBackgroundExecution();
  }

  Future<void> disableBackgroundTracking() async {
    await FlutterBackground.disableBackgroundExecution();
  }

  Future<bool> wasTrackingActive() async{
    return await loadTrackingState();
  }
}