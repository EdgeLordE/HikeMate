import 'package:flutter/material.dart';
import 'Pages/NavigationPage.dart';

void main() {
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
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.lightBlueAccent,
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    Center(child: Text('Search', style: TextStyle(color: Colors.white))),
    Center(child: Text('Touren', style: TextStyle(color: Colors.white))),
    NavigationPage(),
    Center(child: Text('Profil', style: TextStyle(color: Colors.white))),
    Center(child: Text('Erfolge', style: TextStyle(color: Colors.white))),
  ];

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

        height: 60, // genug Platz für Balken + Icons
        child: Stack(
          children: [
            // eigentliche Navigation
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
              top: 0, // Position direkt innerhalb der Navigation Bar
              left: _selectedIndex * tabWidth + tabWidth * 0.1, // Zentrierung
              child: Container(
                width: tabWidth * 0.8, // Breite des Rechtecks
                height: 4, // Höhe des Rechtecks
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(5), // Abgerundete Ecken
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}