// lib/sayfalar/deprem.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:http/http.dart' as http;
import 'dart:convert';

class DepremHaritaPage extends StatefulWidget {
  const DepremHaritaPage({Key? key}) : super(key: key);

  @override
  _DepremHaritaPageState createState() => _DepremHaritaPageState();
}

class _DepremHaritaPageState extends State<DepremHaritaPage> {
  final MapController _mapController = MapController();
  List<Earthquake> _quakes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuakes();
    // Set initial position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(latlng.LatLng(39.0, 35.0), 5.5);
    });
  }

  Future<void> _fetchQuakes() async {
    final now = DateTime.now().toUtc();
    final yesterday = now.subtract(const Duration(hours: 24));
    final url = Uri.parse(
      'https://earthquake.usgs.gov/fdsnws/event/1/query'
      '?format=geojson'
      '&minlatitude=36.0&maxlatitude=42.5'
      '&minlongitude=25.0&maxlongitude=45.0'
      '&minmagnitude=2.5'
      '&starttime=${yesterday.toIso8601String()}',
    );
    final res = await http.get(url);
    final data = json.decode(res.body) as Map<String, dynamic>;
    setState(() {
      _quakes = (data['features'] as List)
          .map((e) => Earthquake.fromJson(e as Map<String, dynamic>))
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Türkiye’deki Son Depremler')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(), // Removed initial position
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _quakes.map((q) {
                    return Marker(
                      point: q.location,
                      width: 40,
                      height: 40,
                      builder: (context) => Icon( // Changed to builder
                        Icons.location_on,
                        color: Color.fromRGBO(255, 0, 0, 0.7),
                        size: 30 + q.magnitude * 2,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
      bottomSheet: _loading
          ? null
          : Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 4)],
              ),
              child: ListView.builder(
                itemCount: _quakes.length,
                itemBuilder: (ctx, i) {
                  final q = _quakes[i];
                  return ListTile(
                    leading: Text(
                      q.magnitude.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text(q.place),
                    subtitle: Text('${q.time.toLocal()}'),
                    onTap: () => _mapController.move(q.location, 7.0),
                  );
                },
              ),
            ),
    );
  }
}

class Earthquake {
  final String id;
  final double magnitude;
  final String place;
  final DateTime time;
  final latlng.LatLng location;

  Earthquake({
    required this.id,
    required this.magnitude,
    required this.place,
    required this.time,
    required this.location,
  });

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>;
    final coords =
        (json['geometry'] as Map<String, dynamic>)['coordinates'] as List;
    return Earthquake(
      id: json['id'] as String,
      magnitude: (props['mag'] ?? 0).toDouble(),
      place: props['place'] as String? ?? 'Unknown',
      time: DateTime.fromMillisecondsSinceEpoch(props['time'] as int),
      location: latlng.LatLng(
        coords[1].toDouble(),
        coords[0].toDouble(),
      ),
    );
  }
}