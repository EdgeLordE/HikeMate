import 'package:flutter/material.dart';
import '../Class/UserService.dart';
import '../Class/User.dart';

class ChangeUsernamePage extends StatefulWidget {
  const ChangeUsernamePage({Key? key}) : super(key: key);

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
  final TextEditingController _oldUsernameController = TextEditingController();
  final TextEditingController _newUsernameController = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _oldUsernameController.text = User.username;
  }

  Future<void> _submit() async {
    final oldUsername = _oldUsernameController.text.trim();
    final newUsername = _newUsernameController.text.trim();
    if (oldUsername.isEmpty || newUsername.isEmpty) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    final success = await UserService.changeUsername(oldUsername, newUsername);

    setState(() {
      _loading = false;
      _message = success
          ? 'Benutzername erfolgreich geändert.'
          : 'Fehler beim Ändern des Benutzernamens.';
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
        title: const Text('Benutzernamen ändern'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _oldUsernameController,
              readOnly: true,
              style: const TextStyle(color: Colors.white70),
              decoration: const InputDecoration(
                labelText: 'Alter Benutzername',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newUsernameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Neuer Benutzername',
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
                  color: _message!.startsWith('Benutzername erfolgreich')
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
