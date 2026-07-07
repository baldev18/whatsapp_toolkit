import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// BLANK MESSAGE - Khali/invisible message WhatsApp par moklva mate
// ============================================================
// Concept: WhatsApp truly-empty message send nathi karva deto.
// Etle apde "invisible" Unicode character vaparie chhiye -
// aa character najare dekhato nathi, pan WhatsApp mate valid
// text chhe, etle message send thai jay chhe (khali jevo dekhay).
// ============================================================
class BlankMessageScreen extends StatefulWidget {
  const BlankMessageScreen({super.key});

  @override
  State<BlankMessageScreen> createState() => _BlankMessageScreenState();
}

class _BlankMessageScreenState extends State<BlankMessageScreen> {
  // U+3164 = Hangul Filler character - najare khali dekhay chhe
  // pan actually ek valid character chhe
  static const String _invisibleChar = '\u3164';

  // User ketla "blank lines" moklva mage chhe e select kare chhe
  int _lineCount = 1;

  // Aa function invisible characters ne WhatsApp ma share kare chhe
  Future<void> _sendBlankMessage() async {
    // Invisible character ne _lineCount vaar repeat karie,
    // dareke vachche new line (\n) mukine
    String blankText = List.filled(_lineCount, _invisibleChar).join('\n');

    final String encodedText = Uri.encodeComponent(blankText);
    final Uri whatsappUrl = Uri.parse('https://wa.me/?text=$encodedText');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      // Jo error aave to user ne message batavva mate SnackBar vaparyu
      // (niche thi ek chhoti popup dekhay chhe)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp khuli na shakyu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blank Message'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
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
                'Aa feature ek "invisible" message moklse jethi WhatsApp '
                    'chat ma khali/blank message aavyu hoy tevu lagshe.',
                style: TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Ketla khali line moklva chhe:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Slider - user finger thi ghasarke number select kare chhe
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _lineCount.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    activeColor: Colors.green,
                    // Aa label slider ni upar current value batave chhe
                    label: _lineCount.toString(),
                    onChanged: (double value) {
                      // setState = screen ne naavi value sathe redraw karo
                      setState(() {
                        _lineCount = value.toInt();
                      });
                    },
                  ),
                ),
                // Current selected number, box ma
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$_lineCount',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Preview box - batave chhe ke kevu dekhashe (khali jevu)
            const Text(
              'Preview:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Text(
                '(najare kai j nahi dekhay - e j to khaas vaat chhe!)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const Spacer(),

            // Send button
            ElevatedButton.icon(
              onPressed: _sendBlankMessage,
              icon: const Icon(Icons.chat, size: 20),
              label: const Text(
                'Send Blank Message',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
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
