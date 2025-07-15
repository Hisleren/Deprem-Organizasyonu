import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ana_sayfa.dart';
import 'yetkili_ana_sayfa.dart';
import 'hesap.dart';
import 'yardim_al.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email = '';
  String _sifre = '';
  String _pin = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32).copyWith(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/drone_logo.png', 
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                'Hoş Geldiniz',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                onChanged: (value) => _email = value.trim(),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Şifre'),
                onChanged: (value) => _sifre = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Pin (Yetkili için)'),
                onChanged: (value) => _pin = value,
                // NORMAL KLAVYE (SAYISAL DEĞİL)
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: girisYap,
                child: const Text('Giriş Yap'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Hesap()),
                  );
                },
                child: const Text('Hesabın Yok mu? Oluştur'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.warning),
                label: const Text('YARDIM ÇAĞIR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const YardimAl()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> girisYap() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _sifre,
      );
      if (_pin == '101010') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const YetkiliAnaSayfa()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AnaSayfa()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş Başarısız!')),
      );
    }
  }
}