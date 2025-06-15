import 'package:flutter/material.dart';
import 'ChangeUsernamePage.dart';
import 'ChangePasswordPage.dart';
import '../Class/supabase_client.dart';
import '../Class/User.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
  }

  Future<void> _loadPhoneNumber() async {
    if (User.id == null) {
      // Handle case where User.id is null, maybe show an error or log out
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Benutzer nicht angemeldet.')),
        );
        setState(() => _loading = false);
      }
      return;
    }
    try {
      final resp = await supabase
          .from('User')
          .select('ContactNumber')
          .eq('UserID', User.id!)
          .single();
      if (mounted) {
        _phoneController.text = (resp['ContactNumber'] as String?) ?? '';
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Fehler beim Laden der Telefonnummer: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Telefonnummer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _savePhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;
    if (User.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Benutzer nicht angemeldet. Speichern nicht möglich.')),
      );
      return;
    }
    final phone = _phoneController.text.trim();
    try {
      await supabase
          .from('User')
          .update({'ContactNumber': phone})
          .eq('UserID', User.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Telefonnummer gespeichert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
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
    _phoneController.dispose();
    super.dispose();
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlueAccent, size: 28),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0), // Angepasstes Padding
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
          'Einstellungen',
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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.lightBlueAccent))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), // Einheitliches Padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notfall-Nummer',
                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
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
                    fillColor: const Color(0xFF505050), // Passend zu anderen Textfeldern
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Abgerundete Ecken
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Colors.lightBlueAccent,
                      size: 25,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Bitte geben Sie eine Telefonnummer ein.';
                    }
                    // Optional: Weitere Validierungen für Telefonnummern
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formWidth, minHeight: 48),
                child: SizedBox(
                  width: double.infinity, // Nimmt die Breite von formWidth ein
                  child: ElevatedButton(
                    onPressed: _savePhoneNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40), // Stark abgerundet
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    child: const Text(
                      'Notfall-Nummer speichern',
                      style: TextStyle(
                        fontSize: 18, // Etwas kleiner als Login/Register Button
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Divider(color: Colors.white24, height: 30, thickness: 0.5),
              const SizedBox(height: 15),

              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Benutzername ändern',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChangeUsernamePage()),
                  );
                },
              ),
              const Divider(color: Colors.white24, height: 1, thickness: 0.5), // Angepasster Divider
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Passwort ändern',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                  );
                },
              ),
              // Weitere ListTiles können hier mit Dividers hinzugefügt werden
            ],
          ),
        ),
      ),
    );
  }
}