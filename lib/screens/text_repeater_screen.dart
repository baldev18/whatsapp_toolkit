import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/app_notifiers.dart';
import '../state/app_strings.dart';
import '../services/interstitial_ad_manager.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';

class TextRepeaterScreen extends StatefulWidget {
  const TextRepeaterScreen({super.key});

  @override
  State<TextRepeaterScreen> createState() => _TextRepeaterScreenState();
}

class _TextRepeaterScreenState extends State<TextRepeaterScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  String _resultText = '';

  void _generateRepeatedText() {
    final lang = localeNotifier.value;
    String message = _messageController.text;
    int count = int.tryParse(_countController.text) ?? 0;

    if (message.isEmpty || count <= 0) {
      setState(() {
        _resultText = AppStrings.get('tr_error_empty', lang);
      });
      return;
    }

    final int maxLimit = isPremiumNotifier.value ? 5000 : 500;
    if (count > maxLimit) {
      count = maxLimit;
      if (!isPremiumNotifier.value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.get('tr_free_limit_snackbar', lang)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }

    String repeated = List.filled(count, message).join('\n');
    setState(() {
      _resultText = repeated;
    });
  }

  Future<void> _shareToWhatsApp() async {
    final lang = localeNotifier.value;

    if (_resultText.isEmpty) {
      setState(() {
        _resultText = AppStrings.get('tr_error_no_result', lang);
      });
      return;
    }

    final String encodedText = Uri.encodeComponent(_resultText);
    final Uri whatsappUrl = Uri.parse('https://wa.me/?text=$encodedText');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      InterstitialAdManager.showAdIfNotPremium();
    } else {
      setState(() {
        _resultText = AppStrings.get('tr_error_whatsapp_missing', lang);
      });
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
            title: Text(AppStrings.get('tr_appbar_title', lang)),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: isDark ? [] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _messageController,
                        label: AppStrings.get('tr_message_label', lang),
                        hint: AppStrings.get('tr_message_hint', lang),
                        icon: Icons.edit_note_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _countController,
                              label: AppStrings.get('tr_count_label', lang),
                              hint: '100',
                              icon: Icons.numbers_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ValueListenableBuilder<bool>(
                            valueListenable: isPremiumNotifier,
                            builder: (context, isPremium, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: (isPremium ? AppColors.premiumGold : AppColors.primary).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isPremium ? 'Max 5000' : 'Max 500',
                                  style: TextStyle(
                                    color: isPremium ? AppColors.premiumGold : AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                GradientButton(
                  text: AppStrings.get('tr_generate_button', lang),
                  onPressed: _generateRepeatedText,
                  icon: Icons.auto_fix_high_rounded,
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _shareToWhatsApp,
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text(AppStrings.get('tr_share_button', lang)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 32),

                // Result Preview Section
                if (_resultText.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Logic could be added here for clipboard if desired
                        },
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF202C33) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
                    ),
                    child: SelectableText(
                      _resultText,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
