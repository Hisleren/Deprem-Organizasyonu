import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DepremAni extends StatelessWidget {
  const DepremAni({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deprem Anı'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Center(
              child: Text(
                'Deprem Anında Yapılması Gerekenler',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            
            // Maddeler
            ..._buildGuidelineItems(),
            
            const SizedBox(height: 32),
            
            // Acil Servis Butonu
            _buildEmergencyButton(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGuidelineItems() {
    final items = [
      'Sakin olun ve paniğe kapılmayın.',
      'Güvenli bir yere geçin.',
      'Asansörleri kullanmayın.',
      'Elektrik, gaz ve su vanalarını kapatın.',
      'Bina dışına çıkarken dikkatli olun.',
      'Telefon görüşmelerinizi mümkün olduğunca kısa yapın.',
      'Yardım çağırın.',
    ];

    return items
        .map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.emergency, size: 28),
        label: const Text(
          '112 Acil Servisi Ara',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _callEmergency(context),
      ),
    );
  }

  void _callEmergency(BuildContext context) async {
    const phoneNumber = 'tel:112';
    if (await canLaunchUrl(Uri.parse(phoneNumber))) {
      await launchUrl(Uri.parse(phoneNumber));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arama başlatılamadı!')),
      );
    }
  }
}