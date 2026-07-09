# Task Management

- [/] Re-integrate Firebase for Feedback
    - [ ] Add `firebase_core` and `cloud_firestore` to `pubspec.yaml`
    - [ ] Re-create `lib/firebase_options.dart`
    - [ ] Re-create `lib/services/firestore_service.dart`
    - [ ] Re-create `lib/screens/feedback_screen.dart`
    - [ ] Update `lib/main.dart` to initialize Firebase
    - [ ] Update `lib/screens/home_screen.dart` to include Feedback card
    - [ ] Re-configure Android `build.gradle.kts` and `settings.gradle.kts`
- [ ] Verification
    - [ ] Run `flutter pub get`
    - [ ] Run `flutter analyze`
    - [ ] Run `flutter build apk --debug`
