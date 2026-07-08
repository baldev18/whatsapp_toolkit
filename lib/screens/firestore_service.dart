// ============================================================
// FIRESTORE SERVICE - Firebase Firestore Database sathe kaam
// karva mate helper functions
// ============================================================
// Aa file "firestore_service.dart" naame save karo:
// lib/services/firestore_service.dart
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Firestore no instance - aakhi app mathi aa j vaparashu
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // Feedback submit karva mate
  // ============================================================
  // Aa function 'feedback' naam ni collection ma navu document
  // umere chhe - Firebase Console > Firestore Database ma
  // tarat j dekhashe
  static Future<void> submitFeedback(String message) async {
    await _db.collection('feedback').add({
      'message': message,
      // serverTimestamp = Firebase no server j samay lakhe chhe,
      // etle phone nu date/time khotu hoy to pan sachu time male
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Feature vapraayo tyare "count" vadhaarva mate
  // ============================================================
  // Aa function dakhla tarike "text_repeater" naam ni feature
  // ketli vaar vaparaai e track kare chhe. Dashboard/analytics
  // mate upyogi chhe.
  static Future<void> incrementFeatureUsage(String featureName) async {
    // 'feature_usage' collection ma, dareke feature nu potanu
    // ek document hoy chhe (document ID = feature nu naam)
    final docRef = _db.collection('feature_usage').doc(featureName);

    // set() with merge:true = jo document na hoy to banavo,
    // hoy to update karo (increment kare chhe count field ne)
    await docRef.set({
      'count': FieldValue.increment(1),
      'lastUsed': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}