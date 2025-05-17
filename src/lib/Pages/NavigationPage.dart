import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(47.3769, 8.5417),
          zoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tiles.bergfex.at/styles/bergfex-osm/{z}/{x}/{y}.jpg',
            userAgentPackageName: 'com.example.app',
            retinaMode: RetinaMode.isHighDensity(context),
            maxZoom: 19,
          ),
          CurrentLocationLayer(),
        ],
      ),
    );
  }
}