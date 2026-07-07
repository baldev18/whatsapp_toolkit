import 'package:flutter/material.dart';
import 'state/app_notifiers.dart';
import 'screens/home_screen.dart';

// ============================================================
// MyApp = aakhi app no root widget (sauthi upar nu container)
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder = themeNotifier ni value badlay
    // tyare aa aakhi builder firi chale chhe, ane MaterialApp
    // navi themeMode sathe redraw thay chhe
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          // App nu title (task switcher ma dekhay)
          title: 'WhatsApp Toolkit',
          // Debug banner (upper-right corner nu red "DEBUG" label) hide karva
          debugShowCheckedModeBanner: false,
          // Light mode nu theme
          theme: ThemeData(
            primarySwatch: Colors.green,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          // Dark mode nu theme
          darkTheme: ThemeData(
            primarySwatch: Colors.green,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          // Have kayu theme vaparvu (light/dark/system) - currentMode
          // pramane automatically switch thay chhe
          themeMode: currentMode,
          // App khulta j aa screen batavse - have menu/home screen
          home: const HomeScreen(),
        );
      },
    );
  }
}
