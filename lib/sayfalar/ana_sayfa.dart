// ana_sayfa.dart - Enhanced Professional Dashboard
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; 
import 'deprem_ani.dart';
import 'son_depremler.dart';
import 'yardim_al.dart';
import 'kullanici_bilgileri.dart';
import 'login_page.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _userName = '';
  int _recentEarthquakeCount = 0;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _loadEarthquakeData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('kullanicilar')
            .doc(uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            // Ad ve soyad arasındaki fazla boşluğu kaldırıyoruz
            _userName = '${data['ad']?.toString().trim() ?? ''} ${data['soyad']?.toString().trim() ?? ''}';
          });
        }
      }
    } catch (e) {
      debugPrint('User data loading error: $e');
    }
  }

  Future<void> _loadEarthquakeData() async {
    try {
      final response = await http.get(
        Uri.parse('http://www.koeri.boun.edu.tr/scripts/lst0.asp'),
        headers: {'Accept-Charset': 'utf-8'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final startIndex = response.body.indexOf('<pre>') + 5;
        final endIndex = response.body.indexOf('</pre>', startIndex);
        final preContent = response.body.substring(startIndex, endIndex);
        final lines = preContent.split('\n');
        
        final now = DateTime.now().toUtc().add(const Duration(hours: 3));
        final last24Hours = now.subtract(const Duration(hours: 24));
        
        int count = 0;
        for (int i = 7; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          
          try {
            final parts = line.split(RegExp(r'\s+'));
            if (parts.length < 9) continue;
            
            final date = parts[0];
            final time = parts[1];
            final dateTimeStr = '${date.replaceAll('.', '-')} $time';
            final quakeTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStr);
            
            if (quakeTime.isAfter(last24Hours)) {
              count++;
            }
          } catch (e) {
            continue;
          }
        }

        setState(() {
          _recentEarthquakeCount = count;
          _isLoadingData = false;
        });
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Earthquake data loading error: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(colorScheme, textTheme),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(colorScheme, textTheme),
                      const SizedBox(height: 20),
                      _buildQuickStats(colorScheme, textTheme),
                      const SizedBox(height: 24),
                      _buildMainActions(colorScheme, textTheme),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ColorScheme colorScheme, TextTheme textTheme) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: colorScheme.primary),
          onPressed: () {
            // TODO: Implement notifications
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
          onSelected: (value) {
            if (value == 'logout') {
              _handleLogout();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Çıkış Yap'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Acil Durum Sistemi',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
      ),
    );
  }

  Widget _buildWelcomeCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.waving_hand,
                color: colorScheme.onPrimary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _userName.isEmpty ? 'Hoş Geldiniz' : 'Hoş Geldiniz, $_userName',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Güncel bilgiler ve acil durum hizmetlerine erişin',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.9),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Bilgiler',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                colorScheme,
                textTheme,
                icon: Icons.public,
                title: 'Son 24 Saat',
                value: _isLoadingData ? '...' : '$_recentEarthquakeCount',
                subtitle: 'Deprem',
                color: colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                colorScheme,
                textTheme,
                icon: Icons.security,
                title: 'Güvenlik',
                value: 'NORMAL',
                subtitle: 'Durum',
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions(ColorScheme colorScheme, TextTheme textTheme) {
    final actions = [
      ActionCardData(
        icon: Icons.warning_amber_rounded,
        title: 'Deprem Anı',
        subtitle: 'Deprem sırasında yapılacaklar',
        color: Colors.orange,
        page: const DepremAni(),
      ),
      ActionCardData(
        icon: Icons.public,
        title: 'Son Depremler',
        subtitle: 'Güncel deprem verileri',
        color: colorScheme.tertiary,
        page: const SonDepremlerPage(),
      ),
      ActionCardData(
        icon: Icons.support_agent,
        title: 'Yardım Al',
        subtitle: 'Acil durum yardım çağrısı',
        color: colorScheme.error,
        page: const YardimAl(),
        isEmergency: true,
      ),
      ActionCardData(
        icon: Icons.account_circle,
        title: 'Bilgilerim',
        subtitle: 'Profil ve kişisel bilgiler',
        color: colorScheme.secondary,
        page: const KullaniciBilgileri(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ana Hizmetler',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _buildActionCard(
              colorScheme,
              textTheme,
              actions[index],
              index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    ActionCardData data,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => data.page),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: data.isEmergency 
                        ? data.color.withOpacity(0.2)
                        : colorScheme.shadow.withOpacity(0.1),
                    blurRadius: data.isEmergency ? 12 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: data.isEmergency
                    ? Border.all(color: data.color.withOpacity(0.3), width: 1.5)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: data.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        data.icon,
                        color: data.color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      data.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çıkış yapılırken hata oluştu: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class ActionCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget page;
  final bool isEmergency;

  ActionCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.page,
    this.isEmergency = false,
  });
}