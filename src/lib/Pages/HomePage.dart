import 'package:flutter/material.dart';
import 'NavigationPage.dart';
import 'WeatherPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    Center(child: Text('Suche', style: TextStyle(color: Colors.white))),
    WeatherPage(),
    NavigationPage(),
    Center(child: Text('Profil', style: TextStyle(color: Colors.white))),
    Center(child: Text('DoneList', style: TextStyle(color: Colors.white))),
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