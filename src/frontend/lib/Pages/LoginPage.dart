import 'dart:convert';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'RegistrationPage.dart';
import '../Class/User.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    try {
      // Verwenden Sie .text von den Controllern, die im State gehalten werden
      final result = await User.login_User(
          _usernameController.text, _passwordController.text);

      if (_usernameController.text == "" && _passwordController.text == "") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte Benutzername und Passwort eingeben')),
        );
        return;
      }

      if (!mounted) return; // Überprüfen, ob das Widget noch im Baum ist

      if (result["success"] == true) { // Expliziter Check auf true
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result["message"]?.toString() ??
                  'Login fehlgeschlagen: Unbekannte Nachricht')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login fehlgeschlagen: ${e.toString()}')),
      );
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  controller: _usernameController, // Controller aus dem State verwenden
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
                  controller: _passwordController, // Controller aus dem State verwenden
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegistrationPage()),
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
                constraints: BoxConstraints(
                    maxWidth: formWidth, minHeight: 48),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        _login(context), // _login Methode des States aufrufen
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding:
                      const EdgeInsets.symmetric(vertical: 11),
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