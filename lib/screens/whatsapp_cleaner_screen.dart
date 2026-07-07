import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/media_category.dart';
import 'category_files_screen.dart';

// ============================================================
// WHATSAPP CLEANER - Junk files (photos/videos/docs) find & delete
// ============================================================
// Concept: WhatsApp badhi media file ne ek fix folder ma save
// kare chhe (Android 11+ ma: Android/media/com.whatsapp/WhatsApp/Media/).
// Apde e folder ni andar ni categories (Images, Video, Documents,
// Audio) scan karie, dareke ni size ganie, ane user ne delete
// karva ni option aapie.
// ============================================================

class WhatsAppCleanerScreen extends StatefulWidget {
  const WhatsAppCleanerScreen({super.key});

  @override
  State<WhatsAppCleanerScreen> createState() => _WhatsAppCleanerScreenState();
}

class _WhatsAppCleanerScreenState extends State<WhatsAppCleanerScreen> {
  // Android 11+ ma WhatsApp media aa path par hoy chhe
  static const String _mediaBasePath =
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media';

  // Badhi categories ni list je apde scan karishu
  final List<MediaCategory> _categories = [
    MediaCategory(
        name: 'Images', folderName: 'WhatsApp Images', icon: Icons.image),
    MediaCategory(
        name: 'Videos', folderName: 'WhatsApp Video', icon: Icons.videocam),
    MediaCategory(
        name: 'Documents',
        folderName: 'WhatsApp Documents',
        icon: Icons.description),
    MediaCategory(
        name: 'Audio', folderName: 'WhatsApp Audio', icon: Icons.audiotrack),
    MediaCategory(
        name: 'Voice Notes',
        folderName: 'WhatsApp Voice Notes',
        icon: Icons.mic),
  ];

  // Har category ni total size (bytes ma) store karva mate map
  Map<String, int> _categorySizes = {};
  Map<String, int> _categoryFileCounts = {};

  bool _isLoading = false;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndScan();
  }

  // Permission check kari ne, malto hoy to scan chalu karo
  Future<void> _checkPermissionAndScan() async {
    // Android 11+ mate "manageExternalStorage" permission jaruri chhe
    final status = await Permission.manageExternalStorage.status;

    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      _scanAllCategories();
    } else {
      setState(() => _permissionGranted = false);
    }
  }

  // Permission maangva mate (button dabave tyare)
  Future<void> _requestPermission() async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      _scanAllCategories();
    } else if (status.isPermanentlyDenied) {
      // Jo user e "Deny" karyu ane firi na puchhvanu kahyu hoy,
      // to Settings screen kholi aapvi
      openAppSettings();
    }
  }

  // Badhi categories ni size scan karva mate
  Future<void> _scanAllCategories() async {
    setState(() => _isLoading = true);

    Map<String, int> sizes = {};
    Map<String, int> counts = {};

    for (var category in _categories) {
      final dir = Directory('$_mediaBasePath/${category.folderName}');
      int totalSize = 0;
      int fileCount = 0;

      // Jo folder exist kare to j andar jaine files vaanchvi
      if (await dir.exists()) {
        try {
          // listSync = folder ni andar ni badhi files/folders ni list
          // recursive: true = andar na sub-folders pan check karo
          final entities = dir.listSync(recursive: true);
          for (var entity in entities) {
            if (entity is File) {
              totalSize += await entity.length();
              fileCount++;
            }
          }
        } catch (e) {
          // Jo koi permission error aave to skip karo e category
        }
      }

      sizes[category.folderName] = totalSize;
      counts[category.folderName] = fileCount;
    }

    setState(() {
      _categorySizes = sizes;
      _categoryFileCounts = counts;
      _isLoading = false;
    });
  }

  // Bytes ne "MB" ke "GB" jevi readable form ma convert karvu
  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 MB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    // Total size badhi categories ni add karine
    final int totalBytes =
    _categorySizes.values.fold(0, (sum, size) => sum + size);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Cleaner'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: !_permissionGranted
      // Jo permission nathi malti to permission maangvanu screen
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'WhatsApp files scan karva mate\n"All Files Access" permission jaruri chhe',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _requestPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Permission Aapo'),
              ),
            ],
          ),
        ),
      )
          : _isLoading
      // Scan chalu hoy tyare loading spinner
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        // Niche khenchi ne (pull-to-refresh) firi scan thay
        onRefresh: _scanAllCategories,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Total space no summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total WhatsApp Media Size',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatSize(totalBytes),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dareke category nu card
            ..._categories.map((category) {
              final size = _categorySizes[category.folderName] ?? 0;
              final count =
                  _categoryFileCounts[category.folderName] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(category.icon, color: Colors.green),
                  title: Text(category.name),
                  subtitle: Text('$count files'),
                  trailing: Text(
                    _formatSize(size),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () {
                    // Category tap karta e ni andar ni files
                    // batavti screen par jaay
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryFilesScreen(
                          categoryName: category.name,
                          folderPath:
                          '$_mediaBasePath/${category.folderName}',
                        ),
                      ),
                    ).then((_) {
                      // Pacha aavta firi scan karo (jo delete
                      // karyu hoy to size update thay)
                      _scanAllCategories();
                    });
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
