// ============================================================
// APP STRINGS - Multi-language text ahi store thay chhe
// ============================================================
// Aa file "strings.dart" naame save karo:
// lib/state/app_strings.dart (ya jya tamaru state/ folder chhe)
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// LANGUAGE NOTIFIER - themeNotifier ni j rite kaam kare chhe
// Global variable je aakhi app mathi vaparay chhe
// ============================================================
// Values: 'en' = English, 'hi' = Hindi, 'gu' = Gujarati
final ValueNotifier<String> localeNotifier = ValueNotifier('en');

// App start thata j saved language load karva mate
// (aa function main() mathi call karo)
Future<void> loadSavedLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  localeNotifier.value = prefs.getString('appLanguage') ?? 'en';
}

// Language badalva ane save karva mate (dropdown mathi call thay chhe)
Future<void> changeLanguage(String languageCode) async {
  localeNotifier.value = languageCode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('appLanguage', languageCode);
}

// ============================================================
// AppStrings class - dareke text no translation ahi store chhe
// ============================================================
// Vaparva mate: AppStrings.get('home_title', localeNotifier.value)
// ============================================================
class AppStrings {
  // Dareke "key" mate 3 languages na text
  static final Map<String, Map<String, String>> _translations = {
    'app_title': {
      'en': 'ChatToolz',
      'hi': 'चैटटूल्ज़',
      'gu': 'ChatToolz',
    },
    'home_text_repeater': {
      'en': 'Text Repeater',
      'hi': 'टेक्स्ट रिपीटर',
      'gu': 'ટેક્સ્ટ રિપીટર',
    },
    'home_text_repeater_sub': {
      'en': 'Repeat a message many times',
      'hi': 'एक मैसेज को कई बार दोहराएं',
      'gu': 'એક મેસેજ ને ઘણી વાર રિપીટ કરો',
    },
    'home_blank_message': {
      'en': 'Blank Message',
      'hi': 'खाली मैसेज',
      'gu': 'ખાલી મેસેજ',
    },
    'home_blank_message_sub': {
      'en': 'Send an invisible message',
      'hi': 'एक अदृश्य मैसेज भेजें',
      'gu': 'ખાલી (invisible) મેસેજ મોકલો',
    },
    'home_qr_generator': {
      'en': 'QR Generator',
      'hi': 'क्यूआर जनरेटर',
      'gu': 'QR જનરેટર',
    },
    'home_qr_generator_sub': {
      'en': 'Create a WhatsApp chat QR from a number',
      'hi': 'नंबर से व्हाट्सएप चैट क्यूआर बनाएं',
      'gu': 'નંબર માંથી WhatsApp ચેટ QR બનાવો',
    },
    'home_qr_scanner': {
      'en': 'QR Scanner',
      'hi': 'क्यूआर स्कैनर',
      'gu': 'QR સ્કેનર',
    },
    'home_qr_scanner_sub': {
      'en': 'Scan a QR code using camera',
      'hi': 'कैमरे से क्यूआर कोड स्कैन करें',
      'gu': 'કેમેરા થી QR કોડ સ્કેન કરો',
    },
    'home_cleaner': {
      'en': 'WhatsApp Cleaner',
      'hi': 'व्हाट्सएप क्लीनर',
      'gu': 'WhatsApp ક્લીનર',
    },
    'home_cleaner_sub': {
      'en': 'Delete junk photos/videos to save space',
      'hi': 'जगह बचाने के लिए जंक फोटो/वीडियो हटाएं',
      'gu': 'જંક ફોટોસ/વિડિઓસ ડિલીટ કરીને સ્પેસ બચાવો',
    },
    'home_backup_reminder': {
      'en': 'Backup Reminder',
      'hi': 'बैकअप रिमाइंडर',
      'gu': 'બેકઅપ રિમાઇન્ડર',
    },
    'home_backup_reminder_sub': {
      'en': 'Get reminded to backup WhatsApp',
      'hi': 'व्हाट्सएप बैकअप के लिए याद दिलाएं',
      'gu': 'WhatsApp બેકઅપ કરવા માટે યાદ કરાવો',
    },
    'home_status_saver': {
      'en': 'Status Saver',
      'hi': 'स्टेटस सेवर',
      'gu': 'સ્ટેટસ સેવર',
    },
    'home_status_saver_sub': {
      'en': 'Download WhatsApp statuses',
      'hi': 'व्हाट्सएप स्टेटस डाउनलोड करें',
      'gu': 'WhatsApp સ્ટેટસ ડાઉનલોડ કરો',
    },
    'home_feedback': {
      'en': 'Feedback',
      'hi': 'फीडबैक',
      'gu': 'ફીડબેક',
    },
    'home_feedback_sub': {
      'en': 'Send a suggestion or problem',
      'hi': 'सुझाव या समस्या भेजें',
      'gu': 'સૂચન ya પ્રોબ્લેમ મોકલો',
    },
    'go_premium': {
      'en': 'Go Premium',
      'hi': 'प्रीमियम लें',
      'gu': 'પ્રીમિયમ લો',
    },
    'go_premium_sub': {
      'en': 'No Ads + Unlimited Repeat',
      'hi': 'बिना विज्ञापन + अनलिमिटेड रिपीट',
      'gu': 'No Ads + Unlimited Repeat',
    },
  };

  // Aa function text pacho aape chhe, current language pramane
  // Jo koi key na male to safety mate English pacho aape chhe
  static String get(String key, String languageCode) {
    return _translations[key]?[languageCode] ??
        _translations[key]?['en'] ??
        key;
  }
}