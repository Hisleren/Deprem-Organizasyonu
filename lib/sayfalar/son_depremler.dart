import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SonDepremlerPage extends StatefulWidget {
  const SonDepremlerPage({Key? key}) : super(key: key);

  @override
  _SonDepremlerPageState createState() => _SonDepremlerPageState();
}

class _SonDepremlerPageState extends State<SonDepremlerPage> {
  List<Map<String, dynamic>> _earthquakes = [];
  bool _loading = true;
  bool _error = false;
  String _lastUpdate = '';

  // Fix Turkish character encoding
  String _fixTurkishEncoding(String input) {
    return input
      .replaceAll('ð', 'ğ')
      .replaceAll('ý', 'ı')
      .replaceAll('þ', 'ş')
      .replaceAll('Ý', 'İ')
      .replaceAll('Þ', 'Ş')
      .replaceAll('Ð', 'Ğ');
  }

  Future<void> _loadEarthquakes() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final response = await http.get(
        Uri.parse('http://www.koeri.boun.edu.tr/scripts/lst0.asp'),
      );

      if (response.statusCode == 200) {
        // Extract content from <pre> tag
        final startIndex = response.body.indexOf('<pre>') + 5;
        final endIndex = response.body.indexOf('</pre>', startIndex);
        final preContent = response.body.substring(startIndex, endIndex);
        
        final lines = preContent.split('\n');
        final List<Map<String, dynamic>> earthquakes = [];
        
        // Get current time in Turkey (UTC+3)
        final now = DateTime.now().toUtc().add(const Duration(hours: 3));
        final last24Hours = now.subtract(const Duration(hours: 24));
        _lastUpdate = DateFormat('dd.MM.yyyy HH:mm:ss').format(now);

        // Process lines starting from index 7
        for (int i = 7; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          
          try {
            // Split by multiple spaces
            final parts = line.split(RegExp(r'\s+'));
            if (parts.length < 9) continue;
            
            // Extract date and time
            final date = parts[0];
            final time = parts[1];
            
            // Parse numeric values
            final latitude = double.tryParse(parts[2]) ?? 0.0;
            final longitude = double.tryParse(parts[3]) ?? 0.0;
            final depth = double.tryParse(parts[4]) ?? 0.0;
            final magnitude = double.tryParse(parts[6]) ?? 0.0;
            
            // Extract location (combine remaining parts)
            final location = parts.sublist(8).join(' ');
            final fixedLocation = _fixTurkishEncoding(location);
            
            // Parse earthquake datetime (Turkey time UTC+3)
            final dateTimeStr = '${date.replaceAll('.', '-')} $time';
            final quakeTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStr);
            
            // Only include earthquakes from last 24 hours
            if (quakeTime.isAfter(last24Hours)) {
              earthquakes.add({
                'dateTime': quakeTime,
                'latitude': latitude,
                'longitude': longitude,
                'depth': depth,
                'magnitude': magnitude,
                'location': fixedLocation,
              });
            }
          } catch (e) {
            // Skip invalid entries
            continue;
          }
        }

        // SORT BY TIME - NEWEST FIRST (most recent at top)
        earthquakes.sort((a, b) => b['dateTime'].compareTo(a['dateTime']));

        setState(() {
          _earthquakes = earthquakes;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm:ss').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _loadEarthquakes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Son Depremler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEarthquakes,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_loading && !_error && _earthquakes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Son Güncelleme: $_lastUpdate',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Veri alınamadı', style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadEarthquakes,
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : _earthquakes.isEmpty
                        ? const Center(
                            child: Text(
                              'Son 24 saatte deprem kaydedilmedi',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            // Reverse order to show newest at top
                            itemCount: _earthquakes.length,
                            itemBuilder: (context, index) {
                              final quake = _earthquakes[index];
                              final mag = quake['magnitude'] ?? 0.0;
                              final depth = quake['depth'] ?? 0.0;
                              final location = quake['location'] ?? 'Bilinmeyen Lokasyon';
                              final date = _formatDateTime(quake['dateTime']);

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                elevation: 2,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getMagnitudeColor(mag),
                                    radius: 22,
                                    child: Text(
                                      mag.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    location,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      Text('Büyüklük: ${mag.toStringAsFixed(1)}'),
                                      Text('Derinlik: ${depth.toStringAsFixed(1)} km'),
                                      Text('Tarih: $date'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Color _getMagnitudeColor(double mag) {
    if (mag < 2.0) return Colors.green;
    if (mag < 3.0) return Colors.lightGreen;
    if (mag < 4.0) return Colors.orange;
    if (mag < 5.0) return Colors.deepOrange;
    return Colors.red;
  }
}