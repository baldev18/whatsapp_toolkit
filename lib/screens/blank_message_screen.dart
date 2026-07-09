import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/app_strings.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';

class BlankMessageScreen extends StatefulWidget {
  const BlankMessageScreen({super.key});

  @override
  State<BlankMessageScreen> createState() => _BlankMessageScreenState();
}

class _BlankMessageScreenState extends State<BlankMessageScreen> {
  static const String _invisibleChar = '\u3164';
  int _lineCount = 1;

  Future<void> _sendBlankMessage() async {
    final lang = localeNotifier.value;
    String blankText = List.filled(_lineCount, _invisibleChar).join('\n');
    final String encodedText = Uri.encodeComponent(blankText);
    final Uri whatsappUrl = Uri.parse('https://wa.me/?text=$encodedText');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('bm_whatsapp_error', lang)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('bm_appbar_title', lang)),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    AppStrings.get('bm_explanation', lang),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                // Slider Control Section
                Column(
                  children: [
                    Text(
                      AppStrings.get('bm_line_count_label', lang),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _lineCount.toDouble(),
                              min: 1,
                              max: 20,
                              divisions: 19,
                              activeColor: AppColors.primary,
                              label: _lineCount.toString(),
                              onChanged: (double value) {
                                setState(() => _lineCount = value.toInt());
                              },
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$_lineCount',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Visual Preview Section
                Container(
                  height: 140,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF202C33) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_off_rounded, color: Colors.grey.shade400, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.get('bm_preview_text', lang),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                GradientButton(
                  text: AppStrings.get('bm_send_button', lang),
                  onPressed: _sendBlankMessage,
                  icon: Icons.send_rounded,
                ),
                
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
