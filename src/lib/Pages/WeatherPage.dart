import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _controller = TextEditingController(text: 'Rankweil');
  final String apiKey = 'b8fe09709a738c0e8f4412b7a7376bb9';
  Map<String, dynamic>? currentWeather;
  List<Map<String, dynamic>> dailyForecast = [];

  Future<void> fetchWeather(String city) async {
    try {
      final currentUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=de');
      final forecastUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=de');

      final currentResponse = await http.get(currentUrl);
      final forecastResponse = await http.get(forecastUrl);

      if (currentResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        Map<String, List> days = {};
        for (var entry in forecastData['list']) {
          final date = DateTime.parse(entry['dt_txt']);
          final day = "${date.year}-${date.month}-${date.day}";
          days.putIfAbsent(day, () => []).add(entry);
        }

        List<Map<String, dynamic>> daily = [];
        final now = DateTime.now();
        days.forEach((key, value) {
          final day = DateTime.parse(value[0]['dt_txt']);
          if (day.day != now.day && daily.length < 4) {
            final temps = value.map((e) => e['main']['temp'] as double).toList();
            final avgTemp = temps.reduce((a, b) => a + b) / temps.length;
            final icon = value[0]['weather'][0]['icon'];
            daily.add({
              'date': day,
              'temp': avgTemp.round(),
              'icon': icon,
            });
          }
        });

        setState(() {
          currentWeather = currentData;
          dailyForecast = daily;
        });
      } else {
        throw Exception('Wetterdaten konnten nicht geladen werden');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF3A3A3A),
            hintText: 'Ort eingeben...',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => fetchWeather(_controller.text),
            ),
          ),
        ),
      ),
      body: currentWeather == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    currentWeather!['name'],
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  Image.network(
                    'https://openweathermap.org/img/wn/${currentWeather!['weather'][0]['icon']}@2x.png',
                    width: 80,
                    height: 80,
                  ),
                  Text(
                    "${currentWeather!['main']['temp'].round()}°",
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currentWeather!['weather'][0]['description'],
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  Text(
                    "H: ${currentWeather!['main']['temp_max'].round()}°  T: ${currentWeather!['main']['temp_min'].round()}°",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dailyForecast.map((day) {
                final date = day['date'] as DateTime;
                final icon = day['icon'];
                return Column(
                  children: [
                    Text(
                      "${["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"][date.weekday % 7]}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Image.network(
                      'https://openweathermap.org/img/wn/$icon.png',
                      width: 32,
                      height: 32,
                    ),
                    Text(
                      "${day['temp']}°",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
