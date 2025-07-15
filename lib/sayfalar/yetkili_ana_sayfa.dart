import 'package:flutter/material.dart';
import 'new_harita.dart';
import 'yetkili_bilgileri.dart';

class YetkiliAnaSayfa extends StatelessWidget {
  const YetkiliAnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yetkili Paneli'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: const [
            PanelButon(
              icon: Icons.map,
              baslik: 'Yardım Haritası',
              sayfa: SecondPage(),
            ),
            PanelButon(
              icon: Icons.people,
              baslik: 'Kullanıcı Bilgileri',
              sayfa: YetkiliBilgileri(),
            ),
          ],
        ),
      ),
    );
  }
}

class PanelButon extends StatelessWidget {
  final IconData icon;
  final String baslik;
  final Widget sayfa;

  const PanelButon({
    super.key,
    required this.icon,
    required this.baslik,
    required this.sayfa,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => sayfa),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              baslik,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}