import 'package:flutter/material.dart';
import 'NavigationPage.dart';
import 'WeatherPage.dart';
import 'ProfilePage.dart';
import 'SearchMountainPage.dart';
import 'DonePage.dart';

/// Hauptseite der HikeMate App mit Tab-Navigation
/// 
/// Diese Seite dient als zentraler Hub der Anwendung nach dem Login.
/// Sie stellt eine Bottom-Navigation-Bar bereit, über die Benutzer
/// zwischen den verschiedenen Hauptfunktionen der App wechseln können.
/// 
/// Verfügbare Tabs:
/// - Suche: Berg-Suchfunktion
/// - Wetter: Wetter-Informationen
/// - Navigation: GPS-Tracking und Wandernavigation
/// - Profil: Benutzer-Profilverwaltung
/// - Erledigt: Liste der absolvierten Berge
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State-Klasse für die HomePage mit Tab-Management
class _HomePageState extends State<HomePage> {
  /// Index des aktuell ausgewählten Tabs
  int _selectedIndex = 0;

  /// Liste aller verfügbaren Seiten/Tabs
  static const List<Widget> _pages = [
    SearchMountainPage(),  // Tab 0: Berg-Suche
    WeatherPage(),         // Tab 1: Wetter
    NavigationPage(),      // Tab 2: GPS-Navigation
    ProfilePage(),         // Tab 3: Benutzerprofil
    DonePage(),           // Tab 4: Erledigte Berge
  ];

  /// Behandelt Tab-Wechsel in der Bottom-Navigation
  /// 
  /// [index] - Index des ausgewählten Tabs (0-4)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double tabWidth = screenWidth / 5;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Stack(
          children: [
            Positioned.fill(
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.cloud), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.navigation), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.checklist), label: ''),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 0,
              left: _selectedIndex * tabWidth + tabWidth * 0.1,
              child: Container(
                width: tabWidth * 0.8,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}