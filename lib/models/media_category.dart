import 'package:flutter/material.dart';

// ============================================================
// WHATSAPP CLEANER - Junk files (photos/videos/docs) find & delete
// ============================================================

// Ek "category" (jem ke Images, Video) no data rakhva mate class
class MediaCategory {
  final String name; // Screen par dekhaay tevu naam
  final String folderName; // Actual folder nu naam (WhatsApp andar)
  final IconData icon;

  MediaCategory({
    required this.name,
    required this.folderName,
    required this.icon,
  });
}
