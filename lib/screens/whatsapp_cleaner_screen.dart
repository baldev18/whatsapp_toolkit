import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/file_utils.dart';
import '../models/media_category.dart';
import '../state/app_strings.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';
import 'category_files_screen.dart';

class WhatsAppCleanerScreen extends StatefulWidget {
  const WhatsAppCleanerScreen({super.key});

  @override
  State<WhatsAppCleanerScreen> createState() => _WhatsAppCleanerScreenState();
}

class _WhatsAppCleanerScreenState extends State<WhatsAppCleanerScreen> {
  static const String _mediaBasePath = '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media';

  Map<String, int> _categorySizes = {};
  Map<String, int> _categoryFileCounts = {};
  bool _isLoading = false;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _checkPermissionAndScan();
    }
  }

  Future<void> _checkPermissionAndScan() async {
    final status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      _scanAllCategories();
    } else {
      setState(() => _permissionGranted = false);
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      _scanAllCategories();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  List<MediaCategory> _getCategories(String lang) {
    return [
      MediaCategory(name: AppStrings.get('wc_cat_images', lang), folderName: 'WhatsApp Images', icon: Icons.image_rounded),
      MediaCategory(name: AppStrings.get('wc_cat_videos', lang), folderName: 'WhatsApp Video', icon: Icons.videocam_rounded),
      MediaCategory(name: AppStrings.get('wc_cat_docs', lang), folderName: 'WhatsApp Documents', icon: Icons.description_rounded),
      MediaCategory(name: AppStrings.get('wc_cat_audio', lang), folderName: 'WhatsApp Audio', icon: Icons.audiotrack_rounded),
      MediaCategory(name: AppStrings.get('wc_cat_voice', lang), folderName: 'WhatsApp Voice Notes', icon: Icons.mic_rounded),
    ];
  }

  Future<void> _scanAllCategories() async {
    setState(() => _isLoading = true);
    Map<String, int> sizes = {};
    Map<String, int> counts = {};

    final categories = _getCategories('en');

    for (var category in categories) {
      final path = '$_mediaBasePath/${category.folderName}';
      final files = FileUtils.listDirectory(path);
      int totalSize = 0;
      for (var file in files) {
        totalSize += await FileUtils.getFileLength(file);
      }
      sizes[category.folderName] = totalSize;
      counts[category.folderName] = files.length;
    }

    setState(() {
      _categorySizes = sizes;
      _categoryFileCounts = counts;
      _isLoading = false;
    });
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 MB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        if (kIsWeb) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.get('wc_title', lang))),
            body: Center(child: Text(AppStrings.get('wc_web_error', lang))),
          );
        }

        final int totalBytes = _categorySizes.values.fold(0, (sum, size) => sum + size);
        final categories = _getCategories(lang);

        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('wc_title', lang)),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
          ),
          body: !_permissionGranted
              ? _buildPermissionView(lang, isDark)
              : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMainView(lang, isDark, totalBytes, categories),
        );
      },
    );
  }

  Widget _buildPermissionView(String lang, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cleaning_services_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            AppStrings.get('wc_permission_msg', lang),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: AppStrings.get('wc_permission_button', lang),
            onPressed: _requestPermission,
            icon: Icons.security_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildMainView(String lang, bool isDark, int totalBytes, List<MediaCategory> categories) {
    return RefreshIndicator(
      onRefresh: _scanAllCategories,
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          // Storage Summary Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)] 
                    : [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.speed_rounded, color: Colors.white, size: 40),
                const SizedBox(height: 16),
                Text(
                  AppStrings.get('wc_total_size_label', lang),
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatSize(totalBytes),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Optimization Required',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),

          // Categories Title
          const Text(
            'Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Grid of Categories
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final size = _categorySizes[category.folderName] ?? 0;
              final count = _categoryFileCounts[category.folderName] ?? 0;
              
              return _buildCategoryCard(category, size, count, lang, isDark);
            },
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(MediaCategory cat, int size, int count, String lang, bool isDark) {
    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryFilesScreen(
                categoryName: cat.name,
                folderPath: '$_mediaBasePath/${cat.folderName}',
              ),
            ),
          ).then((_) => _scanAllCategories());
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, color: AppColors.primary, size: 24),
              ),
              const Spacer(),
              Text(
                cat.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                _formatSize(size),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
