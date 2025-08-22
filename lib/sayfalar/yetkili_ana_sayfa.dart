// yetkili_ana_sayfa.dart - Enhanced Professional Admin Dashboard - ALL PIXEL OVERFLOW ISSUES FIXED
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_harita.dart';
import 'yetkili_bilgileri.dart';
import 'login_page.dart';

class YetkiliAnaSayfa extends StatefulWidget {
  const YetkiliAnaSayfa({super.key});

  @override
  State<YetkiliAnaSayfa> createState() => _YetkiliAnaSayfaState();
}

class _YetkiliAnaSayfaState extends State<YetkiliAnaSayfa>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _adminName = '';
  int _totalUsers = 0;
  int _activeRequests = 0;
  int _todayRequests = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAdminData();
    _loadStats();
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

  Future<void> _loadAdminData() async {
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
            _adminName = '${data['ad'] ?? 'Admin'} ${data['soyad'] ?? ''}';
          });
        }
      }
    } catch (e) {
      debugPrint('Admin data loading error: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      // Get total users count
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('kullanicilar')
          .get();
      
      // Get help requests
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('yardim_istekleri')
          .get();
      
      // Get today's requests
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final todayRequestsSnapshot = await FirebaseFirestore.instance
          .collection('yardim_istekleri')
          .where('tarih', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();
      
      // Count active requests (status: 'bekliyor')
      final activeRequestsCount = requestsSnapshot.docs
          .where((doc) => doc.data()['durum'] == 'bekliyor')
          .length;

      setState(() {
        _totalUsers = usersSnapshot.docs.length;
        _activeRequests = activeRequestsCount;
        _todayRequests = todayRequestsSnapshot.docs.length;
        _isLoadingStats = false;
      });
    } catch (e) {
      debugPrint('Stats loading error: $e');
      setState(() {
        _isLoadingStats = false;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(colorScheme, textTheme, screenHeight),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(colorScheme, textTheme, screenWidth),
                      SizedBox(height: screenHeight * 0.03),
                      _buildStatsSection(colorScheme, textTheme, screenWidth),
                      SizedBox(height: screenHeight * 0.04),
                      _buildQuickActions(colorScheme, textTheme, screenWidth),
                      SizedBox(height: screenHeight * 0.04),
                      _buildRecentActivity(colorScheme, textTheme, screenWidth),
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

  Widget _buildSliverAppBar(ColorScheme colorScheme, TextTheme textTheme, double screenHeight) {
    return SliverAppBar(
      expandedHeight: screenHeight * 0.15,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: colorScheme.primary),
          onPressed: () {
            // TODO: Implement admin notifications
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
          onSelected: (value) {
            if (value == 'logout') {
              _handleLogout();
            } else if (value == 'settings') {
              // TODO: Admin settings
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings, color: Colors.grey, size: 18),
                  SizedBox(width: 8),
                  Text('Ayarlar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Çıkış Yap'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Admin Paneli',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
      ),
    );
  }

  Widget _buildWelcomeCard(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: colorScheme.onPrimary,
                  size: screenWidth * 0.06,
                ),
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
                        'Hoş Geldiniz',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _adminName.isEmpty ? 'Sistem Yöneticisi' : _adminName,
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Sistem durumunu izleyin ve acil durum yönetimi yapın',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.9),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Sistem İstatistikleri',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingStats)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      colorScheme,
                      textTheme,
                      screenWidth,
                      icon: Icons.people,
                      title: 'Toplam Kullanıcı',
                      value: '$_totalUsers',
                      color: colorScheme.secondary,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: _buildStatCard(
                      colorScheme,
                      textTheme,
                      screenWidth,
                      icon: Icons.emergency,
                      title: 'Aktif Talepler',
                      value: '$_activeRequests',
                      color: _activeRequests > 0 ? colorScheme.error : colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      colorScheme,
                      textTheme,
                      screenWidth,
                      icon: Icons.today,
                      title: 'Bugünkü Talepler',
                      value: '$_todayRequests',
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: _buildStatCard(
                      colorScheme,
                      textTheme,
                      screenWidth,
                      icon: Icons.security,
                      title: 'Sistem Durumu',
                      value: 'ONLINE',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    double screenWidth, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: screenWidth * 0.06),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'CANLI',
                      style: textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
  final actions = [
    AdminAction(
      icon: Icons.map,
      title: 'Yardım Haritası',
      subtitle: 'Konum bazlı yardım talepleri',
      color: colorScheme.primary,
      page: const SecondPage(),
    ),
    AdminAction(
      icon: Icons.people_outline,
      title: 'Kullanıcı Yönetimi',
      subtitle: 'Tüm kullanıcıları görüntüle',
      color: colorScheme.secondary,
      page: const YetkiliBilgileri(),
    ),
    AdminAction(
      icon: Icons.emergency_share,
      title: 'Acil Durum Talepleri',
      subtitle: 'Aktif yardım çağrıları',
      color: colorScheme.error,
      page: const EmergencyRequestsPage(),
    ),
    AdminAction(
      icon: Icons.analytics,
      title: 'Raporlar',
      subtitle: 'Sistem analiz ve raporları',
      color: colorScheme.tertiary,
      page: const ReportsPage(),
    ),
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          'Hızlı Erişim',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
      ),
      const SizedBox(height: 16),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: screenWidth * 0.03, // Reduced spacing
          mainAxisSpacing: screenWidth * 0.03,  // Reduced spacing
          childAspectRatio: 1.2, // Increased for better text space
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return _buildActionCard(
            colorScheme,
            textTheme,
            actions[index],
            index,
            screenWidth,
          );
        },
      ),
    ],
  );
}

  Widget _buildActionCard(
  ColorScheme colorScheme,
  TextTheme textTheme,
  AdminAction action,
  int index,
  double screenWidth,
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
              MaterialPageRoute(builder: (_) => action.page),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: action.color.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: action.color.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Added this
                children: [
                  // Icon container - Fixed flex
                  Flexible(
                    flex: 2,
                    child: Container(
                      width: screenWidth * 0.1, // Reduced icon container size
                      height: screenWidth * 0.1,
                      decoration: BoxDecoration(
                        color: action.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action.icon,
                        color: action.color,
                        size: screenWidth * 0.05, // Reduced icon size
                      ),
                    ),
                  ),
                  
                  // Flexible spacer instead of fixed Spacer
                  Flexible(
                    flex: 1,
                    child: SizedBox(height: screenWidth * 0.02),
                  ),
                  
                  // Title - Flexible with proper constraints
                  Flexible(
                    flex: 2,
                    child: SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          action.title,
                          style: textTheme.titleSmall?.copyWith( // Changed from titleMedium
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontSize: screenWidth * 0.035, // Responsive font size
                          ),
                          maxLines: 2, // Allow 2 lines for title
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenWidth * 0.01), // Responsive spacing
                  
                  // Subtitle - Flexible with proper constraints
                  Flexible(
                    flex: 2,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        action.subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: screenWidth * 0.025, // Responsive font size
                          height: 1.2, // Line height for better readability
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

  Widget _buildRecentActivity(ColorScheme colorScheme, TextTheme textTheme, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Son Aktiviteler',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: View all activities
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Tümünü Gör',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                colorScheme,
                textTheme,
                Icons.emergency,
                'Yeni acil durum talebi',
                '5 dakika önce',
                colorScheme.error,
                screenWidth,
              ),
              const Divider(height: 24),
              _buildActivityItem(
                colorScheme,
                textTheme,
                Icons.person_add,
                'Yeni kullanıcı kaydı',
                '15 dakika önce',
                colorScheme.secondary,
                screenWidth,
              ),
              const Divider(height: 24),
              _buildActivityItem(
                colorScheme,
                textTheme,
                Icons.check_circle,
                'Yardım talebi tamamlandı',
                '1 saat önce',
                colorScheme.primary,
                screenWidth,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    ColorScheme colorScheme,
    TextTheme textTheme,
    IconData icon,
    String title,
    String time,
    Color color,
    double screenWidth,
  ) {
    return Row(
      children: [
        Container(
          width: screenWidth * 0.1,
          height: screenWidth * 0.1,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: screenWidth * 0.05,
          ),
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
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  time,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.onSurface.withOpacity(0.3),
        ),
      ],
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

class AdminAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget page;

  AdminAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.page,
  });
}

// Placeholder pages for features that don't exist yet
class EmergencyRequestsPage extends StatelessWidget {
  const EmergencyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acil Durum Talepleri'),
      ),
      body: const Center(
        child: Text('Bu özellik yakında eklenecek'),
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
      ),
      body: const Center(
        child: Text('Bu özellik yakında eklenecek'),
      ),
    );
  }
}