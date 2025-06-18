import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Class/User.dart';
import '../Class/supabase_client.dart';
import '../Class/Logging.dart';

/// Notfall- und Check-In-Seite der HikeMate App
/// 
/// Diese Seite bietet Sicherheitsfunktionen für Wanderer:
/// - Automatische Check-In-Nachrichten in regelmäßigen Abständen
/// - Notfall-Kontakte und schnelle Hilfe-Rufnummern
/// - GPS-Position für Notfall-Services
/// 
/// Features:
/// - Konfigurierbarer Check-In-Timer (automatische Sicherheitsmeldungen)
/// - Schnellzugriff auf Notfall-Rufnummern (112, Bergrettung, etc.)
/// - GPS-Koordinaten für Rettungsdienste
/// - Persistente Speicherung der Check-In-Einstellungen
class EmergencyPage extends StatefulWidget {
  const EmergencyPage({Key? key}) : super(key: key);

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

/// State-Klasse für die EmergencyPage mit Timer- und GPS-Management
class _EmergencyPageState extends State<EmergencyPage> {
  /// Timer für automatische Check-In-Nachrichten
  Timer? _timer;
  
  /// Zeigt an ob der Check-In-Service aktiv ist
  bool _active = false;
  
  /// Intervall für Check-In-Nachrichten in Sekunden (Standard: 2 Stunden)
  int _intervalSeconds = 7200;
  
  /// Zeigt an ob gerade eine Nachricht gesendet wird
  bool _sending = false;
  
  /// Logger für diese Seite
  final _log = LoggingService();

  @override
  void initState() {
    super.initState();
    _log.init().then((_) => _log.i('EmergencyPage initialisiert.'));
    _initCheckIn();
  }

  /// Initialisiert die Check-In-Einstellungen beim App-Start
  /// 
  /// Lädt gespeicherte Einstellungen aus SharedPreferences und
  /// startet den Timer falls Check-In aktiv war
  Future<void> _initCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    _active = prefs.getBool('checkInActive') ?? false;
    _intervalSeconds = prefs.getInt('checkInInterval') ?? 7200;
    _log.i('CheckIn-Status geladen: active=$_active, interval=$_intervalSeconds sec');
    if (_active) _scheduleNext();
    setState(() {});
  }

