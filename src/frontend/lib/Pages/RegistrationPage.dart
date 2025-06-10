import 'package:HikeMate/Class/User.dart';
import 'package:HikeMate/Pages/LoginPage.dart';
import 'package:flutter/material.dart';
import '../Class/supabase_client.dart';
import 'package:bcrypt/bcrypt.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> register(BuildContext context) async {
      try {
        final result = await User.register_User(firstNameController.text, lastNameController.text, usernameController.text, passwordController.text,);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrierung erfolgreich!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username bereits vergeben')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.lightBlueAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFF141212),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: const Text(
                    'Registrieren',
                    style: TextStyle(
                      fontSize: 45,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                _buildTextField(
                  controller: firstNameController,
                  hintText: 'Vorname',
                  icon: Icons.person_2,
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  controller: lastNameController,
                  hintText: 'Nachname',
                  icon: Icons.person_2,
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  controller: usernameController,
                  hintText: 'Benutzername',
                  icon: Icons.person,
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  controller: passwordController,
                  hintText: 'Passwort',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 55),
                Align(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: 300, minWidth: 300, maxHeight: 48, minHeight: 48),
                    child: ElevatedButton(
                      onPressed: () => register(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Align(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, minWidth: 300),
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
      ),
    );
  }
}