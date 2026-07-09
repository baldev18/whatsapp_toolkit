import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> submitFeedback(String message) async {
    await _db.collection('feedback').add({
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> incrementFeatureUsage(String featureName) async {
    final docRef = _db.collection('feature_usage').doc(featureName);
    await docRef.set({
      'count': FieldValue.increment(1),
      'lastUsed': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
