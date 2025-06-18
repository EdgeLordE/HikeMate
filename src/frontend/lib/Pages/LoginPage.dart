// lib/Pages/LoginPage.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../Class/Logging.dart';
import 'HomePage.dart';
import 'RegistrationPage.dart';
import '../Class/User.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  final _log = LoggingService();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    LoggingService();
    _log.i('LoginPage initialized');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    final user = _usernameController.text;
    final pass = _passwordController.text;
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte Benutzername und Passwort eingeben'))
      );
      _log.w('Leere Anmeldedaten');
      return;
    }
    try {
      _log.i('Login attempt for user: $user');
      final result = await User.login_User(user, pass);
      if (!mounted) return;
      if (result['success'] == true) {
        _log.i('Login successful for user: $user');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        final msg = result['message']?.toString() ?? 'Unbekannte Nachricht';
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login fehlgeschlagen: $msg'))
        );
        _log.w('Login failed for user: $user – $msg');
      }
    } catch (e, st) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login fehlgeschlagen: ${e.toString()}'))
      );
      _log.e('Exception during login for user: $user', e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth * 0.85;

    return Scaffold(
      backgroundColor: const Color(0xFF141212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 45,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 50),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formWidth),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF505050),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.lightBlueAccent,
                      size: 25,
                    ),
                    hintText: 'Benutzername',
                    hintStyle: const TextStyle(color: Colors.white54),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 25),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formWidth),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF505050),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.lightBlueAccent,
                      size: 25,
                    ),
                    hintText: 'Passwort',
                    hintStyle: const TextStyle(color: Colors.white54),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Noch kein Konto?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _log.i('Navigiere zu RegistrationPage');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegistrationPage()),
                        );
                      },
                      child: const Text(
                        'Registrieren',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formWidth, minHeight: 48),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _login(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    child: const Text(
                      'Login',
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
    );
  }
}
