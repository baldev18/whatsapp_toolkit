import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_notifiers.dart';
import '../state/app_strings.dart';
import '../config/ad_config.dart';
import '../config/app_theme.dart';
import '../widgets/tool_card.dart';
import 'direct_chat_screen.dart';
import 'status_saver_screen.dart';
import 'text_repeater_screen.dart';
import 'blank_message_screen.dart';
import 'qr_generator_screen.dart';
import 'qr_scanner_screen.dart';
import 'whatsapp_cleaner_screen.dart';
import 'backup_reminder_screen.dart';
import 'premium_screen.dart';
import 'feedback_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern Elegant SliverAppBar
              SliverAppBar(
                expandedHeight: 160.0,
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    AppStrings.get('app_title', lang),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  background: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [AppColors.darkSurface, AppColors.darkBackground]
                                  : [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      // Decorative elements
                      Positioned(
                        top: -40,
                        right: -40,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        right: 20,
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white.withOpacity(0.15),
                          size: 64,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  _buildActionIcon(
                    icon: Icons.translate_rounded,
                    onTap: () => _showLanguageDialog(context, lang),
                  ),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, currentMode, child) {
                      final isDarkMode = currentMode == ThemeMode.dark;
                      return _buildActionIcon(
                        icon: isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                        onTap: () async {
                          final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
                          themeNotifier.value = newMode;
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isDarkMode', newMode == ThemeMode.dark);
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deluxe Premium Banner
                      ValueListenableBuilder<bool>(
                        valueListenable: isPremiumNotifier,
                        builder: (context, isPremium, child) {
                          if (isPremium) return const SizedBox.shrink();
                          return _buildPremiumBanner(lang);
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quick Tools',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Icon(
                            Icons.grid_view_rounded,
                            size: 20,
                            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tools List
                      ToolCard(
                        title: AppStrings.get('home_direct_chat', lang),
                        subtitle: AppStrings.get('home_direct_chat_sub', lang),
                        icon: Icons.chat_bubble_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DirectChatScreen())),
                      ),
                      
                      if (!kIsWeb)
                        ToolCard(
                          title: AppStrings.get('home_status_saver', lang),
                          subtitle: AppStrings.get('home_status_saver_sub', lang),
                          icon: Icons.cloud_download_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatusSaverScreen())),
                        ),

                      ToolCard(
                        title: AppStrings.get('home_text_repeater', lang),
                        subtitle: AppStrings.get('home_text_repeater_sub', lang),
                        icon: Icons.replay_circle_filled_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TextRepeaterScreen())),
                      ),

                      ToolCard(
                        title: AppStrings.get('home_blank_message', lang),
                        subtitle: AppStrings.get('home_blank_message_sub', lang),
                        icon: Icons.disabled_visible_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BlankMessageScreen())),
                      ),

                      ToolCard(
                        title: AppStrings.get('home_qr_generator', lang),
                        subtitle: AppStrings.get('home_qr_generator_sub', lang),
                        icon: Icons.qr_code_2_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QrGeneratorScreen())),
                      ),

                      ToolCard(
                        title: AppStrings.get('home_qr_scanner', lang),
                        subtitle: AppStrings.get('home_qr_scanner_sub', lang),
                        icon: Icons.qr_code_scanner_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScannerScreen())),
                      ),

                      if (!kIsWeb) ...[
                        ToolCard(
                          title: AppStrings.get('home_cleaner', lang),
                          subtitle: AppStrings.get('home_cleaner_sub', lang),
                          icon: Icons.auto_delete_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WhatsAppCleanerScreen())),
                        ),
                        ToolCard(
                          title: AppStrings.get('home_backup_reminder', lang),
                          subtitle: AppStrings.get('home_backup_reminder_sub', lang),
                          icon: Icons.notification_important_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupReminderScreen())),
                        ),
                      ],

                      ToolCard(
                        title: AppStrings.get('home_feedback', lang),
                        subtitle: AppStrings.get('home_feedback_sub', lang),
                        icon: Icons.maps_ugc_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen())),
                      ),
                      
                      const SizedBox(height: 100), // Space for ads/navigation
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomAd(),
        );
      },
    );
  }

  Widget _buildActionIcon({required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildPremiumBanner(String lang) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.premiumGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'PRO VERSION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.get('go_premium', lang),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.get('go_premium_sub', lang),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F2027),
              minimumSize: const Size(110, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomAd() {
    if (isPremiumNotifier.value || !_isBannerLoaded || _bannerAd == null || kIsWeb) {
      return null;
    }
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 8),
      height: _bannerAd!.size.height.toDouble() + 8,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  void _showLanguageDialog(BuildContext context, String currentLang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Select Language',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildLangTile('en', '🇺🇸 English', currentLang),
            _buildLangTile('hi', '🇮🇳 हिन्दी', currentLang),
            _buildLangTile('gu', '🇮🇳 ગુજરાતી', currentLang),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLangTile(String code, String name, String current) {
    final isSelected = code == current;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(
          name, 
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: isSelected 
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 26) 
          : null,
        onTap: () {
          changeLanguage(code);
          Navigator.pop(context);
        },
      ),
    );
  }
}
