import 'package:flutter/material.dart';
import 'dart:io';
import '../services/interstitial_ad_manager.dart';

// ============================================================
// CATEGORY FILES SCREEN - Ek category ni andar ni files batave,
// select kari ne delete karva ni option sathe
// ============================================================
class CategoryFilesScreen extends StatefulWidget {
  final String categoryName;
  final String folderPath;

  const CategoryFilesScreen({
    super.key,
    required this.categoryName,
    required this.folderPath,
  });

  @override
  State<CategoryFilesScreen> createState() => _CategoryFilesScreenState();
}

class _CategoryFilesScreenState extends State<CategoryFilesScreen> {
  List<File> _files = [];
  // Kaya files select thayeli chhe e track karva mate (delete mate)
  final Set<String> _selectedPaths = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    final dir = Directory(widget.folderPath);
    List<File> files = [];

    if (await dir.exists()) {
      try {
        final entities = dir.listSync(recursive: true);
        for (var entity in entities) {
          if (entity is File) {
            files.add(entity);
          }
        }
      } catch (e) {
        // Error aave to khali list rakho
      }
    }

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

  // Selected files ne delete karva mate
  Future<void> _deleteSelected() async {
    // Confirmation dialog batavvo - user ne khatri karva mate
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Karvu?'),
        content: Text('${_selectedPaths.length} files delete thai jashe. Aa pacha nahi aavi shake.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Dareke selected file ne delete karo
    for (var path in _selectedPaths) {
      try {
        await File(path).delete();
      } catch (e) {
        // Jo koi file delete na thai shake to skip karo
      }
    }

    _selectedPaths.clear();
    _loadFiles(); // List firi load karo (delete thayela files hatavva)

    // Delete puru thai gayu, have ek interstitial ad batavo
    // (fakt free user ne j dekhashe)
    InterstitialAdManager.showAdIfNotPremium();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedPaths.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelected,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
          ? const Center(child: Text('Aa category ma koi file nathi'))
          : ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          final isSelected = _selectedPaths.contains(file.path);
          final fileName = file.path.split('/').last;

          return ListTile(
            leading: Checkbox(
              value: isSelected,
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
            title: Text(fileName, overflow: TextOverflow.ellipsis),
            subtitle: FutureBuilder<int>(
              future: file.length(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(_formatSize(snapshot.data!));
                }
                return const Text('...');
              },
            ),
          );
        },
      ),
    );
  }
}
