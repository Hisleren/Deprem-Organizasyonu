import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class Hesap extends StatefulWidget {
  const Hesap({super.key});

  @override
  State<Hesap> createState() => _HesapState();
}

class _HesapState extends State<Hesap> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  
  String _ad = '';
  String _soyad = '';
  String _email = '';
  String _sifre = '';
  String _telefon = '';

  // Yeşil renk (tema ile uyumlu)
  final Color primaryGreen = const Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Oluştur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildTextField('Ad', Icons.person, (value) => _ad = value),
              const SizedBox(height: 16),
              _buildTextField('Soyad', Icons.person_outline, (value) => _soyad = value),
              const SizedBox(height: 16),
              _buildTextField('E-mail', Icons.email, (value) => _email = value,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField('Şifre', Icons.lock, (value) => _sifre = value,
                  obscureText: true),
              const SizedBox(height: 16),
              _buildTextField('Telefon', Icons.phone, (value) => _telefon = value,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _hesapOlustur,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal, // Yeşil renk
                ),
                child: const Text(
                  'HESAP OLUŞTUR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zaten hesabın var mı? Giriş Yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    Function(String) onSaved, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bu alan zorunludur';
        }
        return null;
      },
      onSaved: (value) => onSaved(value!),
    );
  }

  Future<void> _hesapOlustur() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Firebase Auth ile kullanıcı oluştur
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _sifre,
        );
        
        // Firestore'a kullanıcı verilerini kaydet
        await _firestore
          .collection('kullanicilar')
          .doc(userCredential.user!.uid)
          .set({
            'ad': _ad,
            'soyad': _soyad,
            'email': _email,
            'telefon': _telefon,
            'createdAt': FieldValue.serverTimestamp(),
          });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hesap başarıyla oluşturuldu!')),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Hesap oluşturma hatası';
        if (e.code == 'weak-password') {
          errorMessage = 'Zayıf şifre, daha güçlü bir şifre deneyin';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Bu e-posta ile zaten bir hesap var';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Geçersiz e-posta formatı';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: ${e.toString()}')),
        );
      }
    }
  }
}