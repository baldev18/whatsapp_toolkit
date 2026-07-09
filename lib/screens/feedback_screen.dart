import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../state/app_strings.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    final lang = localeNotifier.value;
    final message = _feedbackController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('feedback_empty_warning', lang)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirestoreService.submitFeedback(message);
      _feedbackController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('feedback_success', lang)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('feedback_error_prefix', lang) + e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('feedback_appbar_title', lang)),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Inviting Illustration
                Center(
                  child: Container(
                    height: 160,
                    width: 160,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  AppStrings.get('feedback_label', lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                
                const SizedBox(height: 12),

                Text(
                  'We would love to hear from you. Your feedback helps us improve.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 40),

                // Feedback Form
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
                  child: CustomTextField(
                    controller: _feedbackController,
                    label: 'Message',
                    hint: AppStrings.get('feedback_hint', lang),
                    icon: Icons.rate_review_rounded,
                    maxLines: 5,
                  ),
                ),

                const SizedBox(height: 40),

                GradientButton(
                  text: AppStrings.get('feedback_button', lang),
                  onPressed: _submitFeedback,
                  isLoading: _isSubmitting,
                  icon: Icons.rocket_launch_rounded,
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
