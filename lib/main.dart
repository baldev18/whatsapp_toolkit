// ============================================================
// TEXT REPEATER - WhatsApp Toolkit no pehlo feature
// ============================================================
// Aa file "main.dart" na naame save karo tamara Flutter project
// na "lib" folder ma (path: whatsapp_toolkit/lib/main.dart)
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app.dart';
import 'state/app_notifiers.dart';
import 'services/notification_service.dart';
import 'services/interstitial_ad_manager.dart';

// Har Flutter app ma "main()" function j sauthi pehla run thay che
// Aa app ni entry point (shuruaat) che
//
// "async" banavyu chhe kem ke SharedPreferences thi data vaanchvama
// thodo time lage chhe (file system operation chhe)
void main() async {
  // Flutter ne kahevu padu chhe ke "hu tayar chhu plugins vaparva
  // mate" - async main() vaparta aa line jaruri chhe
  WidgetsFlutterBinding.ensureInitialized();

  // Phone ni andar save thayela settings vaanchva mate
  final prefs = await SharedPreferences.getInstance();

  // 'isDarkMode' naam ni key vaanchvi - jo pehla kadi save j na
  // karyu hoy to default false (light mode) rakhvu
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

  // Saved value pramane themeNotifier ne shuruaat ma j set karvu
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Timezone data initialize karvu - notification ne saachа
  // samay par batavva mate jaruri chhe
  tz.initializeTimeZones();

  // Notification plugin ne setup karvu
  const androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await notificationsPlugin.initialize(initSettings);

  // AdMob ne initialize karvu - aa vagar ads nahi dekhay
  await MobileAds.instance.initialize();

  // App shuru thata j pehli interstitial ad load karvanu shuru
  // karo, jethi jyare pehli vaar jaruri pade tyare tarat j
  // dekhadi shakay
  InterstitialAdManager.loadAd();

  // Phone ma pehla thi premium khareedelu chhe ke nahi e check karvu
  final bool isPremium = prefs.getBool('isPremium') ?? false;
  isPremiumNotifier.value = isPremium;

  runApp(const MyApp());
}
