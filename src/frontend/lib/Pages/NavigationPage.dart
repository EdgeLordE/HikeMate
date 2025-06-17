import 'package:HikeMate/Class/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../Class/LocationTracker.dart';
import '../Class/TrackingStorage.dart';
import '../Class/supabase_client.dart';
import '../Class/Activity.dart';


class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final MapController _mapController = MapController();
  late TrackingService _trackingService;

  @override
  void initState() {
    super.initState();
    _trackingService = TrackingService();

    _trackingService.onUpdate.listen((_) {
      if (mounted) setState(() {});
    });

    TrackingStorage().loadTrackingState().then((isTracking) async {
      if (isTracking) {
        await _trackingService.start();
      } else {
        TrackingStorage().loadTrackingData().then((data) {
          _trackingService.totalDistance = data['totalDistance'];
          _trackingService.totalAscent = data['totalAscent'];
          _trackingService.path
            ..clear()
            ..addAll(data['path']);
          return TrackingStorage().loadTrackingDuration();
        }).then((duration) {
          _trackingService.duration = duration;
          setState(() {});
        });
      }
      setState(() {});
    });

    _moveToCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _moveToCurrentLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    _mapController.move(
      LatLng(pos.latitude, pos.longitude),
      14.0,
    );
  }

  void _toggleTracking() {
    if (_trackingService.isTracking) {
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
    _trackingService.isTracking = false;
    setState(() {});
  }

  void _saveActivity() async {
    try {
      // Beispielhafte Berechnung: 0.9 kcal pro kg pro km, 70kg angenommen
      // Du kannst Gewicht und Formel nach Bedarf anpassen!
      double gewicht = 70; // kg, ggf. dynamisch holen
      double distanzKm = _trackingService.totalDistance / 1000.0; // Meter zu km
      double calories = gewicht * distanzKm * 0.9;

      await supabase.from('Activity').insert({
        'UserID': User.id,
        'Distance': _trackingService.totalDistance,
        'Increase': _trackingService.totalAscent,
        'Duration': _trackingService.duration.inSeconds,
        'Date': DateTime.now().toIso8601String(),
        'Calories': calories.round(), // als ganze Zahl speichern
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivität erfolgreich gespeichert')),
      );
    } catch (e) {
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
              initialCenter: LatLng(0, 0), // initialCenter statt center
              initialZoom: 14.0, // initialZoom statt zoom
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

          // SOS-Button wurde entfernt

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