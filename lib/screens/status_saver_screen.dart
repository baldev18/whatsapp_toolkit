import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import '../services/file_utils.dart';
import '../state/app_strings.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';

class StatusSaverScreen extends StatefulWidget {
  const StatusSaverScreen({super.key});

  @override
  State<StatusSaverScreen> createState() => _StatusSaverScreenState();
}

class _StatusSaverScreenState extends State<StatusSaverScreen> {
  static const String _statusPath = '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';

  List<dynamic> _statusFiles = [];
  bool _isLoading = true;
  bool _permissionGranted = false;
  final Set<String> _selectedPaths = {};

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _checkPermissionAndLoad();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _checkPermissionAndLoad() async {
    final status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      _loadStatuses();
    } else {
      setState(() {
        _permissionGranted = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      _loadStatuses();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _loadStatuses() async {
    setState(() => _isLoading = true);
    final files = FileUtils.getStatuses(_statusPath);
    setState(() {
      _statusFiles = files;
      _isLoading = false;
    });
  }

  bool _isVideo(String path) => path.toLowerCase().endsWith('.mp4');

  Future<void> _saveStatus(dynamic file) async {
    final lang = localeNotifier.value;
    if (kIsWeb) return;
    try {
      if (_isVideo(file.path)) {
        await Gal.putVideo(file.path, album: 'Status Saver');
      } else {
        await Gal.putImage(file.path, album: 'Status Saver');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.get('ss_save_success', lang)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.get('ss_save_error', lang) + e.toString()),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _saveSelected() async {
    final lang = localeNotifier.value;
    if (kIsWeb) return;
    int savedCount = 0;
    for (var path in _selectedPaths) {
      try {
        if (_isVideo(path)) {
          await Gal.putVideo(path, album: 'Status Saver');
        } else {
          await Gal.putImage(path, album: 'Status Saver');
        }
        savedCount++;
      } catch (e) {}
    }
    setState(() => _selectedPaths.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$savedCount ${AppStrings.get('ss_multi_save_success', lang)}'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        if (kIsWeb) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.get('ss_title', lang))),
            body: Center(child: Text(AppStrings.get('ss_web_error', lang))),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('ss_title', lang)),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
            actions: [
              if (_selectedPaths.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.download_done_rounded, color: Colors.white),
                  onPressed: _saveSelected,
                  tooltip: 'Save Selected',
                ),
              if (_permissionGranted)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _loadStatuses,
                ),
            ],
          ),
          body: !_permissionGranted
              ? _buildPermissionView(lang, isDark)
              : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _statusFiles.isEmpty
                      ? _buildEmptyView(lang, isDark)
                      : _buildStatusGrid(lang, isDark),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_open_rounded, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.get('ss_permission_msg', lang),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: AppStrings.get('ss_permission_button', lang),
            onPressed: _requestPermission,
            icon: Icons.security_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String lang, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text(
            AppStrings.get('ss_empty', lang),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid(String lang, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: _statusFiles.length,
      itemBuilder: (context, index) {
        final file = _statusFiles[index];
        final isSelected = _selectedPaths.contains(file.path);
        final isVideo = _isVideo(file.path);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedPaths.remove(file.path);
              } else {
                _selectedPaths.add(file.path);
              }
            });
          },
          onLongPress: () => _saveStatus(file),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder/Thumbnail
                  isVideo
                      ? Container(
                          color: Colors.black87,
                          child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
                        )
                      : Image.file(file, fit: BoxFit.cover),
                  
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Selection Overlay
                  if (isSelected)
                    Container(
                      color: AppColors.primary.withOpacity(0.3),
                      child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
                    ),

                  // Video Indicator
                  if (isVideo && !isSelected)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
