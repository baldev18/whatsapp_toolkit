import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDAT3NDiI_NqdtX3qPmWAyNaaruwq8ZMuI',
    appId: '1:1037763161215:web:50f5e1b9ba2890a76de34a',
    messagingSenderId: '1037763161215',
    projectId: 'whatsapp-toolkit-39bdc',
    authDomain: 'whatsapp-toolkit-39bdc.firebaseapp.com',
    storageBucket: 'whatsapp-toolkit-39bdc.firebasestorage.app',
    measurementId: 'G-MFSN4XTN5Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAeZO4pdtVvo_rVqUd2JeTprdUAjKsp8Z0',
    appId: '1:1037763161215:android:014bb15e1814981c6de34a',
    messagingSenderId: '1037763161215',
    projectId: 'whatsapp-toolkit-39bdc',
    storageBucket: 'whatsapp-toolkit-39bdc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWOsrnlcA2W82l2RmJIHFZfQwgKJ0tXkE',
    appId: '1:1037763161215:ios:2dd1ea9cb5f7d0966de34a',
    messagingSenderId: '1037763161215',
    projectId: 'whatsapp-toolkit-39bdc',
    storageBucket: 'whatsapp-toolkit-39bdc.firebasestorage.app',
    iosBundleId: 'com.example.whatsappToolkit',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAWOsrnlcA2W82l2RmJIHFZfQwgKJ0tXkE',
    appId: '1:1037763161215:ios:2dd1ea9cb5f7d0966de34a',
    messagingSenderId: '1037763161215',
    projectId: 'whatsapp-toolkit-39bdc',
    storageBucket: 'whatsapp-toolkit-39bdc.firebasestorage.app',
    iosBundleId: 'com.example.whatsappToolkit',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDAT3NDiI_NqdtX3qPmWAyNaaruwq8ZMuI',
    appId: '1:1037763161215:web:74ee4ed4aa0a34476de34a',
    messagingSenderId: '1037763161215',
    projectId: 'whatsapp-toolkit-39bdc',
    authDomain: 'whatsapp-toolkit-39bdc.firebaseapp.com',
    storageBucket: 'whatsapp-toolkit-39bdc.firebasestorage.app',
    measurementId: 'G-HTWKLGCN8B',
  );
}
