import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/interstitial_ad_manager.dart';
import '../state/app_strings.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;
  String? _scannedValue;

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? value = barcodes.first.rawValue;
      if (value != null) {
        setState(() {
          _hasScanned = true;
          _scannedValue = value;
        });
        _controller.stop();
      }
    }
  }

  Future<void> _openScannedLink() async {
    final lang = localeNotifier.value;
    if (_scannedValue == null) return;
    final Uri url = Uri.parse(_scannedValue!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      InterstitialAdManager.showAdIfNotPremium();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.get('qs_error_link', lang)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _scanAgain() {
    setState(() {
      _hasScanned = false;
      _scannedValue = null;
    });
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(AppStrings.get('qs_title', lang)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _controller,
                  builder: (context, state, child) {
                    switch (state.torchState) {
                      case TorchState.off:
                        return const Icon(Icons.flash_off_rounded, color: Colors.white);
                      case TorchState.on:
                        return const Icon(Icons.flash_on_rounded, color: Colors.amber);
                      case TorchState.auto:
                        return const Icon(Icons.flash_auto_rounded, color: Colors.blue);
                      case TorchState.unavailable:
                        return const Icon(Icons.no_flash_rounded, color: Colors.grey);
                    }
                  },
                ),
                onPressed: () => _controller.toggleTorch(),
              ),
              IconButton(
                icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
                onPressed: () => _controller.switchCamera(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Scanner View
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),

              // Custom Modern Overlay
              _buildScannerOverlay(isDark),

              // Result Bottom Sheet-like Panel
              if (_hasScanned)
                _buildResultPanel(lang, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScannerOverlay(bool isDark) {
    return Stack(
      children: [
        // Darkened background with a hole
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Premium Corners
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: _ScannerCornersPainter(color: AppColors.primary),
            ),
          ),
        ),
        // Hint text
        if (!_hasScanned)
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: ValueListenableBuilder<String>(
                  valueListenable: localeNotifier,
                  builder: (context, lang, child) => Text(
                    AppStrings.get('qs_scan_hint', lang),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 14, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultPanel(String lang, bool isDark) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppStrings.get('qs_scanned_prefix', lang),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _scannedValue ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, 
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    text: AppStrings.get('qs_open_button', lang),
                    onPressed: _openScannedLink,
                    icon: Icons.open_in_new_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _scanAgain,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      AppStrings.get('qs_rescan_button', lang),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ScannerCornersPainter extends CustomPainter {
  final Color color;
  _ScannerCornersPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 40.0;
    const cornerRadius = 32.0;
    final path = Path();

    // Top Left
    path.moveTo(0, cornerLength + cornerRadius);
    path.lineTo(0, cornerRadius);
    path.arcToPoint(const Offset(cornerRadius, 0), radius: const Radius.circular(cornerRadius));
    path.lineTo(cornerLength + cornerRadius, 0);

    // Top Right
    path.moveTo(size.width - cornerLength - cornerRadius, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(Offset(size.width, cornerRadius), radius: const Radius.circular(cornerRadius));
    path.lineTo(size.width, cornerLength + cornerRadius);

    // Bottom Right
    path.moveTo(size.width, size.height - cornerLength - cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.arcToPoint(Offset(size.width - cornerRadius, size.height), radius: const Radius.circular(cornerRadius));
    path.lineTo(size.width - cornerLength - cornerRadius, size.height);

    // Bottom Left
    path.moveTo(cornerLength + cornerRadius, size.height);
    path.lineTo(cornerRadius, size.height);
    path.arcToPoint(Offset(0, size.height - cornerRadius), radius: const Radius.circular(cornerRadius));
    path.lineTo(0, size.height - cornerLength - cornerRadius);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
