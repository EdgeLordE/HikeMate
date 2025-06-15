import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Class/User.dart';
import '../Class/supabase_client.dart';
import '../main.dart';

class CheckInService {
  static final CheckInService _instance = CheckInService._internal();
  factory CheckInService() => _instance;
  CheckInService._internal();

  Timer? _timer;
  int intervalHours = 2;
  bool active = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    active = prefs.getBool('checkInActive') ?? false;
    intervalHours = prefs.getInt('checkInInterval') ?? 2;
    if (active) {
      _scheduleNext();
    }
  }

  Future<void> start(int hours) async {
    intervalHours = hours;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkInActive', true);
    await prefs.setInt('checkInInterval', hours);
    active = true;
    _scheduleNext();
  }

  Future<void> stop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkInActive', false);
    active = false;
    _timer?.cancel();
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(Duration(hours: intervalHours), _askCheckIn);
  }

  void _askCheckIn() {
    bool responded = false;
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;


    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('Check-In'),
        content: const Text('Bist du noch in Ordnung?'),
        actions: [
          TextButton(
            onPressed: () {
              responded = true;
              Navigator.of(c).pop();
              _scheduleNext();
            },
            child: const Text('Ja'),
          ),
          TextButton(
            onPressed: () {
              responded = true;
              Navigator.of(c).pop();
              sendSOS();
            },
            child: const Text('Nein'),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(minutes: 5), () {
      if (!responded) sendSOS();
      if (active) _scheduleNext();
    });
  }

  Future<void> sendSOS() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final lat = pos.latitude, lon = pos.longitude;

      final row = await supabase
          .from('User')
          .select('ContactNumber')
          .eq('UserID', User.id)
          .single();
      final phone = (row['ContactNumber']?.toString() ?? '').trim();
      if (phone.isEmpty) throw Exception('Keine Notfallnummer hinterlegt.');

      final body = Uri.encodeComponent(
          'SOS! Bitte helft mir. Meine Position: $lat, $lon');
      final uri = Uri.parse('sms:$phone?body=$body');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('SMS-App konnte nicht geöffnet werden.');
      }
    } catch (e) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(SnackBar(content: Text('Fehler beim SOS: $e')));
      }
    }
  }
}
