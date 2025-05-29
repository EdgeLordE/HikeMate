import 'package:flutter/material.dart';
import 'HomePage.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Color(0xFF141212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child:  Text(
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
                constraints: const BoxConstraints(
                  maxWidth: 300,
                  minWidth: 300,

                ),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF505050),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.person_2, // Benutzer-Icon
                      color: Colors.lightBlueAccent,
                      size: 25,
                    ),
                    hintText: 'Vorname', // Optionaler Platzhaltertext
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Align(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                  minWidth: 300,

                ),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF505050),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.person_2, // Benutzer-Icon
                      color: Colors.lightBlueAccent,
                      size: 25,
                    ),
                    hintText: 'Nachname', // Optionaler Platzhaltertext
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Align(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                  minWidth: 300,

                ),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF505050),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.person, // Benutzer-Icon
                      color: Colors.lightBlueAccent,
                      size: 25,
                    ),
                    hintText: 'Benutzername', // Optionaler Platzhaltertext
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 25),


            Align(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                  minWidth: 300,

                ),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF505050),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.lock, // Benutzer-Icon
                      color: Colors.lightBlueAccent,
                      size: 25,
                    ),
                    hintText: 'Passwort', // Optionaler Platzhaltertext
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),


            const SizedBox(height: 55),
            Align(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 300,
                    minWidth: 300,
                    maxHeight: 48,
                    minHeight: 48,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent!.withOpacity(0.9),
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
                        )

                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}