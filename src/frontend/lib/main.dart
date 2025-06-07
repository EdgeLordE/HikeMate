import 'dart:io';

import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'Pages/LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await startRestApiServer();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HikeMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const LoginPage(),
    );
  }
}

Future<void> startRestApiServer() async {
  try {
    String pythonFilePath = '${Directory.current.path}src/frontend/lib/start_server.py';

    debugPrint('Aktuelles Verzeichnis: ${Directory.current.path}');

    Process process = await Process.start('python', [pythonFilePath]);

    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      debugPrint('Python stdout: $data');
    });

    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      debugPrint('Python stderr: $data');
    });
  } catch (e) {
    debugPrint('Fehler beim Starten des Python-Servers: $e');
  }
}