// lib/screens/ana_sayfa.dart
import 'package:flutter/material.dart';
import 'deprem_ani.dart';
import 'son_depremler.dart';            // MapPage2 için
import 'yardim_al.dart';
import 'kullanici_bilgileri.dart';

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({Key? key}) : super(key: key);  // key eklendi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          // const kaldırıldı, çünkü sayfa widget'ları const değil
          children: const [
            AnaSayfaButon(
              icon: Icons.warning_amber_rounded,
              baslik: 'Deprem Anı',
              sayfa: DepremAni(),
            ),
            AnaSayfaButon(
              icon: Icons.location_on,
              baslik: 'Yaşanan Son Depremler',
              sayfa: SonDepremlerPage(),
            ),
            AnaSayfaButon(
              icon: Icons.support_agent,
              baslik: 'Yardım Al',
              sayfa: YardimAl(),
            ),
            AnaSayfaButon(
              icon: Icons.account_circle,
              baslik: 'Bilgilerim',
              sayfa: KullaniciBilgileri(),
            ),
          ],
        ),
      ),
    );
  }
}

class AnaSayfaButon extends StatelessWidget {
  final IconData icon;
  final String baslik;
  final Widget sayfa;

  const AnaSayfaButon({
    Key? key,             // key parametresi eklendi
    required this.icon,
    required this.baslik,
    required this.sayfa,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => sayfa),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 10),
              Text(
                baslik,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
