# Re-integrating Firebase for Feedback Feature

This plan restores Firebase support specifically to enable a database-backed Feedback screen.

## User Review Required

- I will use the **Firebase project configuration** from the previous turns (`whatsapp-toolkit-39bdc`). Please ensure you still have the `google-services.json` file if you plan to build for Android, otherwise I will rely on `firebase_options.dart`.

## Proposed Changes

### 1. Dependencies and Config

#### [pubspec.yaml](file:///C:/Users/BALDEVSINH/StudioProjects/ whatsapp_toolkit/pubspec.yaml)
- Add `firebase_core: ^3.8.0` and `cloud_firestore: ^5.5.0`.

#### [NEW] [firebase_options.dart](file:///C:/Users/BALDEVSINH/StudioProjects/ whatsapp_toolkit/lib/firebase_options.dart)
- Restore with the previous project credentials.

#### [NEW] [firestore_service.dart](file:///C:/Users/BALDEVSINH/StudioProjects/ whatsapp_toolkit/lib/services/firestore_service.dart)
- Restore service for sending messages to Firestore.

### 2. UI and Logic

#### [main.dart](file:///C:/Users/BALDEVSINH/StudioProjects/ whatsapp_toolkit/lib/main.dart)
- Re-add `Firebase.initializeApp()`.

#### [NEW] [feedback_screen.dart](file:///C:/Users/BALDEVSINH/StudioProjects/ whatsapp_toolkit/lib/screens/feedback_screen.dart)
- Restore the Feedback UI.

#### [home_screen.dart](file:///C:/Users/BALDEVSINH/StudioProjects/ whatsapp_toolkit/lib/screens/home_screen.dart)
- Re-add the "Feedback" option to the list of tools.

### 3. Android Configuration

#### [android/app/build.gradle.kts](file:///C:/Users/BALDEVSINH/StudioProjects/ whatsapp_toolkit/android/app/build.gradle.kts)
- Re-add `id("com.google.gms.google-services")`.

#### [android/settings.gradle.kts](file:///C:/Users/BALDEVSINH/StudioProjects/ whatsapp_toolkit/android/settings.gradle.kts)
- Re-add the Google Services plugin definition.

---

## Verification Plan

### Automated Tests
- `flutter pub get`
- `flutter analyze`
- `flutter build apk --debug`

### Manual Verification
- Verify the Feedback screen appears on Home and successfully submits data (handled by user in app).
