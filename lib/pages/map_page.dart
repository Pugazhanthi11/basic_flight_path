// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? fromCoord;
  LatLng? toCoord;
  List<LatLng> flightPath = [];
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      _loadCoordinates(args['from'], args['to']);
    }
  }

  // Get latitude and longitude from place name (Nominatim API)
  Future<LatLng?> _getLatLng(String place) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$place&format=json&limit=1');
    final res = await http.get(url, headers: {'User-Agent': 'flutter-flight-app'});
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data.isNotEmpty) {
        return LatLng(
          double.parse(data[0]['lat']),
          double.parse(data[0]['lon']),
        );
      }
    }
    return null;
  }

  Future<void> _loadCoordinates(String from, String to) async {
    final f = await _getLatLng(from);
    final t = await _getLatLng(to);
    setState(() {
      fromCoord = f;
      toCoord = t;
    });
    if (f != null && t != null) {
      await _fetchFlightPath(f, t);
    }
  }

  // Fetch nearby flights between two points using OpenSky
  Future<void> _fetchFlightPath(LatLng from, LatLng to) async {
    setState(() => loading = true);

    // Get bounding box between the two points
    final double minLat = [from.latitude, to.latitude].reduce((a, b) => a < b ? a : b);
    final double maxLat = [from.latitude, to.latitude].reduce((a, b) => a > b ? a : b);
    final double minLon = [from.longitude, to.longitude].reduce((a, b) => a < b ? a : b);
    final double maxLon = [from.longitude, to.longitude].reduce((a, b) => a > b ? a : b);

    final url = Uri.parse(
        'https://opensky-network.org/api/states/all?lamin=$minLat&lomin=$minLon&lamax=$maxLat&lomax=$maxLon');

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final states = data['states'] as List?;
        if (states != null && states.isNotEmpty) {
          flightPath = states.map<LatLng>((s) {
            return LatLng(s[6] ?? 0.0, s[5] ?? 0.0);
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("Error loading flight data: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (fromCoord != null && toCoord != null)
            FlutterMap(
              options: MapOptions(
                initialCenter: fromCoord!,
                initialZoom: 4.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flight_path',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [fromCoord!, toCoord!],
                      strokeWidth: 4,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: fromCoord!,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.flight_takeoff,
                          color: Colors.green, size: 40),
                    ),
                    Marker(
                      point: toCoord!,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.flight_land,
                          color: Colors.red, size: 40),
                    ),
                    ...flightPath.map((p) => Marker(
                          point: p,
                          width: 10,
                          height: 10,
                          child: const Icon(Icons.airplanemode_active,
                              size: 10, color: Colors.white),
                        )),
                  ],
                ),
              ],
            ),
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          Positioned(
            top: 40,
            left: 15,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
