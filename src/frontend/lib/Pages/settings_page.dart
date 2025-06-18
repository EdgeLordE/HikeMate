import 'package:HikeMate/Class/Logging.dart';
import 'package:flutter/material.dart';
import 'ChangeUsernamePage.dart';
import 'ChangePasswordPage.dart';
import '../Class/supabase_client.dart';
import '../Class/User.dart';

/// Einstellungsseite der HikeMate App
/// 
/// Diese Seite bietet alle Benutzer-Einstellungen und Profilverwaltung:
/// - Telefonnummer bearbeiten
/// - Benutzername ändern
/// - Passwort ändern
/// - Logout-Funktion
/// 
/// Features:
/// - Persistente Speicherung aller Änderungen
/// - Formular-Validation für Telefonnummer
/// - Navigation zu speziellen Change-Pages
/// - Sichere Logout-Funktionalität
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// State-Klasse für die SettingsPage mit Formular-Management
class _SettingsPageState extends State<SettingsPage> {
  /// Logger für diese Seite
  final _log = LoggingService();
  
  /// Form-Key für Validation
  final _formKey = GlobalKey<FormState>();
  
  /// Controller für das Telefonnummer-Eingabefeld
  final TextEditingController _phoneController = TextEditingController();
  
  /// Zeigt an ob gerade Daten geladen werden
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _log.i('SettingsPage initState');
    _loadPhoneNumber();
  }

  /// Lädt die gespeicherte Telefonnummer vom Backend
  Future<void> _loadPhoneNumber() async {
    if (User.id == null) {
      _log.w('Benutzer nicht angemeldet, kann Telefonnummer nicht laden.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Benutzer nicht angemeldet.')),
        );
        setState(() => _loading = false);
      }
      return;
    }
    _log.i('Lade Telefonnummer für User ID: ${User.id}');
    try {
      final resp = await supabase
          .from('User')
          .select('ContactNumber')
          .eq('UserID', User.id!)
          .single();
      if (mounted) {
        _phoneController.text = (resp['ContactNumber'] as String?) ?? '';
        _log.i('Telefonnummer erfolgreich geladen.');
      }
    } catch (e) {
      _log.e('Fehler beim Laden der Telefonnummer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Telefonnummer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }    }
  }

  /// Speichert die eingegebene Telefonnummer
  /// 
  /// Validiert das Formular und speichert die Telefonnummer über Supabase.
  /// Bei Erfolg wird eine grüne Bestätigung angezeigt, bei Fehlern eine rote Meldung.
  Future<void> _savePhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;
    if (User.id == null) {
      _log.w('Benutzer nicht angemeldet. Speichern nicht möglich.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Benutzer nicht angemeldet. Speichern nicht möglich.')),
      );
      return;
    }
    final phone = _phoneController.text.trim();
    _log.i('Speichere Telefonnummer für User ID: ${User.id}');
    try {
      await supabase
          .from('User')
          .update({'ContactNumber': phone}).eq('UserID', User.id!);
      if (mounted) {
        _log.i('Telefonnummer erfolgreich gespeichert.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Telefonnummer gespeichert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _log.e('Fehler beim Speichern der Telefonnummer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _log.i('SettingsPage disposed.');
    _phoneController.dispose();    super.dispose();
  }

  /// Erstellt ein einheitliches Design für Einstellungs-ListTiles
  /// 
  /// [icon] - Das anzuzeigende Icon
  /// [title] - Der Titel der Einstellung
  /// [onTap] - Callback-Funktion beim Antippen
  /// 
  /// Rückgabe: Styled ListTile Widget für die Einstellungsliste
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlueAccent, size: 28),
      title:
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
      trailing:
      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
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
          'Einstellungen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF141212),
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
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.lightBlueAccent))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notfall-Nummer',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formWidth),
                child: TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: '+43 123 4567890',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF505050),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Colors.lightBlueAccent,
                      size: 25,
                    ),
                  ),
                  style:
                  const TextStyle(color: Colors.white, fontSize: 16),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Bitte geben Sie eine Telefonnummer ein.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints:
                BoxConstraints(maxWidth: formWidth, minHeight: 48),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _savePhoneNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.lightBlueAccent.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    child: const Text(
                      'Notfall-Nummer speichern',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Divider(
                  color: Colors.white24, height: 30, thickness: 0.5),
              const SizedBox(height: 15),
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Benutzername ändern',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ChangeUsernamePage()),
                  );
                },
              ),
              const Divider(
                  color: Colors.white24, height: 1, thickness: 0.5),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Passwort ändern',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}