// yetkili_bilgileri.dart - Complete Admin Users Management Page - ALL PIXEL OVERFLOW ISSUES FIXED
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class YetkiliBilgileri extends StatefulWidget {
  const YetkiliBilgileri({super.key});

  @override
  State<YetkiliBilgileri> createState() => _YetkiliBilgileriState();
}

class _YetkiliBilgileriState extends State<YetkiliBilgileri> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: const Text('Kullanıcı Yönetimi'),
            ),
            pinned: true,
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Kullanıcı ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('kullanicilar').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Kullanıcı bulunamadı',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }

              final users = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = '${data['ad'] ?? ''} ${data['soyad'] ?? ''}';
                final email = data['email'] ?? '';
                return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    email.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = users[index];
                    final data = user.data() as Map<String, dynamic>;
                    final isCurrentUser =
                        user.id == FirebaseAuth.instance.currentUser?.uid;

                    return _buildUserCard(
                      context,
                      user.id,
                      data,
                      isCurrentUser,
                      index,
                      screenWidth,
                    );
                  },
                  childCount: users.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    String userId,
    Map<String, dynamic> userData,
    bool isCurrentUser,
    int index,
    double screenWidth,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final name = '${userData['ad'] ?? ''} ${userData['soyad'] ?? ''}'.trim();
    final email = userData['email'] ?? '';
    final phone = userData['telefon'] ?? '';
    final createdAt = (userData['createdAt'] as Timestamp?)?.toDate();

    return Card(
      margin: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        screenWidth * 0.02,
        screenWidth * 0.04,
        screenWidth * 0.02,
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  radius: screenWidth * 0.06,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
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
                          name.isEmpty ? 'İsimsiz Kullanıcı' : name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        email,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'SİZ',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),
            if (phone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: screenWidth * 0.04,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        phone,
                        style: textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            if (createdAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: screenWidth * 0.04,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Üyelik: ${_formatDate(createdAt)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: screenWidth * 0.03),
            // Buttons with flexible layout for smaller screens
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: screenWidth < 400 ? double.infinity : null,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.message, size: screenWidth * 0.04),
                    label: const Text('Mesaj'),
                    onPressed: () => _showFeatureNotAvailable(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth < 400 ? double.infinity : null,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.edit, size: screenWidth * 0.04),
                    label: const Text('Düzenle'),
                    onPressed: () => _showEditUserDialog(context, userId, userData),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                if (!isCurrentUser)
                  SizedBox(
                    width: screenWidth < 400 ? double.infinity : null,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.delete, color: Colors.red, size: screenWidth * 0.04),
                      label: const Text('Sil', style: TextStyle(color: Colors.red)),
                      onPressed: () => _showDeleteDialog(context, userId),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditUserDialog(
    BuildContext context,
    String userId,
    Map<String, dynamic> userData,
  ) async {
    final nameController = TextEditingController(text: userData['ad'] ?? '');
    final surnameController = TextEditingController(text: userData['soyad'] ?? '');
    final phoneController = TextEditingController(text: userData['telefon'] ?? '');
    final screenWidth = MediaQuery.of(context).size.width;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text('Kullanıcıyı Düzenle'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Ad',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: surnameController,
                decoration: InputDecoration(
                  labelText: 'Soyad',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefon',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _firestore.collection('kullanicilar').doc(userId).update({
                  'ad': nameController.text.trim(),
                  'soyad': surnameController.text.trim(),
                  'telefon': phoneController.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                if (mounted) {
                  Navigator.pop(context);
                  _showSuccessSnackbar(context, 'Kullanıcı güncellendi');
                }
              } catch (e) {
                if (mounted) {
                  _showErrorSnackbar(context, 'Güncelleme başarısız: $e');
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String userId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text('Kullanıcıyı Sil'),
        ),
        content: const Text(
          'Bu kullanıcıyı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              try {
                await _firestore.collection('kullanicilar').doc(userId).delete();
                if (mounted) {
                  Navigator.pop(context);
                  _showSuccessSnackbar(context, 'Kullanıcı silindi');
                }
              } catch (e) {
                if (mounted) {
                  _showErrorSnackbar(context, 'Silme işlemi başarısız: $e');
                }
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showFeatureNotAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu özellik yakında eklenecek'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}