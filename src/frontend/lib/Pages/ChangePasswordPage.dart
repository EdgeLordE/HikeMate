import 'package:flutter/material.dart';
import '../Class/User.dart';
import '../Class/Logging.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmNewPassCtrl = TextEditingController();
  final _log = LoggingService();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _log.init().then((_) {
      _log.i('ChangePasswordPage initialisiert.');
    });
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmNewPassCtrl.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
    if (isError) {
      _log.w(message);
    } else {
      _log.i(message);
    }
  }

  Future<void> _submit() async {
    final oldPass = _oldPassCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();
    final confirmNewPass = _confirmNewPassCtrl.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmNewPass.isEmpty) {
      _log.w('ChangePassword: Nicht alle Felder ausgefüllt.');
      _showSnackBar('Bitte füllen Sie alle Felder aus.');
      return;
    }

    if (newPass != confirmNewPass) {
      _log.w('ChangePassword: Neue Passwörter stimmen nicht überein.');
      _showSnackBar('Die neuen Passwörter stimmen nicht überein.');
      return;
    }

    setState(() {
      _loading = true;
    });
    _log.i('ChangePassword: Passwortänderung gestartet.');

    try {
      final success = await User.changePassword(oldPass, newPass);

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      if (success) {
        _log.i('ChangePassword: Passwort erfolgreich geändert.');
        _showSnackBar('Passwort erfolgreich geändert.', isError: false);
        _oldPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmNewPassCtrl.clear();
        await Future.delayed(const Duration(seconds: 2));
        if (mounted && Navigator.canPop(context)) {
          _log.i('ChangePassword: Zurücknavigation nach Erfolg.');
          Navigator.of(context).pop();
        }
      } else {
        _log.w('ChangePassword: Fehler beim Ändern des Passworts.');
        _showSnackBar('Fehler beim Ändern des Passworts. Überprüfen Sie Ihr altes Passwort.');
      }
    } catch (e, st) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      _log.e('ChangePassword: Ausnahme beim Passwortwechsel.', e, st);
      _showSnackBar('Fehler beim Ändern des Passworts: ${e.toString()}');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = true,
    required double maxWidth,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF505050),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.lightBlueAccent,
            size: 25,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth * 0.85;

    return Scaffold(
      backgroundColor: const Color(0xFF141212),
      appBar: AppBar(
        title: const Text(
          'Passwort ändern',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF141212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.lightBlueAccent),
          onPressed: () {
            _log.i('ChangePassword: Navigation zurück gedrückt.');
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _oldPassCtrl,
                  hintText: 'Altes Passwort',
                  icon: Icons.lock_outline,
                  maxWidth: formWidth,
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  controller: _newPassCtrl,
                  hintText: 'Neues Passwort',
                  icon: Icons.lock,
                  maxWidth: formWidth,
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  controller: _confirmNewPassCtrl,
                  hintText: 'Neues Passwort bestätigen',
                  icon: Icons.lock_clock_outlined,
                  maxWidth: formWidth,
                ),
                const SizedBox(height: 30),
                _loading
                    ? const CircularProgressIndicator(color: Colors.lightBlueAccent)
                    : ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: formWidth, minHeight: 48),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.lightBlueAccent.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding:
                        const EdgeInsets.symmetric(vertical: 11),
                      ),
                      child: const Text(
                        'Speichern',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
