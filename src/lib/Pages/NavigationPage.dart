import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

Future<Position?> _checkAndRequestPermissions() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Standortdienste sind deaktiviert.');
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Standortberechtigung verweigert.');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('Standortberechtigung dauerhaft verweigert.');
    return null;
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

class _NavigationPageState extends State<NavigationPage> {
  final MapController _mapController = MapController();
  double _altitude = 0.0;
  double _totaldistance = 0.0;
  double _totalAscent = 0.0;
  LatLng? _previousPosition;
  double? _previousAltitude;
  bool _isTracking = false;
  Duration _duration = Duration.zero;
  Timer? _timer;
  Timer? _altitudeTimer;
  List<LatLng> _path = [];
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _moveToCurrentLocation();
  }

  void _toggleTracking() {
    setState(() {
      if (_isTracking) {
        _isTracking = false;
        _timer?.cancel();
        _timer = null;

        _altitudeTimer?.cancel();
        _altitudeTimer = null;

        _positionStream?.cancel();
        _positionStream = null;
      } else {
        _isTracking = true;
        _duration = Duration.zero;

        _totalAscent = 0.0;
        _totaldistance = 0.0;
        _previousAltitude = null;
        _previousPosition = null;



        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _duration += const Duration(seconds: 1);
          });
        });

        // Start tracking positions
        _positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // Update every 5 meters
          ),
        ).listen((Position position) {
          setState(() {
            final currentPosition = LatLng(position.latitude, position.longitude);
            _path.add(currentPosition);

            if (_previousPosition != null){
              final distance = Distance().as(
                LengthUnit.Meter,
                _previousPosition!,
                currentPosition,
              );
              _totaldistance += distance;
            }
            _previousPosition = currentPosition;

            if (_previousAltitude != null && position.altitude > _previousAltitude!) {
              _totalAscent += (position.altitude - _previousAltitude!);
            }
            _previousAltitude = position.altitude;
          });
        });
      }
    });

    _altitudeTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      Position? position = await _checkAndRequestPermissions();
      setState(() {
        if (position == null) {
          return;
        }
        _altitude = position.altitude;
      });
    });
  }

  Future<void> _moveToCurrentLocation() async {
    Position? position = await _checkAndRequestPermissions();
    if (position != null) {
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        14.0,
      );
    }
  }

  String _formatAltitude(double altitude) {
    return "${altitude.toStringAsFixed(0)} m";
  }

  String _formatDistance(double distance) {
    return "${distance.toInt()} m";
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _altitudeTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(0, 0),
              zoom: 14.0,
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
                    points: _path,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          if (!_isTracking)
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _toggleTracking,
                  child: const Text(
                    'Tracking starten',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 7,
            right: 10,
            child: Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 45,
                height: 45,
                child: ElevatedButton(
                  onPressed: _moveToCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          if (_isTracking)
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
                            _buildInfoBox('Dauer', _formatDuration(_duration)),
                            const SizedBox(height: 5),
                            _buildInfoBox('Anstieg', _formatAltitude(_totalAscent)),
                          ],
                        ),
                        Column(
                          children: [
                            _buildInfoBox('Distanz', _formatDistance(_totaldistance)),
                            const SizedBox(height: 5),
                            _buildInfoBox(
                                'Seehöhe', _formatAltitude(_altitude)),
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _toggleTracking,
                          child: const Text(
                            'Tracking beenden',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

