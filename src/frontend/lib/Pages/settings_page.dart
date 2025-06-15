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
    try {
      final resp = await supabase
          .from('User')
          .select('ContactNumber')
          .eq('UserID', User.id)
          .single();
      _phoneController.text = (resp['ContactNumber'] as String?) ?? '';
    } catch (e) {
      debugPrint('Fehler beim Laden der Telefonnummer: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _savePhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = _phoneController.text.trim();
    try {
      await supabase
          .from('User')
          .update({'ContactNumber': phone})
          .eq('UserID', User.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefonnummer gespeichert')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e')),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Einstellungen')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1F1F1F),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Notfall-Nummer', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '+43...',
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty) ? 'Bitte Nummer eingeben' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _savePhoneNumber,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
                child: const Text('Speichern', style: TextStyle(color: Colors.white)),
              ),
              const Divider(color: Colors.white24, height: 32),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Benutzername ändern', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChangeUsernamePage()),
                  );
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.white),
                title: const Text('Passwort ändern', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
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
