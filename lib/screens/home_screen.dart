import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/app_notifiers.dart';
import '../config/ad_config.dart';
import 'FeedbackScreen.dart';
import 'direct_chat_screen.dart';
import 'status_saver_screen.dart';
import 'text_repeater_screen.dart';
import 'blank_message_screen.dart';
import 'qr_generator_screen.dart';
import 'qr_scanner_screen.dart';
import 'whatsapp_cleaner_screen.dart';
import 'backup_reminder_screen.dart';
import 'premium_screen.dart';

// ============================================================
// HomeScreen = App khultavent sauthi pehla dekhai tevo menu screen
// Aa ma badha tools ni list chhe, tap karta e feature khule chhe
// StatefulWidget banavyu chhe kem ke banner ad load karvani chhe
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Banner ad ne store karva mate variable
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  // Banner ad ne AdMob mathi load karva mate
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      // AdConfig.bannerAdUnitId mathi ID levi - real launch pehla
      // AdConfig class ma real ID nakhvi (upar comment ma samjavyu chhe)
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // setState = ad load thai gayo, screen ne redraw karo
          setState(() => _isBannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          // Jo ad load na thay to disponse (memory free) karo
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    // Screen band thay tyare ad ne pan dispose karvi jaruri chhe
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Toolkit'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // ValueListenableBuilder vaparyu chhe jethi switch nu
          // chihn (icon) current mode pramane badlay
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              final isDark = currentMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                tooltip: isDark ? 'Light mode par jaao' : 'Dark mode par jaao',
                onPressed: () async {
                  final newMode = isDark ? ThemeMode.light : ThemeMode.dark;

                  // themeNotifier.value badlta j badhi jagya e
                  // theme automatically update thai jay chhe
                  themeNotifier.value = newMode;

                  // Have aa selection ne phone ni andar save karo,
                  // jethi app band-chalu karo to pan yaad rahe
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool(
                    'isDarkMode',
                    newMode == ThemeMode.dark,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // "Go Premium" card - ValueListenableBuilder vaparyu chhe
          // jethi premium khareedta j aa card automatically gayab thay
          ValueListenableBuilder<bool>(
            valueListenable: isPremiumNotifier,
            builder: (context, isPremium, child) {
              // Jo already premium hoy to aa card j na batavo
              if (isPremium) return const SizedBox.shrink();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.amber[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber[300]!),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.workspace_premium,
                      color: Colors.amber, size: 32),
                  title: const Text('Go Premium',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text(
                      'No Ads + Unlimited Repeat - ₹49/month ya ₹99 lifetime'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // Har tool mate ek Card banavyu chhe, tap karta navi
          // screen par navigate (jaay) thay chhe
          _buildToolCard(
            context: context,
            icon: Icons.chat_bubble,
            title: 'Direct Chat',
            subtitle: 'Number save karya vagar WhatsApp chat kholo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DirectChatScreen(),
                ),
              );
            },
          ),
          if (!kIsWeb)
            _buildToolCard(
              context: context,
              icon: Icons.photo_library,
              title: 'Status Saver',
              subtitle: 'WhatsApp status na photo/video save karo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatusSaverScreen(),
                  ),
                );
              },
            ),
          _buildToolCard(
            context: context,
            icon: Icons.feedback,
            title: 'Feedback',
            subtitle: 'Suggestion ya problem moklo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),
          _buildToolCard(
            context: context,
            icon: Icons.repeat,
            title: 'Text Repeater',
            subtitle: 'Ek message ne ghani vaar repeat karo',
            onTap: () {
              // Navigator.push = navi screen par jaay
              // MaterialPageRoute = navi screen kai chhe e batave chhe
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TextRepeaterScreen(),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            icon: Icons.visibility_off,
            title: 'Blank Message',
            subtitle: 'Khali (invisible) message moklo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlankMessageScreen(),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            icon: Icons.qr_code,
            title: 'QR Generator',
            subtitle: 'Number mathi WhatsApp chat QR banavo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QrGeneratorScreen(),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            icon: Icons.qr_code_scanner,
            title: 'QR Scanner',
            subtitle: 'Camera thi QR code scan karo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QrScannerScreen(),
                ),
              );
            },
          ),
          if (!kIsWeb)
            _buildToolCard(
              context: context,
              icon: Icons.cleaning_services,
              title: 'WhatsApp Cleaner',
              subtitle: 'Junk photos/videos delete karine space bachavo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WhatsAppCleanerScreen(),
                  ),
                );
              },
            ),
          if (!kIsWeb)
            _buildToolCard(
              context: context,
              icon: Icons.notifications_active,
              title: 'Backup Reminder',
              subtitle: 'WhatsApp backup karva mate yaad karavo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackupReminderScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      // Bottom ma banner ad - fakt premium na hoy ane ad load
      // thai gayo hoy tyare j dekhay
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: isPremiumNotifier,
        builder: (context, isPremium, child) {
          if (isPremium || !_isBannerLoaded || _bannerAd == null || kIsWeb) {
            // Premium user ne ke jyare ad load nathi thayo tyare
            // kai j jagya na rokvi (height 0)
            return const SizedBox.shrink();
          }
          return SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          );
        },
      ),
    );
  }

  // Aa ek helper function chhe - repeat thato Card UI code
  // alag function ma kadhi lidhu chhe jethi upar clean dekhay
  Widget _buildToolCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.green[50],
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