  /// Plant den nächsten Check-In-Timer
  /// 
  /// Cancelt den vorherigen Timer und startet einen neuen mit
  /// dem konfigurierten Intervall
  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: _intervalSeconds), _showSOSScreen);
    _log.i('Nächster Check-In in $_intervalSeconds Sekunden geplant.');
  }

  /// Startet den automatischen Check-In-Service
  /// 
  /// Speichert die Einstellungen persistent und startet den Timer
  /// für wiederkehrende Sicherheits-Check-Ins
  Future<void> _startCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkInActive', true);
    await prefs.setInt('checkInInterval', _intervalSeconds);
    _active = true;
    _log.i('Check-In gestartet mit Intervall $_intervalSeconds Sekunden.');
    _scheduleNext();
    setState(() {});
  }

  /// Stoppt den automatischen Check-In-Service
  /// 
  /// Deaktiviert den Service, cancelt den Timer und speichert
  /// die Einstellungen persistent
  Future<void> _stopCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkInActive', false);
    _active = false;
    _timer?.cancel();
    _log.i('Check-In gestoppt.');
    setState(() {});
  }

  /// Zeigt den SOS-Bildschirm nach Check-In-Timeout
  /// 
  /// Wird automatisch aufgerufen wenn der Check-In-Timer abläuft
  /// und navigiert zum blinkenden SOS-Screen
  void _showSOSScreen() {
    _timer?.cancel();
    _log.i('Zeige SOS-Screen nach Check-In-Timeout.');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SOSScreen(onFinished: () {
          if (_active) _scheduleNext();
        }),
      ),
    );
  }

  /// Sendet eine SOS-Nachricht mit GPS-Position
  /// 
  /// Ermittelt die aktuelle Position, lädt die Notfallnummer aus der
  /// Datenbank und öffnet die SMS-App mit einer vorformulierten
  /// SOS-Nachricht inkl. GPS-Koordinaten. Bei Fehlern wird eine
  /// Fehlermeldung angezeigt.
  Future<void> _sendSOS() async {
    setState(() => _sending = true);
    _log.i('SOS gesendet: Standort wird abgerufen.');
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final lat = pos.latitude, lon = pos.longitude;
      _log.i('Position ermittelt: lat=$lat, lon=$lon');

      final row = await supabase
          .from('User')
          .select('ContactNumber')
          .eq('UserID', User.id)
          .single();
      final phone = (row['ContactNumber']?.toString() ?? '').trim();
      if (phone.isEmpty) throw Exception('Keine Notfallnummer hinterlegt.');
      _log.i('Notfallnummer: $phone');

      final body = Uri.encodeComponent('SOS! Bitte helft mir. Meine Position: $lat, $lon');
      final uri = Uri.parse('sms:$phone?body=$body');
      if (await canLaunchUrl(uri)) {
        _log.i('SMS-App wird geöffnet.');
        await launchUrl(uri);
      } else {
        throw Exception('SMS-App konnte nicht geöffnet werden.');
      }
    } catch (e, st) {
      _log.e('Fehler beim SOS', e, st);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim SOS: $e')));
    } finally {
      setState(() => _sending = false);
      _log.i('SOS-Vorgang abgeschlossen.');
      _showSOSScreen();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _log.i('EmergencyPage disposed.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        title: const Text('Notfall & Check-In'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Check-In Intervall:', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  dropdownColor: const Color(0xFF2C2C2C),
                  value: _intervalSeconds,
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10 Sek.', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 60, child: Text('1 Min.', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 3600, child: Text('1 Std.', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 7200, child: Text('2 Std.', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 14400, child: Text('4 Std.', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 21600, child: Text('6 Std.', style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: _active ? null : (v) => setState(() => _intervalSeconds = v!),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _active ? _stopCheckIn : _startCheckIn,
                  style: ElevatedButton.styleFrom(backgroundColor: _active ? Colors.grey : Colors.lightBlueAccent),
                  child: Text(_active ? 'Stop Check-In' : 'Start Check-In'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sending
                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.redAccent))
                : ElevatedButton.icon(
              onPressed: _sendSOS,
              icon: const Icon(Icons.sos),
              label: const Text('SOS senden'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vollbild-SOS-Bildschirm mit blinkender Animation
/// 
/// Dieser Screen wird angezeigt wenn ein Check-In-Timeout auftritt
/// oder manuell ein SOS gesendet wird. Der Bildschirm blinkt rot
/// um Aufmerksamkeit zu erregen.
/// 
/// [onFinished] - Callback der aufgerufen wird wenn der SOS beendet wird
class SOSScreen extends StatefulWidget {
  /// Callback-Funktion die aufgerufen wird wenn SOS beendet wird
  final VoidCallback onFinished;
  const SOSScreen({required this.onFinished, Key? key}) : super(key: key);
  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

/// State-Klasse für SOSScreen mit Blink-Animation
/// 
/// Verwaltet die rote Blink-Animation für den SOS-Bildschirm
/// mit Hilfe eines AnimationControllers
class _SOSScreenState extends State<SOSScreen>
    with SingleTickerProviderStateMixin {
  /// Controller für die Blink-Animation
  late AnimationController _controller;
  /// Animation für Farbwechsel zwischen verschiedenen Rottönen
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _colorAnim = ColorTween(begin: Colors.red.shade900, end: Colors.red.shade500).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _colorAnim,
        builder: (context, child) => Container(color: _colorAnim.value, child: child),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Center(child: Text('SOS', style: TextStyle(color: Colors.white, fontSize: 120, fontWeight: FontWeight.bold))),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFinished();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                  child: const Text('BEENDET', style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
