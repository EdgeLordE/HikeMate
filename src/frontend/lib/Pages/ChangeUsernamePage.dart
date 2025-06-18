import 'package:flutter/material.dart';
import '../Class/User.dart';

/// Seite zum Ändern des Benutzernamens
/// 
/// Diese Seite ermöglicht es Benutzern ihren aktuellen Benutzernamen
/// zu ändern. Der alte Benutzername wird zur Verifikation angezeigt.
/// 
/// Features:
/// - Anzeige des aktuellen Benutzernamens
/// - Eingabe des neuen gewünschten Benutzernamens
/// - Validation der Eindeutigkeit des neuen Benutzernamens
/// - Aktualisierung im Backend und lokaler Session
class ChangeUsernamePage extends StatefulWidget {
  const ChangeUsernamePage({Key? key}) : super(key: key);

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

/// State-Klasse für die ChangeUsernamePage mit Formular-Management
class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
  /// Controller für den alten Benutzernamen (nur zur Anzeige)
  final TextEditingController _oldUsernameController = TextEditingController();
  
  /// Controller für den neuen gewünschten Benutzernamen
  final TextEditingController _newUsernameController = TextEditingController();
  
  /// Zeigt an ob gerade eine Anfrage läuft
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Aktuellen Benutzernamen vorausfüllen
    _oldUsernameController.text = User.username;
  }

  @override
  void dispose() {
    _oldUsernameController.dispose();
    _newUsernameController.dispose();
    super.dispose();
  }

  /// Zeigt eine Snackbar mit Erfolgsmeldung oder Fehlermeldung
  /// 
  /// [message] - Die anzuzeigende Nachricht
  /// [isError] - true für Fehlermeldung (rot), false für Erfolg (grün)
  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),    );
  }

  /// Führt die Benutzername-Änderung durch
  /// 
  /// Validiert die Eingaben, sendet die Änderungsanfrage an das Backend
  /// und behandelt die Antwort entsprechend. Bei Erfolg wird der neue
  /// Benutzername lokal gespeichert und die Seite geschlossen.
  /// 
  /// Validation:
  /// - Neuer Benutzername darf nicht leer sein
  /// - Neuer Benutzername muss sich vom alten unterscheiden
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

    final success = await User.changeUsername(oldUsername, newUsername);

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
  /// Baut ein stilisiertes Textfeld mit einheitlichem Design
  /// 
  /// [controller] - TextEditingController für das Textfeld
  /// [hintText] - Platzhaltertext für das Textfeld
  /// [icon] - Icon das vor dem Text angezeigt wird
  /// [readOnly] - Gibt an ob das Textfeld nur lesbar ist
  /// [maxWidth] - Maximale Breite des Textfelds für responsive Design
  /// 
  /// Returns: Ein gestyltes TextField Widget mit dunklem Design
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