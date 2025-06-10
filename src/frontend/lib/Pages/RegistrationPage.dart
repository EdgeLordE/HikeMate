import 'package:HikeMate/Class/User.dart';
import 'package:HikeMate/Pages/LoginPage.dart';
import 'package:flutter/material.dart';


class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth * 0.85; // Verwende 85% der Bildschirmbreite

    Future<void> register(BuildContext context) async {
      try {
        final result = await User.register_User(
          firstNameController.text,
          lastNameController.text,
          usernameController.text,
          passwordController.text,
        );
        // Annahme: register_User gibt ein Map mit "success" und "message" zurück oder wirft einen Fehler
        // Diese Logik basiert auf der LoginPage, passe sie ggf. an das tatsächliche Verhalten von User.register_User an.
        if (result["success"]) { // Überprüfe, ob ein "success"-Flag zurückgegeben wird
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrierung erfolgreich!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? 'Registrierung fehlgeschlagen')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrierung fehlgeschlagen: ${e.toString()}')),
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
      body: Center( // Zentriert den Inhalt, wenn nicht gescrollt werden muss
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Horizontaler Abstand
          child: Padding( // Behält den ursprünglichen Padding bei, falls gewünscht
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Zentriert Elemente horizontal
              children: [
                const Text( // Zentriert durch CrossAxisAlignment.center der Column
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
                      onPressed: () => register(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40), // Angepasster Radius
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11), // Konsistentes Padding
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
    required double maxWidth, // Parameter für maximale Breite hinzugefügt
  }) {
    return ConstrainedBox( // Nicht mehr `Align`, da die Column bereits zentriert
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
}