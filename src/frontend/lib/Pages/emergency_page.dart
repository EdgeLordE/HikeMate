import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Class/User.dart';
import '../Class/supabase_client.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({Key? key}) : super(key: key);

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  Timer? _timer;
  bool _active = false;
  int _intervalSeconds = 7200;

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _initCheckIn();
  }

  Future<void> _initCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    _active = prefs.getBool('checkInActive') ?? false;
    _intervalSeconds = prefs.getInt('checkInInterval') ?? 7200;
    if (_active) _scheduleNext();
    setState(() {});
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: _intervalSeconds), _showSOSScreen);
  }

  Future<void> _startCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkInActive', true);
    await prefs.setInt('checkInInterval', _intervalSeconds);
    setState(() => _active = true);
    _scheduleNext();
  }

  Future<void> _stopCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkInActive', false);
    setState(() => _active = false);
    _timer?.cancel();
  }

  void _showSOSScreen() {
    _timer?.cancel();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SOSScreen(onFinished: () {
          if (_active) _scheduleNext();
        }),
      ),
    );
  }

  Future<void> _sendSOS() async {
    setState(() => _sending = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = pos.latitude, lon = pos.longitude;

      final row = await supabase
          .from('User')
          .select('ContactNumber')
          .eq('UserID', User.id)
          .single();
      final phone = (row['ContactNumber']?.toString() ?? '').trim();
      if (phone.isEmpty) throw Exception('Keine Notfallnummer hinterlegt.');

      final body = Uri.encodeComponent(
        'SOS! Bitte helft mir. Meine Position: $lat, $lon',
      );
      final uri = Uri.parse('sms:$phone?body=$body');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('SMS-App konnte nicht geöffnet werden.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim SOS: $e')),
      );
    } finally {
      setState(() => _sending = false);
      _showSOSScreen();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                const Text('Check-In Intervall:',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  dropdownColor: const Color(0xFF2C2C2C),
                  value: _intervalSeconds,
                  items: const [
                    DropdownMenuItem(
                        value: 10,
                        child: Text('10 Sek.',
                            style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 60,
                        child: Text('1 Min.',
                            style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 3600,
                        child: Text('1 Std.',
                            style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 7200,
                        child: Text('2 Std.',
                            style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 14400,
                        child: Text('4 Std.',
                            style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 21600,
                        child: Text('6 Std.',
                            style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: _active
                      ? null
                      : (v) => setState(() => _intervalSeconds = v!),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _active ? _stopCheckIn : _startCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _active ? Colors.grey : Colors.lightBlueAccent,
                  ),
                  child:
                  Text(_active ? 'Stop Check-In' : 'Start Check-In'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sending
                ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.redAccent))
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

class SOSScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const SOSScreen({required this.onFinished, Key? key}) : super(key: key);

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _colorAnim = ColorTween(
      begin: Colors.red.shade900,
      end: Colors.red.shade500,
    ).animate(_controller);
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
        builder: (context, child) => Container(
          color: _colorAnim.value,
          child: child,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFinished();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  child: const Text(
                    'BEENDET',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}