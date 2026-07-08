// ============================================================
// STATUS SAVER - WhatsApp status (photos/videos) save karva mate
// ============================================================
// Aa file "status_saver_screen.dart" naame save karo, jya tamari
// baaki ni screens chhe e j folder ma
//
// IMPORTANT: Aa feature mate WhatsAppCleanerScreen jevi j
// "All Files Access" permission joiye chhe (permission_handler
// ane 'dart:io' pehla thi j tamara project ma chhe)
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';

class StatusSaverScreen extends StatefulWidget {
  const StatusSaverScreen({super.key});

  @override
  State<StatusSaverScreen> createState() => _StatusSaverScreenState();
}

class _StatusSaverScreenState extends State<StatusSaverScreen> {
  // WhatsApp na "currently viewed statuses" aa hidden folder ma
  // save thay chhe. Naam ni shuruaat ma "." chhe etle e "hidden"
  // folder gaṇay chhe (normal file manager ma na dekhay)
  static const String _statusPath =
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';

  List<File> _statusFiles = [];
  bool _isLoading = true;
  bool _permissionGranted = false;

  // Kai files select thai chhe (save/share mate)
  final Set<String> _selectedPaths = {};

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoad();
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

  // .Statuses folder mathi badhi image/video files vaanchvi
  Future<void> _loadStatuses() async {
    setState(() => _isLoading = true);

    final dir = Directory(_statusPath);
    List<File> files = [];

    if (await dir.exists()) {
      try {
        final entities = dir.listSync();
        for (var entity in entities) {
          if (entity is File) {
            final ext = entity.path.toLowerCase();
            // Fakt images ane videos j levi, ".nomedia" jevi
            // system files skip karvi
            if (ext.endsWith('.jpg') ||
                ext.endsWith('.jpeg') ||
                ext.endsWith('.png') ||
                ext.endsWith('.mp4')) {
              files.add(entity);
            }
          }
        }
      } catch (e) {
        // Error aave to khali list rakho
      }
    }

    setState(() {
      _statusFiles = files;
      _isLoading = false;
    });
  }

  bool _isVideo(String path) => path.toLowerCase().endsWith('.mp4');

  // Ek status ne gallery ma save karva mate
  Future<void> _saveStatus(File file) async {
    try {
      if (_isVideo(file.path)) {
        // Video ne gallery ma save karvu
        await Gal.putVideo(file.path, album: 'Status Saver');
      } else {
        // Image ne gallery ma save karvu
        await Gal.putImage(file.path, album: 'Status Saver');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gallery ma save thai gayu! 📁')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save karva ma error: $e')),
        );
      }
    }
  }

  // Selected badha statuses ek sathe save karva mate
  Future<void> _saveSelected() async {
    int savedCount = 0;
    for (var path in _selectedPaths) {
      try {
        if (_isVideo(path)) {
          await Gal.putVideo(path, album: 'Status Saver');
        } else {
          await Gal.putImage(path, album: 'Status Saver');
        }
        savedCount++;
      } catch (e) {
        // Ek file fail thay to baki ni chalu rakhvi
      }
    }

    setState(() => _selectedPaths.clear());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$savedCount status(es) save thai gaya! 📁')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Saver'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedPaths.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _saveSelected,
            ),
          if (_permissionGranted)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadStatuses,
            ),
        ],
      ),
      body: !_permissionGranted
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Status files vaanchva mate\n"All Files Access" permission jaruri chhe',
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
          ? const Center(child: CircularProgressIndicator())
          : _statusFiles.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Koi status nathi malyu.\nPehla WhatsApp kholine '
                    'kai status joi lo, pachi ahi refresh karo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        // 3 column no grid banavvo
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: _statusFiles.length,
        itemBuilder: (context, index) {
          final file = _statusFiles[index];
          final isSelected = _selectedPaths.contains(file.path);
          final isVideo = _isVideo(file.path);

          return GestureDetector(
            onTap: () {
              // Tap karta select/deselect thay
              setState(() {
                if (isSelected) {
                  _selectedPaths.remove(file.path);
                } else {
                  _selectedPaths.add(file.path);
                }
              });
            },
            onLongPress: () => _saveStatus(file),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image thumbnail - video hoy to bhi
                // pehlu frame ke placeholder dekhay
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isVideo
                      ? Container(
                    color: Colors.black87,
                    child: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 36,
                    ),
                  )
                      : Image.file(file, fit: BoxFit.cover),
                ),
                // Selected hoy to green checkmark dekhay
                if (isSelected)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Colors.white),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}