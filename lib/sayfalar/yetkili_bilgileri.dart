import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YetkiliBilgileri extends StatelessWidget {
  const YetkiliBilgileri({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tüm Kullanıcılar')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kullanicilar')
            .orderBy('ad')           // istersen ada göre sıralama ekleyebilirsin
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz hiçbir kullanıcı kayıtlı değil.'));
          }

          final kullanicilar = snap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: kullanicilar.length,
            itemBuilder: (ctx, i) {
              final doc  = kullanicilar[i].data() as Map<String, dynamic>;
              final isim = "${doc['ad'] ?? ''} ${doc['soyad'] ?? ''}";
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(isim),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("E-mail: ${doc['email'] ?? '-'}"),
                      Text("Telefon: ${doc['telefon'] ?? '-'}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
