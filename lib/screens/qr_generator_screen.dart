import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../state/app_strings.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final TextEditingController _countryCodeController = TextEditingController(text: '91');
  final TextEditingController _phoneController = TextEditingController();
  String _qrData = '';

  void _generateQr() {
    final lang = localeNotifier.value;
    String countryCode = _countryCodeController.text.trim();
    String phone = _phoneController.text.trim();
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    countryCode = countryCode.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.isEmpty || countryCode.isEmpty) {
      setState(() {
        _qrData = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.get('qg_error_empty', lang)),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() {
      _qrData = 'https://wa.me/$countryCode$phone';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('qg_title', lang)),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Form
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
                              label: AppStrings.get('qg_country_code', lang),
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
                              label: AppStrings.get('qg_phone_number', lang),
                              hint: '9876543210',
                              icon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      GradientButton(
                        text: AppStrings.get('qg_generate_button', lang),
                        onPressed: _generateQr,
                        icon: Icons.qr_code_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // QR Result Section
                if (_qrData.isNotEmpty)
                  _buildQrResult(lang, isDark)
                else
                  _buildEmptyState(isDark),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQrResult(String lang, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202C33) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 200,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF000000),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF000000),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _qrData,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.qr_code_rounded, size: 100, color: Colors.grey.withOpacity(0.2)),
        const SizedBox(height: 16),
        Text(
          'Enter details above to generate QR',
          style: TextStyle(
            color: Colors.grey.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
