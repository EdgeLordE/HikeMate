import 'dart:convert';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'RegistrationPage.dart';
import '../Class/supabase_client.dart';
import 'package:bcrypt/bcrypt.dart';
import '../Class/User.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth * 0.85;

    Future<void> login(BuildContext context) async {
      try {
        final result = await User.login_User(usernameController.text, passwordController.text);

        if (result["success"]) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"])),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login fehlgeschlagen')),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141212),
      body: Center(
        child: SingleChildScrollView( // Added SingleChildScrollView for smaller screens
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Added horizontal padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
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
                  controller: usernameController,
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
                  controller: passwordController,
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
              ConstrainedBox( // Added ConstrainedBox for responsive width
                constraints: BoxConstraints(maxWidth: formWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Align to start within the constrained width
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
                          MaterialPageRoute(builder: (context) => const RegistrationPage()),
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
                    maxWidth: formWidth, minHeight: 48), // minHeight to maintain button size
                child: SizedBox( // Use SizedBox to enforce width for ElevatedButton
                  width: double.infinity, // Make button take full width of ConstrainedBox
                  child: ElevatedButton(
                    onPressed: () => login(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40), // Adjusted border radius
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11), // Ensure consistent padding
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