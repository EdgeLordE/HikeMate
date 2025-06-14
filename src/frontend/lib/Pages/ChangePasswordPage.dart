import 'package:flutter/material.dart';
import '../Class/UserService.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _submit() async {
    final oldPass = _oldPassCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();
    if (oldPass.isEmpty || newPass.isEmpty) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    final success = await UserService.changePassword(oldPass, newPass);

    setState(() {
      _loading = false;
      _message = success
          ? 'Passwort erfolgreich geändert.'
          : 'Fehler beim Ändern des Passworts.';
    });

    if (success && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        title: const Text('Passwort ändern'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _oldPassCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Altes Passwort',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPassCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Neues Passwort',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator(color: Colors.lightBlueAccent)
                : ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 12,
                ),
              ),
              child: const Text('Ändern', style: TextStyle(fontSize: 16)),
            ),
            if (_message != null) ...[
              const SizedBox(height: 20),
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith('Passwort erfolgreich')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
