// yardim_al.dart - Enhanced Emergency Help Page - ALL PIXEL OVERFLOW ISSUES FIXED
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class YardimAl extends StatefulWidget {
  const YardimAl({super.key});

  @override
  State<YardimAl> createState() => _YardimAlState();
}

class _YardimAlState extends State<YardimAl> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _descriptionController = TextEditingController();
  
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  
  bool _isLoading = false;
  bool _locationGranted = false;
  String _selectedEmergencyType = 'Genel Yardım';
  
  final List<String> _emergencyTypes = [
    'Genel Yardım',
    'Medikal Acil Durum',
    'Yangın',
    'Deprem',
    'Sel/Su Baskını',
    'Güvenlik',
    'Diğer',
  ];

  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: 'Ambulans',
      number: '112',
      icon: Icons.local_hospital,
      color: Colors.red,
    ),
    EmergencyContact(
      name: 'İtfaiye',
      number: '110',
      icon: Icons.local_fire_department,
      color: Colors.orange,
    ),
    EmergencyContact(
      name: 'Polis',
      number: '155',
      icon: Icons.local_police,
      color: Colors.blue,
    ),
    EmergencyContact(
      name: 'Jandarma',
      number: '156',
      icon: Icons.security,
      color: Colors.green,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkLocationPermission();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 24,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    setState(() {
      _locationGranted = permission == LocationPermission.always ||
                       permission == LocationPermission.whileInUse;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Acil Durum Yardımı',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmergencyAlert(colorScheme, textTheme, screenWidth),
            SizedBox(height: screenHeight * 0.04),
            _buildEmergencyContacts(colorScheme, textTheme, screenWidth),
            SizedBox(height: screenHeight * 0.04),
            _buildHelpRequestForm(colorScheme, textTheme, screenWidth),
            SizedBox(height: screenHeight * 0.03),
            _buildMainEmergencyButton(colorScheme, textTheme, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.04),
            _buildLocationStatus(colorScheme, textTheme, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyAlert(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.error,
            colorScheme.error.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  Icons.emergency,
                  color: colorScheme.onError,
                  size: screenWidth * 0.08,
                ),
              );
            },
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ACİL DURUM',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hayati tehlike durumunda hemen 112\'yi arayın',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onError.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Acil Durum Numaraları',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: screenWidth * 0.04,
            mainAxisSpacing: screenWidth * 0.04,
            childAspectRatio: 1.2,
          ),
          itemCount: _emergencyContacts.length,
          itemBuilder: (context, index) {
            final contact = _emergencyContacts[index];
            return _buildContactCard(colorScheme, textTheme, contact, screenWidth);
          },
        ),
      ],
    );
  }

  Widget _buildContactCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    EmergencyContact contact,
    double screenWidth,
  ) {
    return GestureDetector(
      onTap: () => _callEmergency(contact.number),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: contact.color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              contact.icon,
              color: contact.color,
              size: screenWidth * 0.08,
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                contact.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: contact.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  contact.number,
                  style: textTheme.titleLarge?.copyWith(
                    color: contact.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpRequestForm(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Yardım Talebi Oluştur',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Emergency Type Dropdown
        DropdownButtonFormField<String>(
          value: _selectedEmergencyType,
          decoration: InputDecoration(
            labelText: 'Acil Durum Türü',
            prefixIcon: Icon(Icons.category_outlined, color: colorScheme.primary),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 16,
            ),
          ),
          isExpanded: true,
          items: _emergencyTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(
                type,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedEmergencyType = value!;
            });
          },
        ),
        
        const SizedBox(height: 20),
        
        // Description Field
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Açıklama (İsteğe bağlı)',
            hintText: 'Durumu kısaca açıklayın...',
            prefixIcon: Icon(Icons.description_outlined, color: colorScheme.primary),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 16,
            ),
          ),
          maxLines: 3,
          maxLength: 200,
        ),
      ],
    );
  }

  Widget _buildMainEmergencyButton(ColorScheme colorScheme, TextTheme textTheme, double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 0.1, 0),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.95 + (_pulseAnimation.value - 1.0) * 0.1,
                child: SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.08,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendHelpRequest,
                    icon: _isLoading
                        ? SizedBox(
                            width: screenWidth * 0.06,
                            height: screenWidth * 0.06,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.emergency_share, size: screenWidth * 0.08),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _isLoading ? 'GÖNDERİLİYOR...' : 'YARDIM ÇAĞIR',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onError,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      elevation: 8,
                      shadowColor: colorScheme.error.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLocationStatus(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: _locationGranted 
            ? colorScheme.secondary.withOpacity(0.1)
            : colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _locationGranted 
              ? colorScheme.secondary.withOpacity(0.3)
              : colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _locationGranted ? Icons.location_on : Icons.location_off,
            color: _locationGranted ? colorScheme.secondary : colorScheme.error,
            size: screenWidth * 0.06,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _locationGranted ? 'Konum Erişimi Aktif' : 'Konum Erişimi Kapalı',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _locationGranted ? colorScheme.secondary : colorScheme.error,
                    ),
                  ),
                ),
                Text(
                  _locationGranted 
                      ? 'Konumunuz yardım ekiplerine gönderilecek'
                      : 'Konum izni verin ki size hızlıca ulaşabilelim',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!_locationGranted)
            TextButton(
              onPressed: _requestLocationPermission,
              child: const Text('İzin Ver'),
            ),
        ],
      ),
    );
  }

  Future<void> _callEmergency(String phoneNumber) async {
    HapticFeedback.heavyImpact();
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorSnackBar('Arama başlatılamadı');
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    setState(() {
      _locationGranted = permission == LocationPermission.always ||
                        permission == LocationPermission.whileInUse;
    });
  }

  Future<void> _sendHelpRequest() async {
    final colorScheme = Theme.of(context).colorScheme;
    
    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.heavyImpact();
      
      // Get location if permission granted
      Position? location;
      if (_locationGranted) {
        try {
          location = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (e) {
          debugPrint('Location error: $e');
        }
      }

      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Kullanıcı oturum açmamış');

      // Get user data
      final userDoc = await _firestore.collection('kullanicilar').doc(uid).get();
      final userData = userDoc.data();
      if (userData == null) throw Exception('Kullanıcı bilgisi bulunamadı');

      // Send help request
      await _firestore.collection('yardim_istekleri').add({
        'uid': uid,
        'ad': userData['ad'] ?? '',
        'soyad': userData['soyad'] ?? '',
        'telefon': userData['telefon'] ?? '',
        'email': userData['email'] ?? '',
        'acil_durum_turu': _selectedEmergencyType,
        'aciklama': _descriptionController.text.trim(),
        'konum': location != null ? {
          'lat': location.latitude,
          'lng': location.longitude,
        } : null,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'bekliyor',
      });

      // Success feedback
      HapticFeedback.mediumImpact();
      _shakeController.forward().then((_) => _shakeController.reset());
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Yardım çağrısı gönderildi! Ekiplerimiz size ulaşacak.')),
            ],
          ),
          backgroundColor: colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      // Clear form
      _descriptionController.clear();
      setState(() {
        _selectedEmergencyType = 'Genel Yardım';
      });

    } catch (e) {
      _showErrorSnackBar('Yardım çağrısı gönderilemedi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.onError),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class EmergencyContact {
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
  });
}