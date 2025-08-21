// login_page.dart - Enhanced Professional Login - ALL PIXEL OVERFLOW ISSUES FIXED
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'ana_sayfa.dart';
import 'yetkili_ana_sayfa.dart';
import 'hesap.dart';
import 'yardim_al.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.05),
              colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 500,
                      minHeight: screenHeight * 0.7,
                    ),
                    child: Card(
                      elevation: 8,
                      shadowColor: colorScheme.shadow.withOpacity(0.2),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.08),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo and Title Section
                              _buildHeaderSection(colorScheme, textTheme, screenWidth),
                              
                              SizedBox(height: screenHeight * 0.04),
                              
                              // Login Form
                              _buildLoginForm(colorScheme, screenWidth),
                              
                              SizedBox(height: screenHeight * 0.03),
                              
                              // Login Button
                              _buildLoginButton(colorScheme, textTheme, screenWidth),
                              
                              SizedBox(height: screenHeight * 0.02),
                              
                              // Register Link
                              _buildRegisterLink(colorScheme, textTheme, screenWidth),
                              
                              SizedBox(height: screenHeight * 0.035),
                              
                              // Divider
                              _buildDivider(colorScheme, textTheme, screenWidth),
                              
                              SizedBox(height: screenHeight * 0.025),
                              
                              // Emergency Help Button
                              _buildEmergencyButton(colorScheme, screenWidth),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.2,
          height: screenWidth * 0.2,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.security_rounded,
            size: screenWidth * 0.1,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: screenWidth * 0.06),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Deprem Organizasyonu',
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Güvenli giriş yapın',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ColorScheme colorScheme, double screenWidth) {
    return Column(
      children: [
        // Email Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'E-posta',
            hintText: 'ornek@email.com',
            prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'E-posta adresi gereklidir';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Geçerli bir e-posta adresi girin';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 20),
        
        // Password Field
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            labelText: 'Şifre',
            hintText: 'Şifrenizi girin',
            prefixIcon: Icon(Icons.lock_outlined, color: colorScheme.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility_off : Icons.visibility,
                color: colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Şifre gereklidir';
            }
            if (value.length < 6) {
              return 'Şifre en az 6 karakter olmalıdır';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 20),
        
        // PIN Field
        TextFormField(
          controller: _pinController,
          decoration: InputDecoration(
            labelText: 'PIN (Yetkili için)',
            hintText: 'Yetkili PIN kodu (isteğe bağlı)',
            prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: colorScheme.tertiary),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.text,
        ),
        
        const SizedBox(height: 16),
        
        // Remember Me Checkbox
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Beni hatırla',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            Flexible(
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Şifre sıfırlama özelliği yakında eklenecek')),
                  );
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Şifremi Unuttum',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Giriş Yap',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Hesabınız yok mu? ',
          style: textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Hesap()),
            );
          },
          child: Text(
            'Kayıt Olun',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'VEYA',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildEmergencyButton(ColorScheme colorScheme, double screenWidth) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.heavyImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const YardimAl()),
          );
        },
        icon: Icon(Icons.emergency, color: colorScheme.error, size: screenWidth * 0.05),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'ACİL DURUM YARDIMI',
            style: TextStyle(
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (_pinController.text.trim() == '101010') {
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

      // Success feedback
      HapticFeedback.lightImpact();
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Giriş başarısız!';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı';
          break;
        case 'wrong-password':
          errorMessage = 'Hatalı şifre';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta formatı';
          break;
        case 'user-disabled':
          errorMessage = 'Bu hesap devre dışı bırakıldı';
          break;
        case 'too-many-requests':
          errorMessage = 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin';
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      HapticFeedback.selectionClick();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}