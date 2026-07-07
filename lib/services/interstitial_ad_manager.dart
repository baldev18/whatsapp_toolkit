import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';
import '../state/app_notifiers.dart';

// ============================================================
// INTERSTITIAL AD MANAGER - Aakhi app mathi interstitial (full-screen)
// ads ek j jagya e thi load ane show karva mate
// ============================================================
// Concept: Interstitial ad ek "full-screen" ad chhe je user ek
// kaam puru kare (jem ke file delete kare, status save kare,
// message share kare) pachi vaccha ma dekhay chhe.
// - Free user ne j dekhay chhe, premium user ne KADI nahi.
// - Ek ad "show" thai jay pachi e automatically dispose thai
//   jay chhe, etle apde tarat j biji navi ad load kari rakhie
//   chhiye jethi next vaar mate tayar rahe.
// ============================================================
class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;

  // App shuru thata j (main() mathi) ek ad "ready" rakhi mukvi
  static void loadAd() {
    // Jo already ek ad load thai chuki hoy ke load thai rahi
    // hoy, to firi thi load na karo
    if (_isLoading || _interstitialAd != null) return;
    _isLoading = true;

    InterstitialAd.load(
      // AdConfig.interstitialAdUnitId mathi ID levi - real launch
      // pehla AdConfig class ma real ID nakhvi
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                // Ad band thai jay (user "X" dabave) pachi navi
                // ad tarat j load karvanu shuru karo
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _interstitialAd = null;
                  loadAd();
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  _interstitialAd = null;
                  loadAd();
                },
              );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  // Aa function j screens mathi call thay chhe jyare koi kaam
  // (delete, save, share) puru thay
  static void showAdIfNotPremium() {
    // Premium user ne kadi ad na dekhadvi
    if (isPremiumNotifier.value) return;

    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      // Ad tayar nathi (hji load thai rahi hoy) - have thi
      // load karvanu shuru karo jethi next vaar mate male
      loadAd();
    }
  }
}
