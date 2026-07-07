import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/interstitial_ad_manager.dart';

// ============================================================
// QR SCANNER - Camera thi QR code scan karva mate
// ============================================================
// Concept: MobileScanner widget camera kholi de chhe ane
// automatically QR code detect kare chhe. Jyare QR mali jay,
// tyare "onDetect" callback chale chhe je ma scanned data male chhe.
// ============================================================
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // MobileScannerController = camera ne control kare chhe
  // (jem ke flash on/off, camera switch karvu)
  final MobileScannerController _controller = MobileScannerController();

  // Ek j QR ne vaar-vaar detect na kare e mate flag rakhyo chhe
  bool _hasScanned = false;

  // Scan thayela result ne store karva mate
  String? _scannedValue;

  // Aa function jyare QR detect thay tyare chale chhe
  void _onDetect(BarcodeCapture capture) {
    // Jo pehla thi j scan thai gayu hoy to biju kai na karo
    if (_hasScanned) return;

    // capture.barcodes ma badha detect thayela codes ni list hoy chhe
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? value = barcodes.first.rawValue;
      if (value != null) {
        setState(() {
          _hasScanned = true;
          _scannedValue = value;
        });
        // Scan thay etle camera thobavi devi (battery/performance mate)
        _controller.stop();
      }
    }
  }

  // Scanned link ne kholva mate (jo e WhatsApp link hoy to WhatsApp khulshe)
  Future<void> _openScannedLink() async {
    if (_scannedValue == null) return;
    final Uri url = Uri.parse(_scannedValue!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);

      // Link khulai gayi, have ek interstitial ad batavo
      // (fakt free user ne j dekhashe)
      InterstitialAdManager.showAdIfNotPremium();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aa link khuli na shaki')),
      );
    }
  }

  // Firi thi scan karva mate (naavu QR scan karvu hoy to)
  void _scanAgain() {
    setState(() {
      _hasScanned = false;
      _scannedValue = null;
    });
    _controller.start(); // Camera firi chalu karo
  }

  @override
  void dispose() {
    // Screen band thay tyare camera pan band karvi jaruri chhe
    // (nahi to battery/resources vede thay)
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Flash on/off button
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera preview - screen no motto bhaag
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // MobileScanner = actual camera widget je QR detect kare chhe
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                // Camera upar ek chokhu/square overlay - user ne
                // batavva mate ke QR ne kya point karvo
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Niche no bhaag - scan result batavva mate
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: _scannedValue == null
              // Jyare sudhi kai scan nathi thayu
                  ? const Center(
                child: Text(
                  'QR code ne green box ni andar rakho...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              )
              // Jyare scan thai jay tyare result + buttons
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Scanned: $_scannedValue',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _openScannedLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Kholo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _scanAgain,
                          child: const Text('Firi Scan Karo'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
