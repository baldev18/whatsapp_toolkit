// ============================================================
// FEEDBACK SCREEN - User feedback Firestore ma save karva mate
// ============================================================
// Aa file "feedback_screen.dart" naame save karo, jya tamari
// baaki ni screens chhe e j folder ma (jem ke lib/screens/)
// ============================================================

import 'package:flutter/material.dart';

import 'firestore_service.dart';
// Upar no import path tamara folder structure pramane badalvo
// pade - jo firestore_service.dart alag jagya e hoy to path
// update karjo (dakhla: 'services/firestore_service.dart')

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    final message = _feedbackController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Krupa karine kai feedback lakho')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Aa line Firestore ma actual data mokle chhe
      await FirestoreService.submitFeedback(message);

      _feedbackController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback moklai gayu! Aabhar 🙏')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error aavi: $e')),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Moklo'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tamaru suggestion ya problem lakho:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Dakhla tarike: Status Saver feature add karo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text('Submit Karo'),
            ),
          ],
        ),
      ),
    );
  }
}