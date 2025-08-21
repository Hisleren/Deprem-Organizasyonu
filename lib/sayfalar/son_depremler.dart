// son_depremler.dart - Enhanced Earthquake Data Page
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class SonDepremlerPage extends StatefulWidget {
  const SonDepremlerPage({Key? key}) : super(key: key);

  @override
  State<SonDepremlerPage> createState() => _SonDepremlerPageState();
}

class _SonDepremlerPageState extends State<SonDepremlerPage>
    with TickerProviderStateMixin {
  List<EarthquakeData> _earthquakes = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _lastUpdate = '';
  String _selectedFilter = 'Tümü';
  
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  final List<String> _magnitudeFilters = [
    'Tümü',
    '2.0+',
    '3.0+',
    '4.0+',
    '5.0+',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadEarthquakeData();
  }

  void _initializeAnimations() {
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadEarthquakeData() async {
    if (!_isLoading) {
      _refreshController.forward().then((_) {
        _refreshController.reset();
      });
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('http://www.koeri.boun.edu.tr/scripts/lst0.asp'),
        headers: {'Accept-Charset': 'utf-8'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _parseEarthquakeData(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('Earthquake data loading error: $e');
    }
  }

  void _parseEarthquakeData(String htmlContent) {
    try {
      final startIndex = htmlContent.indexOf('<pre>') + 5;
      final endIndex = htmlContent.indexOf('</pre>', startIndex);
      final preContent = htmlContent.substring(startIndex, endIndex);
      
      final lines = preContent.split('\n');
      final List<EarthquakeData> earthquakes = [];
      
      final now = DateTime.now().toUtc().add(const Duration(hours: 3));
      final last24Hours = now.subtract(const Duration(hours: 24));
      _lastUpdate = DateFormat('dd.MM.yyyy HH:mm:ss').format(now);

      for (int i = 7; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        try {
          final parts = line.split(RegExp(r'\s+'));
          if (parts.length < 9) continue;
          
          final date = parts[0];
          final time = parts[1];
          final latitude = double.tryParse(parts[2]) ?? 0.0;
          final longitude = double.tryParse(parts[3]) ?? 0.0;
          final depth = double.tryParse(parts[4]) ?? 0.0;
          final magnitude = double.tryParse(parts[6]) ?? 0.0;
          final location = _fixTurkishEncoding(parts.sublist(8).join(' '));
          
          final dateTimeStr = '${date.replaceAll('.', '-')} $time';
          final quakeTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStr);
          
          if (quakeTime.isAfter(last24Hours)) {
            earthquakes.add(EarthquakeData(
              dateTime: quakeTime,
              latitude: latitude,
              longitude: longitude,
              depth: depth,
              magnitude: magnitude,
              location: location,
            ));
          }
        } catch (e) {
          continue;
        }
      }

      earthquakes.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      setState(() {
        _earthquakes = earthquakes;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _fixTurkishEncoding(String input) {
    return input
        .replaceAll('Ã°', 'ğ')
        .replaceAll('Ã½', 'ı')
        .replaceAll('Ã¾', 'ş')
        .replaceAll('Ã', 'İ')
        .replaceAll('Ãž', 'Ş')
        .replaceAll('Ã', 'Ğ');
  }

  List<EarthquakeData> get _filteredEarthquakes {
    if (_selectedFilter == 'Tümü') return _earthquakes;
    
    final minMagnitude = double.parse(_selectedFilter.replaceAll('+', ''));
    return _earthquakes.where((eq) => eq.magnitude >= minMagnitude).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // son_depremler.dart dosyasındaki SliverAppBar'ı bu kodla güncelleyin

SliverAppBar(
  expandedHeight: 160,
  floating: false,
  pinned: true,
  backgroundColor: colorScheme.primary,
  foregroundColor: colorScheme.onPrimary,
  actions: [
    AnimatedBuilder(
      animation: _refreshAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _refreshAnimation.value * 6.28,
          child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadEarthquakeData,
          ),
        );
      },
    ),
  ],
  flexibleSpace: FlexibleSpaceBar(
    // Bu başlık, AppBar küçüldüğünde görünmeye devam edecek.
    title: const Text(
      'Son Depremler',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),

    background: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.analytics,
                  size: MediaQuery.of(context).size.width * 0.1,
                  color: Colors.white,
                ),
                // İkon ve alt başlık arasındaki boşluğu ayarlıyoruz.
                const SizedBox(height: 8),

                // ❌ ÖNCEKİ BÜYÜK "Son Depremler" YAZISI BURADAN KALDIRILDI.

                // Sadece alt başlık kalıyor.
                Text(
                  'Son 24 Saat Verileri',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: MediaQuery.of(context).size.width * 0.038,
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
),
          ];
        },
        body: Column(
          children: [
            _buildHeader(colorScheme, textTheme),
            _buildFilterChips(colorScheme, textTheme),
            Expanded(child: _buildEarthquakeList(colorScheme, textTheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoading || _hasError) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  colorScheme,
                  textTheme,
                  'Toplam',
                  '${_earthquakes.length}',
                  Icons.public,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  colorScheme,
                  textTheme,
                  'En Yüksek',
                  _earthquakes.isEmpty
                      ? '0.0'
                      : _earthquakes
                          .map((e) => e.magnitude)
                          .reduce((max, current) => max > current ? max : current)
                          .toStringAsFixed(1),
                  Icons.trending_up,
                  _getMagnitudeColor(_earthquakes.isEmpty ? 0.0 :
                      _earthquakes.map((e) => e.magnitude).reduce((max, current) => max > current ? max : current)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Son güncelleme: $_lastUpdate',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _magnitudeFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _magnitudeFilters[index];
          final isSelected = _selectedFilter == filter;
          
          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            backgroundColor: colorScheme.surface,
            selectedColor: colorScheme.primary.withOpacity(0.2),
            checkmarkColor: colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEarthquakeList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Deprem verileri yükleniyor...',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Veriler Yüklenemedi',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'İnternet bağlantınızı kontrol edin ve tekrar deneyin',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadEarthquakeData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredData = _filteredEarthquakes;

    if (filteredData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: colorScheme.secondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Deprem Bulunamadı',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFilter == 'Tümü'
                    ? 'Son 24 saatte deprem kaydedilmedi'
                    : 'Seçilen büyüklükte deprem bulunamadı',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEarthquakeData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredData.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildEarthquakeCard(
                    colorScheme,
                    textTheme,
                    filteredData[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEarthquakeCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    EarthquakeData earthquake,
  ) {
    final magnitudeColor = _getMagnitudeColor(earthquake.magnitude);
    final timeAgo = _getTimeAgo(earthquake.dateTime);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: magnitudeColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: earthquake.magnitude >= 4.0
            ? Border.all(color: magnitudeColor.withOpacity(0.3))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: magnitudeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: magnitudeColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      earthquake.magnitude.toStringAsFixed(1),
                      style: textTheme.titleLarge?.copyWith(
                        color: magnitudeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        earthquake.location,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeAgo,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: magnitudeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getMagnitudeLevel(earthquake.magnitude),
                    style: textTheme.bodySmall?.copyWith(
                      color: magnitudeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  colorScheme,
                  textTheme,
                  Icons.straighten,
                  'Derinlik',
                  '${earthquake.depth.toStringAsFixed(1)} km',
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  colorScheme,
                  textTheme,
                  Icons.access_time,
                  'Saat',
                  DateFormat('HH:mm:ss').format(earthquake.dateTime),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    ColorScheme colorScheme,
    TextTheme textTheme,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
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

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude < 2.0) return Colors.green;
    if (magnitude < 3.0) return Colors.lightGreen;
    if (magnitude < 4.0) return Colors.orange;
    if (magnitude < 5.0) return Colors.deepOrange;
    if (magnitude < 6.0) return Colors.red;
    return Colors.purple;
  }

  String _getMagnitudeLevel(double magnitude) {
    if (magnitude < 2.0) return 'Çok Zayıf';
    if (magnitude < 3.0) return 'Zayıf';
    if (magnitude < 4.0) return 'Hafif';
    if (magnitude < 5.0) return 'Orta';
    if (magnitude < 6.0) return 'Güçlü';
    return 'Çok Güçlü';
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    }
  }
}

class EarthquakeData {
  final DateTime dateTime;
  final double latitude;
  final double longitude;
  final double depth;
  final double magnitude;
  final String location;

  EarthquakeData({
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.depth,
    required this.magnitude,
    required this.location,
  });
}