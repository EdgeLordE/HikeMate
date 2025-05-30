import 'package:HikeMate/Pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
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
        final response = await supabase.from('User').insert({
          'FirstName': firstNameController.text,
          'LastName': lastNameController.text,
          'Username': usernameController.text,
          'Password':  BCrypt.hashpw(passwordController.text, BCrypt.gensalt()),
        }).execute();

        final response_get = await supabase
            .from('User')
            .select()
            .eq('Username', usernameController.text)
            .maybeSingle();

        if (response_get != null){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }


      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
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
      body: Center(
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
            Align(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300, minWidth: 300),
                child: TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF505050),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_2,
                      color: Colors.lightBlueAccent,
                      size: 25,
                    ),
                    hintText: 'Vorname',
                    hintStyle: const TextStyle(color: Colors.white54),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Align(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300, minWidth: 300),
                child: TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF505050),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_2,
                      color: Colors.lightBlueAccent,
                      size: 25,
                    ),
                    hintText: 'Nachname',
                    hintStyle: const TextStyle(color: Colors.white54),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Align(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300, minWidth: 300),
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
            ),
            const SizedBox(height: 25),
            Align(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300, minWidth: 300),
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
    );
  }
}