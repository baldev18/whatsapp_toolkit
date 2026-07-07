import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../services/interstitial_ad_manager.dart';

// ============================================================
// STATUS SAVER - WhatsApp status ni photo/video save karva mate
// ============================================================
// Concept: WhatsApp jyare koi status (photo/video) batave chhe,
// tyare e file thoda samay mate ek "hidden" (chhupayela) folder
// ma save thay chhe:
//   Android 11+: Android/media/com.whatsapp/WhatsApp/Media/.Statuses
//   Junа phone:  WhatsApp/Media/.Statuses
// Apde e folder scan karie, andar ni images/videos batavie,
// ane user "Save" dabave to file ne Pictures/Status Saver
// folder ma copy kari devi jethi e Gallery ma pan dekhay
// ane WhatsApp status expire (24 kalak) thai jay to pan
// user pase rahi jay.
//
// IMPORTANT: Status joi shakva mate, user e pehla WhatsApp
// kholi ne e status ek vaar "view" karvo padse - tyar pachi j
// e aa hidden folder ma aave chhe.
// ============================================================
class StatusSaverScreen extends StatefulWidget {
  const StatusSaverScreen({super.key});

  @override
  State<StatusSaverScreen> createState() => _StatusSaverScreenState();
}

class _StatusSaverScreenState extends State<StatusSaverScreen> {
  // Be jagya e status hoy shake chhe (phone/Android version pramane) -
  // apde banne check karishu, jyu pehla malshe e vaparishu
  static const List<String> _possibleStatusPaths = [
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/WhatsApp/Media/.Statuses',
  ];

  // Jya save thayela statuses (already save karela) rakhishu
  static const String _savedFolderPath =
      '/storage/emulated/0/Pictures/Status Saver';

  List<File> _statusFiles = [];
  // Kaya files already save thai chuki chhe e yaad rakhva mate
  // (jethi "Saved" badge batavi shakay)
  Set<String> _savedFileNames = {};
  // Video thumbnails ne ek vaar banavya pachi yaad rakhva mate
  // (jethi scroll karta vaar-vaar navi thumbnail na banvi pade)
  final Map<String, Uint8List?> _videoThumbnailCache = {};

