import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KullaniciBilgileri extends StatelessWidget {
  const KullaniciBilgileri({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kullanıcı Bilgileri"),
        elevation: 0,
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(
              child: Text(
                "Önce giriş yapmalısınız.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("kullanicilar")
                  .doc(uid)
                  .snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || !snap.data!.exists) {
                  return const Center(
                    child: Text(
                      "Kullanıcı bulunamadı.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final data = snap.data!.data() as Map<String, dynamic>;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoCard("Ad", data["ad"] ?? "-"),
                      const SizedBox(height: 12),
                      _buildInfoCard("Soyad", data["soyad"] ?? "-"),
                      const SizedBox(height: 12),
                      _buildInfoCard("E-mail", data["email"] ?? "-"),
                      const SizedBox(height: 12),
                      _buildInfoCard("Telefon", data["telefon"] ?? "-"),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}