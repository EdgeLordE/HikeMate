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

  @override
  void initState() {
    super.initState();
    _oldUsernameController.text = User.username;
  }

  @override
  void dispose() {
    _oldUsernameController.dispose();
    _newUsernameController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _submit() async {
    final oldUsername = _oldUsernameController.text.trim(); // Bleibt, da es vom User-Objekt kommt
    final newUsername = _newUsernameController.text.trim();

    if (newUsername.isEmpty) {
      _showSnackBar('Bitte geben Sie einen neuen Benutzernamen ein.');
      return;
    }

    if (newUsername == oldUsername) {
      _showSnackBar('Der neue Benutzername muss sich vom alten unterscheiden.');
      return;
    }
    // Optionale weitere Validierungen für den neuen Benutzernamen (Länge, Zeichen etc.)

    setState(() {
      _loading = true;
    });

    final success = await UserService.changeUsername(oldUsername, newUsername);

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    if (success) {
      _showSnackBar('Benutzername erfolgreich geändert.', isError: false);
      // Update local User object if necessary, though UserService might handle this
      User.username = newUsername; // Direktes Update des statischen Feldes
      _oldUsernameController.text = newUsername; // Aktualisiere das Textfeld
      _newUsernameController.clear();
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    } else {
      _showSnackBar('Fehler beim Ändern des Benutzernamens. Der Benutzername ist möglicherweise bereits vergeben.');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
    required double maxWidth,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
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
          hintStyle: TextStyle(color: readOnly ? Colors.white70 : Colors.white54),
        ),
        style: TextStyle(color: readOnly ? Colors.white70 : Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth * 0.85;

    return Scaffold(
      backgroundColor: const Color(0xFF141212), // Angepasster Hintergrund
      appBar: AppBar(
        title: const Text(
          'Benutzernamen ändern',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF141212), // Angepasster Hintergrund
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.lightBlueAccent),
          onPressed: () {
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
                  controller: _oldUsernameController,
                  hintText: 'Alter Benutzername',
                  icon: Icons.person_outline,
                  readOnly: true,
                  maxWidth: formWidth,
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  controller: _newUsernameController,
                  hintText: 'Neuer Benutzername',
                  icon: Icons.person,
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
                        backgroundColor: Colors.lightBlueAccent.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
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