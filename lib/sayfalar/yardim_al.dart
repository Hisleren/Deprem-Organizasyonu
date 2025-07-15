import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class YardimAl extends StatefulWidget {
  const YardimAl({super.key});

  @override
  State<YardimAl> createState() => _YardimAlState();
}

class _YardimAlState extends State<YardimAl> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _aciklama = '';
  bool _konumYukleniyor = false;

  Future<void> _konumGonder() async {
    setState(() {
      _konumYukleniyor = true;
    });

    try {
      // Konum izni kontrolü
      LocationPermission izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
        if (izin == LocationPermission.denied) {
          throw Exception("Konum izni reddedildi.");
        }
      }

      // Konum al
      Position konum = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception("Kullanıcı oturum açmamış.");

      final kullaniciDoc =
          await _firestore.collection('kullanicilar').doc(uid).get();

      final kullanici = kullaniciDoc.data();
      if (kullanici == null) throw Exception("Kullanıcı bilgisi bulunamadı.");

      await _firestore.collection('yardim_istekleri').add({
        'uid': uid,
        'ad': kullanici['ad'],
        'soyad': kullanici['soyad'],
        'aciklama': _aciklama,
        'konum': {
          'lat': konum.latitude,
          'lng': konum.longitude,
        },
        'tarih': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yardım çağrısı gönderildi!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _konumYukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
        title: const Text("Yardım Al"),
        backgroundColor: Theme.of(context).colorScheme.primary);
    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Açıklama (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (v) => _aciklama = v,
            ),
            const SizedBox(height: 20),
            _konumYukleniyor
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _konumGonder,
                    icon: const Icon(Icons.warning),
                    label: const Text('YARDIM ÇAĞIR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
