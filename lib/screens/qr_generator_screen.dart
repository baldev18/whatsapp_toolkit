import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ============================================================
// QR GENERATOR - Phone number mathi WhatsApp chat QR code
// ============================================================
// Concept: user no phone number levu, wa.me link banavvi,
// ane e link ne QR code ma convert karvi. Koi bijo vyakti
// aa QR scan kare to seedhu WhatsApp chat khuli jay - contact
// save karya vagar.
// ============================================================
class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  // Country code ane number mate alag-alag controllers
  final TextEditingController _countryCodeController =
  TextEditingController(text: '91'); // Default India (+91)
  final TextEditingController _phoneController = TextEditingController();

  // Aa variable ma final wa.me link store thay chhe
  // Jyare khali hoy tyare QR na dekhay
  String _qrData = '';

  // "Generate QR" button dabave tyare aa function chale chhe
  void _generateQr() {
    String countryCode = _countryCodeController.text.trim();
    String phone = _phoneController.text.trim();

    // Number mathi spaces, dashes, + hatavva mate (jo user e nakhya hoy)
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    countryCode = countryCode.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.isEmpty || countryCode.isEmpty) {
      setState(() {
        _qrData = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Krupa karine country code ane number nakho'),
        ),
      );
      return;
    }

    // wa.me link format: https://wa.me/<countrycode><number>
    // Dakhla tarike: https://wa.me/919876543210
    setState(() {
      _qrData = 'https://wa.me/$countryCode$phone';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Generator'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Country Code:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _countryCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '+',
                hintText: 'Dakhla tarike: 91',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Phone Number (without country code):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Dakhla tarike: 9876543210',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _generateQr,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Generate QR',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

            // QR code fakt tyare j dekhay jyare _qrData khali na hoy
            if (_qrData.isNotEmpty) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  // QrImageView = qr_flutter package no widget je
                  // actual QR code draw kare chhe
                  child: QrImageView(
                    data: _qrData, // Aa j text/link QR ma encode thay chhe
                    version: QrVersions.auto,
                    size: 220,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _qrData,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
