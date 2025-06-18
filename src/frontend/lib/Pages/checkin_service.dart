import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Class/User.dart';
import '../Class/supabase_client.dart';
import '../Class/Logging.dart';
import '../main.dart';

/// Service für automatische Check-In-Funktionalität
/// 
/// Dieser Service implementiert ein Singleton-Pattern und verwaltet
/// automatische Sicherheits-Check-Ins für Wanderer. Er sendet in
/// regelmäßigen Abständen Lebenszeichen mit GPS-Position.
/// 
/// Features:
/// - Automatische Check-In-Nachrichten in konfigurierbaren Intervallen
/// - GPS-Position-Übertragung für Sicherheit
/// - Persistente Speicherung der Einstellungen
/// - Hintergrund-Timer für kontinuierliche Überwachung
/// - Integration mit Notfall-Services
class CheckInService {
  /// Singleton-Instanz des CheckInService
  static final CheckInService _instance = CheckInService._internal();
  
  /// Factory Constructor für Singleton-Pattern
  factory CheckInService() => _instance;
  
  /// Privater Constructor für Singleton-Pattern
  CheckInService._internal();

  /// Logger für diesen Service
  final _log = LoggingService();
  
  /// Timer für periodische Check-Ins
  Timer? _timer;
  
  /// Check-In-Intervall in Stunden (Standard: 2 Stunden)
  int intervalHours = 2;
  
  /// Zeigt an ob der Check-In-Service aktiv ist
  bool active = false;

  /// Initialisiert den CheckInService
  /// 
  /// Lädt gespeicherte Einstellungen und startet ggf. den Timer
  Future<void> init() async {
    await _log.init();
    _log.i('CheckInService init gestartet.');

    final prefs = await SharedPreferences.getInstance();
    active = prefs.getBool('checkInActive') ?? false;
    intervalHours = prefs.getInt('checkInInterval') ?? 2;
    _log.i('Status geladen: active=\$active, intervalHours=\$intervalHours');

    if (active) {
      _scheduleNext();
    }
  }

  /// Startet den Check-In-Service mit dem angegebenen Intervall
  /// 
  /// [hours] - Intervall zwischen Check-Ins in Stunden
  /// 
  /// Speichert die Einstellungen persistent und startet den Timer
  Future<void> start(int hours) async {
    intervalHours = hours;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkInActive', true);
    await prefs.setInt('checkInInterval', hours);
    active = true;
    _log.i('CheckInService gestartet mit Intervall \$intervalHours Stunden.');
    _scheduleNext();
  }

  /// Stoppt den Check-In-Service
  /// 
  /// Deaktiviert den Service, cancelt den Timer und speichert
  /// die Einstellungen persistent
  Future<void> stop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkInActive', false);
    active = false;
    _timer?.cancel();
    _log.i('CheckInService gestoppt. Keine weiteren Check-Ins.');
  }

  /// Plant den nächsten Check-In Timer
  /// 
  /// Cancelt den vorherigen Timer und startet einen neuen mit
  /// dem konfigurierten Intervall
  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(Duration(hours: intervalHours), _askCheckIn);
    _log.i('Nächstes Check-In in \$intervalHours Stunden geplant.');
  }

  /// Zeigt den Check-In-Dialog an und wartet auf Benutzerreaktion
  /// 
  /// Startet einen 5-Minuten-Timer. Bei fehlender Reaktion wird
  /// automatisch ein SOS gesendet. Der Dialog ist nicht abweisbar
  /// und erfordert eine explizite Antwort.
  void _askCheckIn() {
    _log.i('CheckInService fragt nach Check-In.');

    bool responded = false;
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      _log.w('Kontext für Check-In-Dialog nicht verfügbar.');
      return;
    }

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
              _log.i('Check-In bestätigt: Benutzer OK.');
              Navigator.of(c).pop();
              _scheduleNext();
            },
            child: const Text('Ja'),
          ),
          TextButton(
            onPressed: () {
              responded = true;
              _log.w('Check-In abgelehnt: SOS wird gesendet.');
              Navigator.of(c).pop();
              sendSOS();
            },
            child: const Text('Nein'),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(minutes: 5), () {
      if (!responded) {
        _log.w('Keine Reaktion auf Check-In innerhalb von 5 Minuten. SOS wird gesendet.');
        sendSOS();
      }
      if (active) _scheduleNext();
    });
  }

  /// Sendet eine SOS-Nachricht mit aktueller GPS-Position
  /// 
  /// Ermittelt die aktuelle Position, lädt die Notfallnummer aus der
  /// Datenbank und öffnet die SMS-App mit einer vorformulierten
  /// SOS-Nachricht inkl. GPS-Koordinaten.
  /// 
  /// Bei Fehlern wird eine entsprechende Snackbar angezeigt.
  Future<void> sendSOS() async {
    _log.i('sendSOS aufgerufen. Versuche Standort abzurufen.');
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final lat = pos.latitude, lon = pos.longitude;
      _log.i('Position ermittelt: lat=\$lat, lon=\$lon');

      final row = await supabase
          .from('User')
          .select('ContactNumber')
          .eq('UserID', User.id)
          .single();
      final phone = (row['ContactNumber']?.toString() ?? '').trim();
      if (phone.isEmpty) throw Exception('Keine Notfallnummer hinterlegt.');

      _log.i('Notfallnummer: \$phone');
      final body = Uri.encodeComponent(
          'SOS! Bitte helft mir. Meine Position: \$lat, \$lon');
      final uri = Uri.parse('sms:\$phone?body=\$body');
      if (await canLaunchUrl(uri)) {
        _log.i('SMS-App wird geöffnet.');
        await launchUrl(uri);
      } else {
        throw Exception('SMS-App konnte nicht geöffnet werden.');
      }
    } catch (e, st) {
      _log.e('Fehler in sendSOS', e, st);
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(SnackBar(content: Text('Fehler beim SOS: \$e')));
      }
    }
  }
}
