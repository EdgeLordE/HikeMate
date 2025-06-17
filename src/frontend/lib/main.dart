import 'dart:io';
import 'package:HikeMate/Pages/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'Pages/LoginPage.dart';
import 'Pages/ProfilePage.dart';
import 'Pages/emergency_page.dart';
import 'Pages/checkin_service.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await CheckInService().init();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HikeMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/profile': (_) => const ProfilePage(),
        '/emergency': (_) => const EmergencyPage(),
      },
    );
  }
}
