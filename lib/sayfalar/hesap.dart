// hesap.dart - Enhanced with App's Black & Dark Color Scheme
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

  // Uygulama genelindeki koyu tema renkleri
  final Color primaryColor = const Color(0xFF4CAF50); // Ana yeşil renk
  final Color backgroundColor = const Color(0xFF121212); // Koyu arkaplan
  final Color surfaceColor = const Color(0xFF1E1E1E); // Bileşen arkaplan
  final Color onSurfaceColor = const Color(0xFFFFFFFF); // Yazı rengi
  final Color outlineColor = const Color(0xFF424242); // Çerçeve rengi
  final Color errorColor = const Color(0xFFCF6679); // Hata rengi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Hesap Oluştur'),
        backgroundColor: surfaceColor,
        foregroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildLogoSection(),
              const SizedBox(height: 30),
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
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'HESAP OLUŞTUR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: 'Zaten hesabın var mı? ',
                    style: TextStyle(
                      color: onSurfaceColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: 'Giriş Yap',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Icon(
            Icons.person_add,
            size: 40,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Yeni Hesap Oluştur',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Acil durum hizmetlerine erişmek için kaydolun',
          style: TextStyle(
            fontSize: 14,
            color: onSurfaceColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
      style: TextStyle(color: onSurfaceColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: onSurfaceColor.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outlineColor),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bu alan zorunludur';
        }
        if (label == 'E-mail' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Geçerli bir e-posta adresi girin';
        }
        if (label == 'Şifre' && value.length < 6) {
          return 'Şifre en az 6 karakter olmalıdır';
        }
        if (label == 'Telefon' && value.isNotEmpty && value.length < 10) {
          return 'Geçerli bir telefon numarası girin';
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
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Hesap başarıyla oluşturuldu!'),
              ],
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
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
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: ${e.toString()}'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}