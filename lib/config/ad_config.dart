// ============================================================
// ADMOB CONFIGURATION - Badhi AdMob IDs ek j jagya e rakhi chhe
// ============================================================
// IMPORTANT: Abhi aa badhi Google ni "TEST" ID chhe - development/
// testing mate barabar chhe, pan REAL app launch karta pehla
// tamare 3 vastu karvi padse:
//
// 1) https://admob.google.com par account banavo, tamari app
//    add karo - tyathi ek "App ID" malshe (jem ke
//    ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY)
//
// 2) AdMob ma "Ad units" banavo - ek Banner mate, ek Interstitial
//    mate. Dareke ek ID malshe (jem ke
//    ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ)
//
// 3) Niche na 3 constants ne tamari REAL IDs sathe replace karo,
//    ANE android/app/src/main/AndroidManifest.xml ma pan
//    <application> tag ni andar aa navu meta-data ADD/UPDATE karo:
//
//    <meta-data
//        android:name="com.google.android.gms.ads.APPLICATION_ID"
//        android:value="TAMARI_REAL_APP_ID_AHIYA_NAKHO"/>
//
// Jyare sudhi real IDs na nakho, tyare sudhi ads dekhashe khari,
// pan e "TEST" ads hase (Google no test banner/interstitial) -
// real paisa nahi male e ads na.
// ============================================================
class AdConfig {
  // TODO: Real AdMob App ID sathe replace karo (Manifest ma pan nakhvu)
  static const String appId = 'ca-app-pub-3940256099942544~3347511713'; // TEST

  // TODO: Real Banner Ad Unit ID sathe replace karo
  static const String bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // TEST

  // TODO: Real Interstitial Ad Unit ID sathe replace karo
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // TEST
}
