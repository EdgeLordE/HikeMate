import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../Class/Logging.dart';

/// Wetter-Seite der HikeMate App
/// 
/// Diese Seite zeigt aktuelle Wetterdaten und Wettervorhersagen an.
/// Sie kann Wetter sowohl für den aktuellen GPS-Standort als auch
/// für manuell eingegebene Orte anzeigen.
/// 
/// Features:
/// - Automatisches Laden des Wetters für aktuellen Standort
/// - Manuelle Ortssuche mit Eingabefeld
/// - Aktuelle Wetterdaten (Temperatur, Beschreibung, etc.)
/// - 5-Tage Wettervorhersage gruppiert nach Tagen
/// - Integration mit OpenWeatherMap API
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

/// State-Klasse für die WeatherPage mit Wetter-API Management
class _WeatherPageState extends State<WeatherPage> {
  /// Logger für diese Seite
  final _log = LoggingService();
  
  /// Controller für das Orts-Eingabefeld
  final TextEditingController _controller = TextEditingController();
  
  /// API-Schlüssel für OpenWeatherMap
  final String apiKey = 'b8fe09709a738c0e8f4412b7a7376bb9';

  /// Aktuelle Wetterdaten
  Map<String, dynamic>? currentWeather;
  
  /// Wettervorhersage gruppiert nach Tagen
  Map<String, List<Map<String, dynamic>>> groupedForecast = {};

  @override
  void initState() {
    super.initState();
    _log.i('WeatherPage initState');
    fetchWeatherByLocation();
  }

  @override
  void dispose() {
    _log.i('WeatherPage disposed.');
    _controller.dispose();
    super.dispose();
  }

  /// Lädt Wetterdaten für den aktuellen GPS-Standort
  /// 
  /// Diese Methode wird automatisch beim Seitenaufruf ausgeführt
  /// und fordert GPS-Berechtigungen an falls nötig.
  Future<void> fetchWeatherByLocation() async {
    _log.i('Versuche, Wetterdaten für den aktuellen Standort abzurufen.');
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Standortdienste sind deaktiviert');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Standortberechtigung verweigert');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);

      if (!mounted) return;

      final coordUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=de');
      final response = await http.get(coordUrl);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final city = data['name'] as String;
        _log.i('Standort erfolgreich ermittelt: $city. Rufe Wetterdaten ab.');
        _controller.text = city;
        await fetchWeather(city);
      } else {
        _log.w(
            'Fehler beim Ermitteln des Standorts via Koordinaten. Status: ${response.statusCode}');
        throw Exception('Fehler beim Ermitteln des Standorts');
      }
    } catch (e) {
      _log.e('Standortfehler: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Standortfehler: ${e.toString()}')),
      );
    }  }

  /// Lädt Wetterdaten für eine bestimmte Stadt
  /// 
  /// [city] - Name der Stadt für die das Wetter abgerufen werden soll
  /// 
  /// Diese Methode:
  /// - Ruft aktuelle Wetterdaten von OpenWeatherMap API ab
  /// - Ruft 5-Tage-Wettervorhersage ab
  /// - Gruppiert Vorhersagedaten nach Tagen
  /// - Aktualisiert die UI mit den neuen Daten
  /// - Behandelt Fehler mit Benutzer-Feedback
  Future<void> fetchWeather(String city) async {
    _log.i('Rufe Wetterdaten für "$city" ab.');
    try {
      final currentUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=de');
      final forecastUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=de');

      final currentResponse = await http.get(currentUrl);
      final forecastResponse = await http.get(forecastUrl);

      if (!mounted) return;

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        Map<String, List<Map<String, dynamic>>> forecastByDay = {};
        for (var entry in forecastData['list'] as List) {
          final date = DateTime.parse(entry['dt_txt'] as String);
          final dayKey =
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          forecastByDay.putIfAbsent(dayKey, () => []).add({
            'time': "${date.hour.toString().padLeft(2, '0')}:00",
            'temp': (entry['main']['temp'] as num).round(),
            'icon': entry['weather'][0]['icon'],
            'desc': entry['weather'][0]['description'],
          });
        }

        setState(() {
          currentWeather = currentData;
          groupedForecast = forecastByDay;
        });
        _log.i('Wetterdaten für "$city" erfolgreich geladen und verarbeitet.');
      } else {
        _log.w(
            'Fehler beim Laden der Wetterdaten für "$city". Status: Current=${currentResponse.statusCode}, Forecast=${forecastResponse.statusCode}');
        throw Exception('Fehler beim Laden der Wetterdaten');
      }
    } catch (e) {
      _log.e('Fehler beim Abrufen der Wetterdaten für "$city": $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: ${e.toString()}')),
      );
    }
  }

  Widget buildForecast() {
    if (groupedForecast.isEmpty) {
      return const Center(
          child: Text("Keine Vorhersage verfügbar",
              style: TextStyle(color: Colors.white)));
    }

    final todayKey = groupedForecast.keys.first;
    final today = groupedForecast[todayKey]!;

    final allOthers = groupedForecast.entries.skip(1).toList();
    if (allOthers.length > 1) {
      allOthers.removeLast();
    }
    final others = allOthers;

    const weekdays = ['Mo -', 'Di -', 'Mi -', 'Do -', 'Fr -', 'Sa -', 'So -'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text("Heute",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: today
                .map((e) => ListTile(
              leading: Image.network(
                  'https://openweathermap.org/img/wn/${e['icon']}@2x.png'),
              title: Text("${e['time']} - ${e['desc']}",
                  style: const TextStyle(color: Colors.white)),
              trailing: Text("${e['temp']}°",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18)),
            ))
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        const Text("Nächste Tage",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...others.map((dayEntry) {
          final day = dayEntry.key;
          final list = dayEntry.value;
          final date = DateTime.parse(day);
          final weekday = weekdays[date.weekday - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$weekday $day',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: list
                          .map((e) => Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Text(e['time'],
                                style: const TextStyle(
                                    color: Colors.white70)),
                            Image.network(
                                'https://openweathermap.org/img/wn/${e['icon']}@2x.png',
                                width: 50),
                            Text("${e['temp']}°",
                                style:
                                const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ))
                          .toList(),
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: TextField(
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
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    fetchWeather(value.trim());
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                final city = _controller.text.trim();
                if (city.isNotEmpty) {
                  fetchWeather(city);
                }
              },
            )
          ],
        ),
      ),
      body: currentWeather == null
          ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.lightBlueAccent),
              SizedBox(height: 16),
              Text("Standort wird verwendet...",
                  style: TextStyle(color: Colors.white)),
            ],
          ))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  'https://openweathermap.org/img/wn/${currentWeather!["weather"][0]["icon"]}@2x.png',
                  width: 80,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentWeather!["name"] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${(currentWeather!["main"]["temp"] as num).round()}°",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentWeather!["weather"][0]["description"]
                        as String,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 18),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            buildForecast(),
          ],
        ),
      ),
    );
  }
}