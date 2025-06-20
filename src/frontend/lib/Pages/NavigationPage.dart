import 'package:HikeMate/Class/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../Class/Logging.dart';
import '../Class/LocationTracker.dart';
import '../Class/TrackingStorage.dart';
import '../Class/supabase_client.dart';
import '../Class/Activity.dart';

/// GPS-Navigations- und Tracking-Seite der HikeMate App
/// 
/// Diese Seite ist das Herzstück der Wanderfunktionalität. Sie bietet
/// GPS-Tracking, Kartenansicht und Aufzeichnung von Wanderungen.
/// 
/// Features:
/// - Interaktive Karte mit aktueller Position
/// - GPS-Tracking mit Start/Stop-Funktionalität
/// - Aufzeichnung von Distanz, Höhenmetern und Zeit
/// - Anzeige des zurückgelegten Pfades auf der Karte
/// - Speicherung von Tracking-Daten zwischen App-Sessions
/// - Hintergrund-Tracking (App läuft auch bei geschlossenem Bildschirm)
/// - Speichern abgeschlossener Wanderungen als Aktivitäten
class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

/// State-Klasse für die NavigationPage mit GPS- und Karten-Management
class _NavigationPageState extends State<NavigationPage> {
  /// Logger für diese Seite
  final _log = LoggingService();
  
  /// Controller für die Kartenansicht
  final MapController _mapController = MapController();
  
  /// Service für GPS-Tracking und Datenaufzeichnung
  late TrackingService _trackingService;

  @override
  void initState() {
    super.initState();
    _log.i('NavigationPage initState');
    _trackingService = TrackingService();

    // Lauscht auf Updates vom TrackingService für UI-Aktualisierungen
    _trackingService.onUpdate.listen((_) {
      if (mounted) setState(() {});
    });

    // Lädt gespeicherten Tracking-Status und setzt ggf. Tracking fort
    TrackingStorage().loadTrackingState().then((isTracking) async {
      _log.i('Geladener Tracking-Status: $isTracking');
      if (isTracking) {
        _log.i('Tracking wird fortgesetzt.');
        await _trackingService.start();
      } else {
        _log.i('Lade gespeicherte Tracking-Daten.');
        TrackingStorage().loadTrackingData().then((data) {
          _trackingService.totalDistance = data['totalDistance'];
          _trackingService.totalAscent = data['totalAscent'];
          _trackingService.path
            ..clear()
            ..addAll(data['path']);
          return TrackingStorage().loadTrackingDuration();
        }).then((duration) {
          _trackingService.duration = duration;
          if (mounted) setState(() {});
          _log.i('Gespeicherte Daten geladen.');
        });
      }
      if (mounted) setState(() {});
    });

    _moveToCurrentLocation();
  }

  @override
  void dispose() {
    _log.i('NavigationPage disposed.');
    super.dispose();
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      _log.i('Verschiebe zu aktueller Position: ${pos.latitude}, ${pos.longitude}');
      _mapController.move(
        LatLng(pos.latitude, pos.longitude),
        14.0,
      );
    } catch (e, st) {
      _log.e('Fehler beim Abrufen der aktuellen Position', e, st);
    }
  }

  void _toggleTracking() {
    if (_trackingService.isTracking) {
      _log.i('Tracking wird gestoppt.');
      TrackingStorage().saveTrackingData(
        _trackingService.totalDistance,
        _trackingService.totalAscent,
        _trackingService.path,
      );
      TrackingStorage().saveTrackingDuration(_trackingService.duration);
      TrackingStorage().saveTrackingState(false);
      _showSaveOrDiscardDialog();
      _trackingService.stop();
    } else {
      _log.i('Tracking wird gestartet.');
      _trackingService.totalDistance = 0;
      _trackingService.totalAscent = 0;
      _trackingService.duration = Duration.zero;
      _trackingService.path.clear();

      TrackingStorage().saveTrackingState(true);
      _trackingService.start();
    }

    setState(() {});
  }

  String _formatAltitude(double altitude) => "${altitude.toStringAsFixed(0)} m";
  String _formatDistance(double distance) => "${distance.toInt()} m";
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }

  void _showSaveOrDiscardDialog() {
    _log.i('Zeige Speichern/Verwerfen-Dialog.');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Aktivität beenden',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Möchten Sie die Aktivität speichern oder verwerfen?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _discardActivity();
              },
              child: const Text(
                'Verwerfen',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveActivity();
              },
              child: const Text(
                'Speichern',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  void _discardActivity() {
    _log.i('Aktivität wird verworfen.');
    _trackingService.isTracking = false;
    setState(() {});
  }

  void _saveActivity() async {
    _log.i('Versuche, Aktivität zu speichern.');
    try {

      double gewicht = 70;
      double distanzKm = _trackingService.totalDistance / 1000.0;
      double calories = gewicht * distanzKm * 0.9;

      await supabase.from('Activity').insert({
        'UserID': User.id,
        'Distance': _trackingService.totalDistance,
        'Increase': _trackingService.totalAscent,
        'Duration': _trackingService.duration.inSeconds,
        'Date': DateTime.now().toIso8601String(),
        'Calories': calories.round(),
      });
      _log.i('Aktivität erfolgreich in Supabase gespeichert.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivität erfolgreich gespeichert')),
      );
    } catch (e, st) {
      _log.e('Fehler beim Speichern der Aktivität', e, st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern der Aktivität: $e')),
      );
    }

    _trackingService.isTracking = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(0, 0),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tiles.bergfex.at/styles/bergfex-osm/{z}/{x}/{y}.jpg',
                userAgentPackageName: 'com.example.app',
                retinaMode: RetinaMode.isHighDensity(context),
                maxZoom: 19,
              ),
              CurrentLocationLayer(),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _trackingService.path,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),

          if (!_trackingService.isTracking)
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _toggleTracking,
                  child: const Text(
                    'Tracking starten',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ),

          if (!_trackingService.isTracking)
            Positioned(
              bottom: 7,
              right: 10,
              child: SizedBox(
                width: 45,
                height: 45,
                child: ElevatedButton(
                  onPressed: _moveToCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(10),
                  ),
                  child:
                  const Icon(Icons.my_location, color: Colors.white, size: 20),
                ),
              ),
            ),

          if (_trackingService.isTracking)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 190,
                width: double.infinity,
                color: const Color(0xFF1E1E1E),
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            _buildInfoBox(
                                'Dauer', _formatDuration(_trackingService.duration)),
                            const SizedBox(height: 5),
                            _buildInfoBox('Anstieg',
                                _formatAltitude(_trackingService.totalAscent)),
                          ],
                        ),
                        Column(
                          children: [
                            _buildInfoBox('Distanz',
                                _formatDistance(_trackingService.totalDistance)),
                            const SizedBox(height: 5),
                            _buildInfoBox('Seehöhe',
                                _formatAltitude(_trackingService.altitude)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Center(
                      child: SizedBox(
                        width: 230,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _toggleTracking,
                          child: const Text(
                            'Tracking beenden',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_trackingService.isTracking)
            Positioned(
              top: 40,
              right: 10,
              child: SizedBox(
                width: 45,
                height: 45,
                child: ElevatedButton(
                  onPressed: _moveToCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(10),
                  ),
                  child:
                  const Icon(Icons.my_location, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String value) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      width: deviceWidth / 2 - 15,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
            Text(value,
                style: const TextStyle(
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}