// deprem_ani.dart - Enhanced Earthquake Information Page
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DepremAni extends StatefulWidget {
  const DepremAni({super.key});

  @override
  State<DepremAni> createState() => _DepremAniState();
}

class _DepremAniState extends State<DepremAni> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: screenHeight * 0.22,
              floating: false,
              pinned: true,
              foregroundColor: Colors.white,
              backgroundColor: colorScheme.background, 
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: colorScheme.background,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.security,
                              size: screenWidth * 0.1,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Deprem Rehberi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hayat Kurtarıcı Bilgiler',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: screenWidth * 0.038,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                unselectedLabelStyle: TextStyle(fontSize: screenWidth * 0.03),
                tabs: const [
                  Tab(text: 'Öncesi'),
                  Tab(text: 'Anı'),
                  Tab(text: 'Sonrası'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBeforeEarthquakeTab(context),
            _buildDuringEarthquakeTab(context),
            _buildAfterEarthquakeTab(context),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom + 16),
        child: FloatingActionButton.extended(
          onPressed: () => _callEmergency('112'),
          backgroundColor: colorScheme.error,
          foregroundColor: Colors.white,
          icon: Icon(Icons.phone, size: screenWidth * 0.055),
          label: Text(
            '112 ARA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.038,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeforeEarthquakeTab(BuildContext context) {
    final beforeItems = [
      GuideItem(
        icon: Icons.home_repair_service,
        title: 'Acil Durum Çantası',
        description: 'Su, yiyecek, ilaç, el feneri, radyo hazırlayın',
        color: Colors.green,
      ),
      GuideItem(
        icon: Icons.family_restroom,
        title: 'Aile Planı',
        description: 'Buluşma noktası belirleyin ve iletişim planı yapın',
        color: Colors.blue,
      ),
      GuideItem(
        icon: Icons.build,
        title: 'Yapısal Güvenlik',
        description: 'Ağır eşyaları sabitleyin, çatlakları kontrol edin',
        color: Colors.orange,
      ),
      GuideItem(
        icon: Icons.school,
        title: 'Bilgi ve Eğitim',
        description: 'Deprem tatbikatlarına katılın, bilgilerinizi güncelleyin',
        color: Colors.purple,
      ),
    ];

    return _buildGuideList(
      context,
      beforeItems,
      'Deprem Öncesi Hazırlık',
      'Hazırlıklı olmak hayat kurtarır',
    );
  }

  Widget _buildDuringEarthquakeTab(BuildContext context) {
    final duringItems = [
      GuideItem(
        icon: Icons.self_improvement,
        title: 'Sakin Kalın',
        description: 'Paniğe kapılmayın, soğukkanlılığınızı koruyun',
        color: Colors.indigo,
        isEmergency: true,
      ),
      GuideItem(
        icon: Icons.shield,
        title: 'Çök-Kapan-Tutun',
        description: 'Masanın altına girin, başınızı koruyun',
        color: Colors.red,
        isEmergency: true,
      ),
      GuideItem(
        icon: Icons.no_transfer,
        title: 'Asansör Kullanmayın',
        description: 'Merdivenleri kullanın, asansörde kalmayın',
        color: Colors.orange,
        isEmergency: true,
      ),
      GuideItem(
        icon: Icons.door_front_door,
        title: 'Açık Alana Geçin',
        description: 'Güvenli şekilde açık alana çıkmaya çalışın',
        color: Colors.green,
      ),
    ];

    return _buildGuideList(
      context,
      duringItems,
      'Deprem Anında Yapılacaklar',
      'Doğru davranış hayat kurtarır',
    );
  }

  Widget _buildAfterEarthquakeTab(BuildContext context) {
    final afterItems = [
      GuideItem(
        icon: Icons.health_and_safety,
        title: 'Yaralıları Kontrol Edin',
        description: 'İlk yardım uygulayın, yaralıları güvenli yere taşıyın',
        color: Colors.red,
      ),
      GuideItem(
        icon: Icons.power_off,
        title: 'Altyapıyı Kontrol Edin',
        description: 'Elektrik, gaz ve su vanalarını kapatın',
        color: Colors.yellow.shade800,
      ),
      GuideItem(
        icon: Icons.radio,
        title: 'Bilgi Alın',
        description: 'Radyo dinleyin, resmi açıklamaları takip edin',
        color: Colors.blue,
      ),
      GuideItem(
        icon: Icons.support_agent,
        title: 'Yardım İsteyin',
        description: 'Gerektiğinde arama kurtarma ekiplerini arayın',
        color: Colors.green,
      ),
    ];

    return _buildGuideList(
      context,
      afterItems,
      'Deprem Sonrası Yapılacaklar',
      'Organize davranış çok önemli',
    );
  }

  Widget _buildGuideList(
    BuildContext context,
    List<GuideItem> items,
    String title,
    String subtitle,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                  child: _buildGuideCard(context, items[index]),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          sliver: SliverToBoxAdapter(
            child: _buildEmergencyTips(context),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: screenHeight * 0.1),
        ),
      ],
    );
  }

  Widget _buildGuideCard(BuildContext context, GuideItem item) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: item.isEmergency
              ? Border.all(color: item.color.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: item.isEmergency
                    ? Border.all(color: item.color.withOpacity(0.3))
                    : null,
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: screenWidth * 0.06,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (item.isEmergency) ...[
                        SizedBox(width: screenWidth * 0.02),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenWidth * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ÖNEMLİ',
                            style: textTheme.bodySmall?.copyWith(
                              color: item.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyTips(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.error.withOpacity(0.1),
            colorScheme.error.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: colorScheme.error,
                size: screenWidth * 0.055,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Önemli Hatırlatmalar',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          _buildTipItem(context, 'Deprem çantanızı düzenli kontrol edin'),
          _buildTipItem(context, 'Aile bireylerinin okul/iş yerlerini bilin'),
          _buildTipItem(context, 'Evcil hayvanlarınız için de plan yapın'),
          _buildTipItem(context, 'Önemli belgelerin kopyalarını saklayın'),
          SizedBox(height: screenWidth * 0.03),
          // ❌ Burada "Acil Durum: 112" butonu kaldırıldı
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Arama başlatılamadı!'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class GuideItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isEmergency;

  GuideItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isEmergency = false,
  });
}