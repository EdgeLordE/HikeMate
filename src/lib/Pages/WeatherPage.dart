import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Future<Map<String, dynamic>> fetchWeather() async {
    const apiKey = 'b8fe09709a738c0e8f4412b7a7376bb9';
    const city = 'Bregenz';
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=de');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Fehler beim Laden der Wetterdaten');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchWeather(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('Fehler beim Laden der Wetterdaten',
                  style: TextStyle(color: Colors.white)));
        } else if (snapshot.hasData) {
          final weather = snapshot.data!;
          final temp = weather['main']['temp'].toStringAsFixed(1);
          final desc = weather['weather'][0]['description'];
          final icon = weather['weather'][0]['icon'];
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://openweathermap.org/img/wn/$icon@2x.png',
                  width: 80,
                  height: 80,
                ),
                Text(
                  '$temp°C',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  desc.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          );
        } else {
          return const Center(
              child: Text('Keine Wetterdaten verfügbar',
                  style: TextStyle(color: Colors.white)));
        }
      },
    );
  }
}