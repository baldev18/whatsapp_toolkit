import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/app_notifiers.dart';
import '../services/interstitial_ad_manager.dart';

// ============================================================
// TextRepeaterScreen = aapnu mukhya screen
// StatefulWidget vaparyu chhe kem ke aa screen ma data
// (jem ke text, number) badalay chhe user na input pramane
// ============================================================
class TextRepeaterScreen extends StatefulWidget {
  const TextRepeaterScreen({super.key});

  @override
  State<TextRepeaterScreen> createState() => _TextRepeaterScreenState();
}

class _TextRepeaterScreenState extends State<TextRepeaterScreen> {
  // TextEditingController = user je textbox ma type kare
  // e value ne "read" karva mate vaparay chhe
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  // Aa variable ma final repeated text store thase, jene
  // screen par batavishu
  String _resultText = '';

  // Aa function "Generate" button dabave tyare chalse
  void _generateRepeatedText() {
    // User e je message type karyo e levu
    String message = _messageController.text;

    // User e je number nakhyo e levu, ane text (String) mathi
    // number (int) ma convert karvu
    int count = int.tryParse(_countController.text) ?? 0;

    // Jo message khali hoy athva count 0/negative hoy
    // to error batavo, kai na karo
    if (message.isEmpty || count <= 0) {
      setState(() {
        _resultText = 'Krupa karine message ane sachu number nakho';
      });
      return; // Aagad function chalvanu band karo
    }

    // Safety: bahu vadhare repeat na thay (app hang na thay)
    // Premium user ne vadhare limit (5000), free user ne 500
    final int maxLimit = isPremiumNotifier.value ? 5000 : 500;
    if (count > maxLimit) {
      count = maxLimit;
      if (!isPremiumNotifier.value) {
        // Free user ne khabar padvi joiye ke limit chhe ane
        // premium thi vadhare malshe
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Free limit 500 chhe. Premium thi 5000 sudhi!'),
          ),
        );
      }
    }

    // Message ne "count" vaar repeat karvu
    // List.filled banave chhe message ni "count" copies
    // ane join('\n') dareke copy vachche new line mukine jode chhe
    String repeated = List.filled(count, message).join('\n');

    // setState() = Flutter ne kahe chhe ke "data badlai gayu chhe,
    // screen ne re-draw karo nava data sathe"
    setState(() {
      _resultText = repeated;
    });
  }

  // Aa function result text ne WhatsApp ma share kare chhe
  Future<void> _shareToWhatsApp() async {
    // Jo result khali hoy to kai na karo
    if (_resultText.isEmpty) {
      setState(() {
        _resultText = 'Pehla Generate button dabao, pachi Share karo';
      });
      return;
    }

    // wa.me link banaviye - aa link WhatsApp automatically kholi
    // aape chhe pre-filled text sathe
    // Uri.encodeComponent() text ne URL-safe banave chhe
    // (spaces, special characters properly handle thay)
    final String encodedText = Uri.encodeComponent(_resultText);
    final Uri whatsappUrl = Uri.parse('https://wa.me/?text=$encodedText');

    // canLaunchUrl = check kare chhe ke aa URL khulva layak chhe ke nahi
    if (await canLaunchUrl(whatsappUrl)) {
      // externalApplication mode = WhatsApp app ma j khulse
      // (browser ma nahi)
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);

      // Share thai gayu, have ek interstitial ad batavo
      // (fakt free user ne j dekhashe)
      InterstitialAdManager.showAdIfNotPremium();
    } else {
      // Jo WhatsApp install j na hoy phone ma
      setState(() {
        _resultText = 'WhatsApp install nathi ke khulai nathi shakto';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Upar ni AppBar (title bar)
      appBar: AppBar(
        title: const Text('Text Repeater'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      // Body ma badhu content, scroll thai shake tevu (SingleChildScrollView)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Message input box
            const Text(
              'Message nakho:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Dakhla tarike: Happy Birthday!',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Repeat count input box
            const Text(
              'Ketli vaar repeat karvu:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _countController,
              // keyboardType: number - mobile ma number keyboard khulse
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Dakhla tarike: 10',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Generate button
            ElevatedButton(
              onPressed: _generateRepeatedText,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Generate',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),

            // Share to WhatsApp button
            ElevatedButton.icon(
              onPressed: _shareToWhatsApp,
              icon: const Icon(Icons.chat, size: 20),
              label: const Text(
                'Share to WhatsApp',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 20),

            // Result batavva mate box - fakt tyare j dekhay
            // jyare _resultText khali na hoy
            if (_resultText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  // SelectableText vaparyu chhe jethi user
                  // aa text ne copy kari shake (long-press karine)
                  _resultText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
