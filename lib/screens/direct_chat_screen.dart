import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// DIRECT CHAT - Number ne contact list ma save karya vagar,
// seedhu tena sathe WhatsApp chat kholi devu
// ============================================================
// Concept: QR Generator ni jem j "wa.me" link vaparie chhiye,
// pan aa vaar QR banavi ne screen par batavvani jagya e apde
// seedhu link ne "launch" (kholi) karie chhiye, jethi WhatsApp
// tarat j e number no chat screen kholi de.
// User ichche to sathe ek pre-filled message pan nakhi shake.
// ============================================================
class DirectChatScreen extends StatefulWidget {
  const DirectChatScreen({super.key});

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  // Country code ane number mate alag-alag controllers
  final TextEditingController _countryCodeController =
  TextEditingController(text: '91'); // Default India (+91)
  final TextEditingController _phoneController = TextEditingController();
  // Optional pre-filled message - user ichche to khali pan rakhi shake
  final TextEditingController _messageController = TextEditingController();

  bool _isOpening = false;

  // "Chat Kholo" button dabave tyare aa function chale chhe
  Future<void> _openDirectChat() async {
    String countryCode = _countryCodeController.text.trim();
    String phone = _phoneController.text.trim();

    // Number ane country code mathi spaces, dashes, + hatavva mate
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    countryCode = countryCode.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.isEmpty || countryCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Krupa karine country code ane number nakho'),
        ),
      );
      return;
    }

    setState(() => _isOpening = true);

    // wa.me link banaviye - jo message type karyu hoy to e sathe
    // encode kari ne jodi diye chhiye
    final String message = _messageController.text.trim();
    final String fullNumber = '$countryCode$phone';
    final Uri whatsappUrl = message.isEmpty
        ? Uri.parse('https://wa.me/$fullNumber')
        : Uri.parse('https://wa.me/$fullNumber?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp install nathi ke khulai nathi shakto'),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isOpening = false);
    }
  }

  @override
  void dispose() {
    // Controllers ne dispose karvi jaruri chhe, nahi to memory leak thay
    _countryCodeController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Chat'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Explanation card - user ne samjavva mate
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Aa number ne tamara phone ma contact tarike save '
                    'karya vagar, seedhu tena sathe WhatsApp chat '
                    'kholi shakay chhe.',
                style: TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),

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

            const Text(
              'Message (optional):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Dakhla tarike: Hello! Kem cho?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Chat kholo button
            ElevatedButton.icon(
              onPressed: _isOpening ? null : _openDirectChat,
              icon: _isOpening
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.chat, size: 20),
              label: Text(
                _isOpening ? 'Khulai rahyu chhe...' : 'Chat Kholo',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
