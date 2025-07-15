import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:cloud_firestore/cloud_firestore.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final MapController _mapController = MapController();
  final CollectionReference<Map<String, dynamic>> _markersRef =
      FirebaseFirestore.instance.collection('map_markers');

  bool _satellite = false;
  bool _addingMode = false;
  final latlng.LatLng _initialCenter = latlng.LatLng(41.0082, 28.9784);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_initialCenter, 13.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harita'),
        actions: [
          IconButton(
            icon: Icon(_satellite ? Icons.map : Icons.satellite),
            onPressed: () => setState(() => _satellite = !_satellite),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _markersRef.snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Hata: ${snap.error}'));
          }

          final markers = snap.data!.docs.map((doc) {
            final data = doc.data();
            return Marker(
              point: latlng.LatLng(
                data['lat'] as double,
                data['lng'] as double,
              ),
              width: 50,
              height: 50,
              builder: (_) => GestureDetector(
                onTap: () => _openMarkerSheet(doc.id, data),
                child: Icon(
                  Icons.place,
                  size: 40,
                  color: _colorFromName(data['color'] as String),
                ),
              ),
            );
          }).toList();

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _initialCenter,
              zoom: 13.0,
              interactiveFlags:
                  InteractiveFlag.all & ~InteractiveFlag.rotate,
              onTap: (_, tapPos) async {
                if (_addingMode) {
                  setState(() => _addingMode = false);
                  final col = await _askForColor(context);
                  if (col != null) {
                    await _markersRef.add({
                      'lat': tapPos.latitude,
                      'lng': tapPos.longitude,
                      'color': col,
                      'text': '',
                    });
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _satellite
                    ? 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: _satellite ? [] : ['a', 'b', 'c'],
                tileProvider: NetworkTileProvider(
                  headers: {
                    'User-Agent':
                        'depremorganizasyonu/1.0 (email@example.com)',
                  },
                ),
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _addingMode = true),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_location_alt, color: Colors.white),
      ),
    );
  }

  void _openMarkerSheet(String docId, Map<String, dynamic> data) {
    final note = data['text'] as String? ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              readOnly: true,
              controller: TextEditingController(text: note),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: 'Not bulunmuyor',
                hintStyle: TextStyle(color: Colors.white38),
              ),
              onTap: () => _editNote(context, docId, note),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.white),
              title: const Text('İşareti Sil',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _deleteMarker(docId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette, color: Colors.white),
              title: const Text('Renk Değiştir',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _changeMarkerColor(context, docId, data['color'] as String);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Notu Düzenle',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _editNote(context, docId, note);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMarker(String docId) async {
    await _markersRef.doc(docId).delete();
  }

  Future<void> _changeMarkerColor(
      BuildContext ctx, String docId, String current) async {
    final newColor = await _askForColor(ctx, current: current);
    if (newColor != null) {
      await _markersRef.doc(docId).update({'color': newColor});
    }
  }

  Future<void> _editNote(
      BuildContext ctx, String docId, String currentNote) async {
    final controller = TextEditingController(text: currentNote);
    final updated = await showModalBottomSheet<String>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Not ekleyin...',
                  hintStyle: TextStyle(color: Colors.grey[700]),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('İptal', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                  child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (updated != null) {
      await _markersRef.doc(docId).update({'text': updated});
    }
  }

  Future<String?> _askForColor(BuildContext context, {String? current}) {
  const opts = ['Kırmızı', 'Turuncu', 'Sarı', 'Yeşil', 'Siyah'];
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text('Renk Seçin', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: opts
            .map((c) => RadioListTile<String>(
                  title: Text(c, style: const TextStyle(color: Colors.white)),
                  value: c,
                  groupValue: current,
                  activeColor: Colors.white, // Circle color when selected
                  onChanged: (val) => Navigator.pop(context, val),
                ))
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

  Color _colorFromName(String name) {
    switch (name) {
      case 'Kırmızı':
        return Colors.red;
      case 'Turuncu':
        return Colors.orange;
      case 'Sarı':
        return Colors.yellow;
      case 'Yeşil':
        return Colors.green;
      case 'Siyah':
        return Colors.black;
      default:
        return Colors.blue;
    }
  }
}