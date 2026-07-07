import 'package:flutter/material.dart';

// ============================================================
// PREMIUM NOTIFIER - User premium chhe ke nahi e "yaad" rakhva mate
// ============================================================
// themeNotifier ni jem j chhe - jyare aa value badlay, badhi
// jagya e (ads batavvi/na batavvi, repeat limit) automatically
// update thai jay chhe
final ValueNotifier<bool> isPremiumNotifier = ValueNotifier(false);

// ============================================================
// THEME NOTIFIER - Dark/Light mode ne "yaad" rakhva mate
// ============================================================
// ValueNotifier = ek variable jenu value badlai tyare
// je koi widget "sambhad" rahyu hoy (ValueListenableBuilder
// vade) e automatically redraw thay jay chhe.
// Aa "global" chhe etle app ni koi pan screen mathi
// theme badli shakay chhe.
// ============================================================
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