  bool _isLoading = true;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndScan();
  }

  Future<void> _checkPermissionAndScan() async {
    final status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      _scanStatuses();
    } else {
      setState(() => _permissionGranted = false);
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      _scanStatuses();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  // .Statuses folder mathi badhi images/videos vaanchva mate
  Future<void> _scanStatuses() async {
    setState(() => _isLoading = true);

    List<File> foundFiles = [];

    // Banne possible paths check karo, jya folder male tya thi vaanchvu
    for (var path in _possibleStatusPaths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        try {
          final entities = dir.listSync();
          for (var entity in entities) {
            if (entity is File) {
              final ext = entity.path.split('.').last.toLowerCase();
              // Fakt image/video files levi, ".nomedia" jevi files skip karvi
              if (['jpg', 'jpeg', 'png', 'webp', 'mp4'].contains(ext)) {
                foundFiles.add(entity);
              }
            }
          }
        } catch (e) {
          // Permission error aave to skip karo
        }
      }
    }

    // Save thayela statuses ni list pan vaanchi levi (already saved
    // che ke nahi e batavva mate)
    final savedDir = Directory(_savedFolderPath);
    Set<String> savedNames = {};
    if (await savedDir.exists()) {
      try {
        final savedEntities = savedDir.listSync();
        for (var entity in savedEntities) {
          if (entity is File) {
            savedNames.add(entity.path.split('/').last);
          }
        }
      } catch (e) {
        // ignore
      }
    }

    setState(() {
      _statusFiles = foundFiles;
      _savedFileNames = savedNames;
      _isLoading = false;
    });
  }

  bool _isVideo(File file) {
    return file.path.toLowerCase().endsWith('.mp4');
  }

  // Video file mathi ek chhoti thumbnail image banavva mate
  // Ek vaar banavya pachi cache ma save kari raakhie chhiye
  // jethi biji vaar firi thi banavvi na pade (performance mate)
  Future<Uint8List?> _getVideoThumbnail(String videoPath) async {
    // Jo pehla thi cache ma hoy to e j pacho aapi devo
    if (_videoThumbnailCache.containsKey(videoPath)) {
      return _videoThumbnailCache[videoPath];
    }

    try {
      final Uint8List? thumbBytes = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300, // Chhoti size, grid mate barabar chhe
        quality: 60,
      );
      _videoThumbnailCache[videoPath] = thumbBytes;
      return thumbBytes;
    } catch (e) {
      // Jo thumbnail banavva ma error aave (corrupt video, etc.)
      _videoThumbnailCache[videoPath] = null;
      return null;
    }
  }

  // Status file ne Pictures/Status Saver folder ma copy karva mate
  Future<void> _saveStatus(File file) async {
    final savedDir = Directory(_savedFolderPath);
    // Jo "Status Saver" folder na hoy to banavi levu
    if (!await savedDir.exists()) {
      await savedDir.create(recursive: true);
    }

    final String fileName = file.path.split('/').last;
    final String newPath = '$_savedFolderPath/$fileName';

    try {
      // Jo aa file pehla thi j save thai gayeli hoy to biju copy na banavo
      if (!await File(newPath).exists()) {
        await file.copy(newPath);
      }

      setState(() {
        _savedFileNames.add(fileName);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status Gallery ma save thai gayo! 📥')),
        );
      }

      // Status save thai gayo, have ek interstitial ad batavo
      // (fakt free user ne j dekhashe)
      InterstitialAdManager.showAdIfNotPremium();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save karva ma error aavi')),
        );
      }
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
          // Firi thi scan karva mate refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _scanStatuses,
          ),
        ],
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
                'Status joi ane save karva mate\n"All Files Access" permission jaruri chhe',
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
      // Jo koi status na male to samjaavvu ke user pehla
      // WhatsApp ma status joi lo
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Koi status nathi malyo.\nPehla WhatsApp kholi ne '
                    'koi status ek vaar joi lo, pachi ahiya '
                    'refresh karo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      )
      // Statuses ni grid batavvi
          : RefreshIndicator(
        onRefresh: _scanStatuses,
        child: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: _statusFiles.length,
          itemBuilder: (context, index) {
            final file = _statusFiles[index];
            final fileName = file.path.split('/').last;
            final isSaved = _savedFileNames.contains(fileName);
            final isVideo = _isVideo(file);

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // Video files mate real thumbnail generate karie
                    // chhiye (FutureBuilder vaparyu chhe kem ke
                    // thumbnail banavvama thodo time lage chhe),
                    // image files mate direct preview batavie chhiye
                    child: isVideo
                        ? FutureBuilder<Uint8List?>(
                      future: _getVideoThumbnail(file.path),
                      builder: (context, snapshot) {
                        // Jyare sudhi thumbnail banti hoy tyare
                        // ek chhoto loading spinner batavo
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            color: Colors.black87,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          );
                        }

                        final thumbBytes = snapshot.data;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            if (thumbBytes != null)
                            // Real video frame image tarike batavvi
                              Image.memory(thumbBytes, fit: BoxFit.cover)
                            else
                            // Jo thumbnail na bani shaki to
                            // fallback tarike black background
                              Container(color: Colors.black87),
                            // Video par hammesha ek play icon
                            // overlay tarike batavvi, jethi user
                            // ne khabar pade ke aa video chhe
                            const Center(
                              child: Icon(Icons.play_circle_fill,
                                  color: Colors.white, size: 40),
                            ),
                          ],
                        );
                      },
                    )
                        : Image.file(
                      file,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                  // Niche save button - jo already saved hoy to
                  // green checkmark batavo, nahi to save icon
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: isSaved ? null : () => _saveStatus(file),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSaved ? Colors.green : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2)),
                          ],
                        ),
                        child: Icon(
                          isSaved ? Icons.check : Icons.download,
                          size: 18,
                          color: isSaved ? Colors.white : Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
