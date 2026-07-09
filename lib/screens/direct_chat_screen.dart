import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/app_strings.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';

class DirectChatScreen extends StatefulWidget {
  const DirectChatScreen({super.key});

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final TextEditingController _countryCodeController = TextEditingController(text: '91');
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isOpening = false;

  Future<void> _openDirectChat() async {
    final lang = localeNotifier.value;
    String countryCode = _countryCodeController.text.trim();
    String phone = _phoneController.text.trim();
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    countryCode = countryCode.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.isEmpty || countryCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.get('dc_error_empty', lang)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    setState(() => _isOpening = true);
    final String message = _messageController.text.trim();
    final String fullNumber = '$countryCode$phone';
    final Uri whatsappUrl = message.isEmpty
        ? Uri.parse('https://wa.me/$fullNumber')
        : Uri.parse('https://wa.me/$fullNumber?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.get('dc_error_whatsapp', lang)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }

    if (mounted) {
      setState(() => _isOpening = false);
    }
  }

  @override
  void dispose() {
    _countryCodeController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('dc_title', lang)),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Clean Info Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppStrings.get('dc_explanation', lang),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // Main Form
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: CustomTextField(
                              controller: _countryCodeController,
                              label: AppStrings.get('dc_country_code', lang),
                              hint: '91',
                              icon: Icons.public_rounded,
                              keyboardType: TextInputType.number,
                              prefixText: '+',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _phoneController,
                              label: AppStrings.get('dc_phone_label', lang),
                              hint: '9876543210',
                              icon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _messageController,
                        label: AppStrings.get('dc_msg_label', lang),
                        hint: AppStrings.get('dc_msg_hint', lang),
                        icon: Icons.chat_bubble_outline_rounded,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Action Button
                GradientButton(
                  text: AppStrings.get('dc_open_button', lang),
                  onPressed: _openDirectChat,
                  isLoading: _isOpening,
                  icon: Icons.send_rounded,
                ),
                
                const SizedBox(height: 20),
                
                // Centered Help Text
                Center(
                  child: Text(
                    'Fast. Secure. Simple.',
                    style: TextStyle(
                      color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
