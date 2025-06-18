import 'dart:io';
import 'package:flutter/material.dart';
import 'package:HikeMate/Class/User.dart';
import 'package:HikeMate/Pages/LoginPage.dart';
import 'package:HikeMate/Class/Logging.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _log = LoggingService();

  @override
  void initState() {
    super.initState();
    _log.init().then((_) {
      _log.i('RegistrationPage initialisiert.');
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final user = usernameController.text;
    try {
      _log.i('Registrierungsversuch für Benutzer: $user');
      final result = await User.register_User(
        firstNameController.text,
        lastNameController.text,
        user,
        passwordController.text,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        _log.i('Registrierung erfolgreich für Benutzer: $user');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrierung erfolgreich!')),
        );
        if (Navigator.canPop(context)) {
          _log.i('Navigiere zurück zur LoginPage');
          Navigator.pop(context);
        } else {
          _log.i('Ersetze mit LoginPage');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        final msg = result["message"] ?? 'Registrierung fehlgeschlagen';
        _log.w('Registrierung fehlgeschlagen für Benutzer: $user – $msg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e, st) {
      if (!mounted) return;
      _log.e('Ausnahme bei Registrierung für Benutzer: $user', e, st);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrierung fehlgeschlagen: ${e.toString()}')),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF141212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.lightBlueAccent),
          onPressed: () {
            _log.i('Navigiere zurück von RegistrationPage');
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFF141212),
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Registrieren',
                  style: TextStyle(
                    fontSize: 45,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 50),
                _buildTextField(
                  controller: firstNameController,
                  hintText: 'Vorname',
                  icon: Icons.person_2,
                  maxWidth: formWidth,
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  controller: lastNameController,
                  hintText: 'Nachname',
                  icon: Icons.person_2,
                  maxWidth: formWidth,
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  controller: usernameController,
                  hintText: 'Benutzername',
                  icon: Icons.person,
                  maxWidth: formWidth,
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  controller: passwordController,
                  hintText: 'Passwort',
                  icon: Icons.lock,
                  obscureText: true,
                  maxWidth: formWidth,
                ),
                const SizedBox(height: 55),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: formWidth, minHeight: 48),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      child: const Text(
                        'Registrieren',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
