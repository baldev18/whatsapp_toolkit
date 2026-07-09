import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/file_utils.dart';
import '../services/interstitial_ad_manager.dart';
import '../state/app_strings.dart';
import '../config/app_theme.dart';

class CategoryFilesScreen extends StatefulWidget {
  final String categoryName;
  final String folderPath;

  const CategoryFilesScreen({super.key, required this.categoryName, required this.folderPath});

  @override
  State<CategoryFilesScreen> createState() => _CategoryFilesScreenState();
}

class _CategoryFilesScreenState extends State<CategoryFilesScreen> {
  List<dynamic> _files = [];
  final Set<String> _selectedPaths = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadFiles();
    }
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    final files = FileUtils.listDirectory(widget.folderPath);
    setState(() {
      _files = files;
      _isLoading = false;
    });
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _deleteSelected() async {
    final lang = localeNotifier.value;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(AppStrings.get('cf_delete_title', lang)),
        content: Text('${_selectedPaths.length} ${AppStrings.get('cf_delete_msg', lang)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.get('cf_cancel', lang)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(80, 40),
            ),
            child: Text(AppStrings.get('cf_delete_button', lang)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    for (var path in _selectedPaths) {
      await FileUtils.deleteFile(path);
    }

    _selectedPaths.clear();
    _loadFiles();
    InterstitialAdManager.showAdIfNotPremium();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        if (kIsWeb) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.categoryName)),
            body: Center(child: Text(AppStrings.get('cf_web_error', lang))),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.categoryName),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
            actions: [
              if (_selectedPaths.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                  onPressed: _deleteSelected,
                ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _files.isEmpty
                  ? _buildEmptyState(lang, isDark)
                  : _buildFileList(isDark),
        );
      },
    );
  }

  Widget _buildEmptyState(String lang, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            AppStrings.get('cf_empty', lang),
            style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _files.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final file = _files[index];
        final isSelected = _selectedPaths.contains(file.path);
        final fileName = file.path.split('/').last;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: isDark ? [] : [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Checkbox(
              value: isSelected,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    _selectedPaths.add(file.path);
                  } else {
                    _selectedPaths.remove(file.path);
                  }
                });
              },
            ),
            title: Text(
              fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: FutureBuilder<int>(
              future: FileUtils.getFileLength(file),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    _formatSize(snapshot.data!),
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  );
                }
                return const Text('...');
              },
            ),
          ),
        );
      },
    );
  }
}
