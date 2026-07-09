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
    'home_direct_chat': {
      'en': 'Direct Chat',
      'hi': 'डायरेक्ट चैट',
      'gu': 'ડાયરેક્ટ ચેટ',
    },
    'home_direct_chat_sub': {
      'en': 'Open WhatsApp chat without saving number',
      'hi': 'नंबर सेव किए बिना व्हाट्सएप चैट खोलें',
      'gu': 'Number save karya vagar WhatsApp chat kholo',
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
    'feedback_appbar_title': {
      'en': 'Send Feedback',
      'hi': 'फीडबैक भेजें',
      'gu': 'Feedback Moklo',
    },
    'feedback_label': {
      'en': 'Write your suggestion or problem:',
      'hi': 'अपना सुझाव या समस्या लिखें:',
      'gu': 'Tamaru suggestion ya problem lakho:',
    },
    'feedback_hint': {
      'en': 'Example: Add a Status Saver feature...',
      'hi': 'उदाहरण: स्टेटस सेवर फीचर जोड़ें...',
      'gu': 'Dakhla tarike: Status Saver feature add karo...',
    },
    'feedback_button': {
      'en': 'Submit',
      'hi': 'सबमिट करें',
      'gu': 'Submit Karo',
    },
    'feedback_empty_warning': {
      'en': 'Please write some feedback',
      'hi': 'कृपया कुछ फीडबैक लिखें',
      'gu': 'Krupa karine kai feedback lakho',
    },
    'feedback_success': {
      'en': 'Feedback sent! Thank you 🙏',
      'hi': 'फीडबैक भेज दिया गया! धन्यवाद 🙏',
      'gu': 'Feedback moklai gayu! Aabhar 🙏',
    },
    'feedback_error_prefix': {
      'en': 'Error occurred: ',
      'hi': 'त्रुटि हुई: ',
      'gu': 'Error aavi: ',
    },
    'tr_appbar_title': {
      'en': 'Text Repeater',
      'hi': 'टेक्स्ट रिपीटर',
      'gu': 'Text Repeater',
    },
    'tr_message_label': {
      'en': 'Enter message:',
      'hi': 'मैसेज लिखें:',
      'gu': 'Message nakho:',
    },
    'tr_message_hint': {
      'en': 'Example: Happy Birthday!',
      'hi': 'उदाहरण: जन्मदिन मुबारक हो!',
      'gu': 'Dakhla tarike: Happy Birthday!',
    },
    'tr_count_label': {
      'en': 'How many times to repeat:',
      'hi': 'कितनी बार दोहराना है:',
      'gu': 'Ketli vaar repeat karvu:',
    },
    'tr_count_hint': {
      'en': 'Example: 10',
      'hi': 'उदाहरण: 10',
      'gu': 'Dakhla tarike: 10',
    },
    'tr_generate_button': {
      'en': 'Generate',
      'hi': 'जनरेट करें',
      'gu': 'Generate',
    },
    'tr_share_button': {
      'en': 'Share to WhatsApp',
      'hi': 'व्हाट्सएप पर शेयर करें',
      'gu': 'Share to WhatsApp',
    },
    'tr_error_empty': {
      'en': 'Please enter a message and a valid number',
      'hi': 'कृपया एक मैसेज और सही नंबर लिखें',
      'gu': 'Krupa karine message ane sachu number nakho',
    },
    'tr_free_limit_snackbar': {
      'en': 'Free limit is 500. Get 5000 with Premium!',
      'hi': 'फ्री लिमिट 500 है। प्रीमियम से 5000 तक!',
      'gu': 'Free limit 500 chhe. Premium thi 5000 sudhi!',
    },
    'tr_error_no_result': {
      'en': 'Please tap Generate first, then Share',
      'hi': 'पहले जनरेट दबाएं, फिर शेयर करें',
      'gu': 'Pehla Generate button dabao, pachi Share karo',
    },
    'tr_error_whatsapp_missing': {
      'en': 'WhatsApp is not installed or could not open',
      'hi': 'व्हाट्सएप इंस्टॉल नहीं है या खुल नहीं सका',
      'gu': 'WhatsApp install nathi ke khulai nathi shakto',
    },
    'bm_appbar_title': {
      'en': 'Blank Message',
      'hi': 'खाली मैसेज',
      'gu': 'Blank Message',
    },
    'bm_explanation': {
      'en': 'This feature sends an "invisible" message so your WhatsApp '
          'chat looks like a blank/empty message was sent.',
      'hi': 'यह फीचर एक "अदृश्य" मैसेज भेजता है जिससे आपकी व्हाट्सएप चैट में '
          'खाली मैसेज भेजा हुआ लगेगा।',
      'gu': 'Aa feature ek "invisible" message moklse jethi WhatsApp chat '
          'ma khali/blank message aavyu hoy tevu lagshe.',
    },
    'bm_line_count_label': {
      'en': 'How many blank lines to send:',
      'hi': 'कितनी खाली लाइनें भेजनी हैं:',
      'gu': 'Ketla khali line moklva chhe:',
    },
    'bm_preview_label': {
      'en': 'Preview:',
      'hi': 'पूर्वावलोकन:',
      'gu': 'Preview:',
    },
    'bm_preview_text': {
      'en': "(Nothing visible - that's the special part!)",
      'hi': '(कुछ दिखेगा नहीं - यही तो खास बात है!)',
      'gu': '(najare kai j nahi dekhay - e j to khaas vaat chhe!)',
    },
    'bm_send_button': {
      'en': 'Send Blank Message',
      'hi': 'खाली मैसेज भेजें',
      'gu': 'Send Blank Message',
    },
    'bm_whatsapp_error': {
      'en': 'Could not open WhatsApp',
      'hi': 'व्हाट्सएप नहीं खुल सका',
      'gu': 'WhatsApp khuli na shakyu',
    },
    'qg_title': {
      'en': 'QR Generator',
      'hi': 'क्यूआर जनरेटर',
      'gu': 'QR જનરેટર',
    },
    'qg_country_code': {
      'en': 'Country Code:',
      'hi': 'कंट्री कोड:',
      'gu': 'Country Code:',
    },
    'qg_country_code_hint': {
      'en': 'Example: 91',
      'hi': 'उदाहरण: 91',
      'gu': 'Dakhla tarike: 91',
    },
    'qg_phone_number': {
      'en': 'Phone Number (without country code):',
      'hi': 'फोन नंबर (कंट्री कोड के बिना):',
      'gu': 'Phone Number (country code vagar):',
    },
    'qg_phone_hint': {
      'en': 'Example: 9876543210',
      'hi': 'उदाहरण: 9876543210',
      'gu': 'Dakhla tarike: 9876543210',
    },
    'qg_generate_button': {
      'en': 'Generate QR',
      'hi': 'क्यूआर जनरेट करें',
      'gu': 'Generate QR',
    },
    'qg_error_empty': {
      'en': 'Please enter country code and number',
      'hi': 'कृपया कंट्री कोड और नंबर दर्ज करें',
      'gu': 'Krupa karine country code ane number nakho',
    },
    'qs_title': {
      'en': 'QR Scanner',
      'hi': 'क्यूआर स्कैनर',
      'gu': 'QR સ્કેનર',
    },
    'qs_error_link': {
      'en': 'Could not open this link',
      'hi': 'यह लिंक नहीं खुल सका',
      'gu': 'Aa link khuli na shaki',
    },
    'qs_scan_hint': {
      'en': 'Place QR code inside the green box...',
      'hi': 'क्यूआर कोड को हरे बॉक्स के अंदर रखें...',
      'gu': 'QR કોડ ને ગ્રીન બોક્સ ની અંદર રાખો...',
    },
    'qs_scanned_prefix': {
      'en': 'Scanned: ',
      'hi': 'स्कैन किया गया: ',
      'gu': 'Scanned: ',
    },
    'qs_open_button': {
      'en': 'Open',
      'hi': 'खोलें',
      'gu': 'Kholo',
    },
    'qs_rescan_button': {
      'en': 'Scan Again',
      'hi': 'फिर से स्कैन करें',
      'gu': 'Firi Scan Karo',
    },
    'wc_title': {
      'en': 'WhatsApp Cleaner',
      'hi': 'व्हाट्सएप क्लीनर',
      'gu': 'WhatsApp ક્લીનર',
    },
    'wc_permission_msg': {
      'en': 'All Files Access permission is required to scan WhatsApp files',
      'hi': 'व्हाट्सएप फाइलों को स्कैन करने के लिए "ऑल फाइल्स एक्सेस" अनुमति आवश्यक है',
      'gu': 'WhatsApp files scan karva mate "All Files Access" permission jaruri chhe',
    },
    'wc_permission_button': {
      'en': 'Give Permission',
      'hi': 'अनुमति दें',
      'gu': 'Permission Aapo',
    },
    'wc_total_size_label': {
      'en': 'Total WhatsApp Media Size',
      'hi': 'कुल व्हाट्सएप मीडिया आकार',
      'gu': 'Total WhatsApp Media Size',
    },
    'wc_files_count': {
      'en': 'files',
      'hi': 'फाइलें',
      'gu': 'files',
    },
    'wc_cat_images': {
      'en': 'Images',
      'hi': 'छवियां',
      'gu': 'Images',
    },
    'wc_cat_videos': {
      'en': 'वीडियो',
      'hi': 'वीडियो',
      'gu': 'Videos',
    },
    'wc_cat_docs': {
      'en': 'Documents',
      'hi': 'दस्तावेज़',
      'gu': 'Documents',
    },
    'wc_cat_audio': {
      'en': 'Audio',
      'hi': 'ऑडियो',
      'gu': 'Audio',
    },
    'wc_cat_voice': {
      'en': 'Voice Notes',
      'hi': 'वॉयस नोट्स',
      'gu': 'Voice Notes',
    },
    'wc_web_error': {
      'en': 'WhatsApp Cleaner is not supported on Web',
      'hi': 'वेब पर व्हाट्सएप क्लीनर समर्थित नहीं है',
      'gu': 'WhatsApp Cleaner is not supported on Web',
    },
    'cf_delete_title': {
      'en': 'Delete?',
      'hi': 'हटाएं?',
      'gu': 'Delete Karvu?',
    },
    'cf_delete_msg': {
      'en': ' files will be deleted. This cannot be undone.',
      'hi': ' फाइलें हटा दी जाएंगी। इसे पूर्ववत नहीं किया जा सकता।',
      'gu': ' files delete thai jashe. Aa pacha nahi aavi shake.',
    },
    'cf_cancel': {
      'en': 'Cancel',
      'hi': 'रद्द करें',
      'gu': 'Cancel',
    },
    'cf_delete_button': {
      'en': 'Delete',
      'hi': 'हटाएं',
      'gu': 'Delete',
    },
    'cf_empty': {
      'en': 'No files in this category',
      'hi': 'इस श्रेणी में कोई फाइल नहीं है',
      'gu': 'Aa category ma koi file nathi',
    },
    'cf_web_error': {
      'en': 'File management is not supported on Web',
      'hi': 'वेब पर फाइल प्रबंधन समर्थित नहीं है',
      'gu': 'File management is not supported on Web',
    },
    'br_title': {
      'en': 'Backup Reminder',
      'hi': 'बैकअप रिमाइंडर',
      'gu': 'બેકઅપ રિમાઇન્ડર',
    },
    'br_notif_title': {
      'en': 'WhatsApp Backup Reminder',
      'hi': 'व्हाट्सएप बैकअप रिमाइंडर',
      'gu': 'WhatsApp Backup Reminder',
    },
    'br_notif_body': {
      'en': "Don't forget to backup your WhatsApp chats!",
      'hi': 'अपनी व्हाट्सएप चैट का बैकअप लेना न भूलें!',
      'gu': 'Tamara WhatsApp chats backup karvanu na bhulso!',
    },
    'br_perm_error': {
      'en': 'Notification permission is required',
      'hi': 'नोटिफिकेशन अनुमति आवश्यक है',
      'gu': 'Notification permission jaruri chhe',
    },
    'br_explanation': {
      'en': "WhatsApp doesn't automatically backup chats until you do it manually. This reminder will help you not to lose important chats.",
      'hi': 'व्हाट्सएप तब तक चैट का बैकअप नहीं लेता जब तक आप इसे मैन्युअल रूप से नहीं करते। यह रिमाइंडर आपको महत्वपूर्ण चैट न खोने में मदद करेगा।',
      'gu': 'WhatsApp automatically chats backup nathi karta jyare sudhi tame manually na karo. Aa reminder tamane yaad karavse jethi tame kadi apna important chats na guma.',
    },
    'br_switch_label': {
      'en': 'Turn on Reminder',
      'hi': 'रिमाइंडर चालू करें',
      'gu': 'Reminder Chalu Karo',
    },
    'br_status_on': {
      'en': 'On',
      'hi': 'चालू',
      'gu': 'Chalu chhe',
    },
    'br_status_off': {
      'en': 'Off',
      'hi': 'बंद',
      'gu': 'Band chhe',
    },
    'br_freq_label': {
      'en': 'How often to remind:',
      'hi': 'कितनी बार याद दिलाना है:',
      'gu': 'Ketli vaar yaad karavvu:',
    },
    'br_freq_daily': {
      'en': 'Daily',
      'hi': 'दैनिक',
      'gu': 'Daily',
    },
    'br_freq_weekly': {
      'en': 'Weekly',
      'hi': 'साप्ताहिक',
      'gu': 'Weekly',
    },
    'br_time_label': {
      'en': 'At what time:',
      'hi': 'किस समय:',
      'gu': 'Kaya samay e:',
    },
    'pr_title': {
      'en': 'Go Premium',
      'hi': 'प्रीमियम लें',
      'gu': 'પ્રીમિયમ લો',
    },
    'pr_success': {
      'en': 'Premium activated! 🎉',
      'hi': 'प्रीमियम सक्रिय! 🎉',
      'gu': 'Premium activate thai gayu! 🎉',
    },
    'pr_error_prefix': {
      'en': 'Purchase failed: ',
      'hi': 'खरीद विफल रही: ',
      'gu': 'Purchase fail thayu: ',
    },
    'pr_restore_empty': {
      'en': 'No previous purchase found',
      'hi': 'कोई पिछला खरीद नहीं मिला',
      'gu': 'Koi juni purchase nathi malyu',
    },
    'pr_store_missing': {
      'en': 'Play Store not available. Test on a real device.',
      'hi': 'प्ले स्टोर उपलब्ध नहीं है। वास्तविक डिवाइस पर परीक्षण करें।',
      'gu': 'Play Store available nathi. Real device par test karo.',
    },
    'pr_features_title': {
      'en': 'In Premium you get:',
      'hi': 'प्रीमियम में आपको मिलता है:',
      'gu': 'Premium ma malshe:',
    },
    'pr_feature_ads': {
      'en': 'No Ads - no ads will be shown',
      'hi': 'कोई विज्ञापन नहीं - कोई विज्ञापन नहीं दिखाया जाएगा',
      'gu': 'No Ads - koi ads nahi dekhay',
    },
    'pr_feature_repeat': {
      'en': 'Unlimited Repeat - from 500 up to 5000',
      'hi': 'असीमित दोहराव - 500 से 5000 तक',
      'gu': 'Unlimited Repeat - 500 ni jagya e 5000 sudhi',
    },
    'pr_load_error': {
      'en': 'Products not loaded. Play Console setup required.',
      'hi': 'उत्पाद लोड नहीं हुए। प्ले कंसोल सेटअप आवश्यक है।',
      'gu': 'Products load nathi thaya. Play Console setup jaruri chhe.',
    },
    'pr_lifetime': {
      'en': 'Lifetime',
      'hi': 'जीवनभर',
      'gu': 'Lifetime',
    },
    'pr_monthly': {
      'en': 'Monthly',
      'hi': 'मासिक',
      'gu': 'Monthly',
    },
    'pr_restoring': {
      'en': 'Restoring...',
      'hi': 'पुनर्स्थापित किया जा रहा है...',
      'gu': 'Restore thai rahyu chhe...',
    },
    'pr_restore_button': {
      'en': 'Restore Purchases',
      'hi': 'खरीद पुनर्स्थापित करें',
      'gu': 'Restore Purchases',
    },
    'ss_title': {
      'en': 'Status Saver',
      'hi': 'स्टेटस सेवर',
      'gu': 'સ્ટેટસ સેવર',
    },
    'ss_save_success': {
      'en': 'Saved to Gallery! 📁',
      'hi': 'गैलरी में सहेजा गया! 📁',
      'gu': 'Gallery ma save thai gayu! 📁',
    },
    'ss_save_error': {
      'en': 'Error saving: ',
      'hi': 'सहेजने में त्रुटि: ',
      'gu': 'Save karva ma error: ',
    },
    'ss_multi_save_success': {
      'en': ' status(es) saved to Gallery! 📁',
      'hi': ' स्टेटस गैलरी में सहेजे गए! 📁',
      'gu': ' status(es) save thai gaya! 📁',
    },
    'ss_permission_msg': {
      'en': 'All Files Access permission is required to read status files',
      'hi': 'स्टेटस फाइलें पढ़ने के लिए "ऑल फाइल्स एक्सेस" अनुमति आवश्यक है',
      'gu': 'Status files vaanchva mate "All Files Access" permission jaruri chhe',
    },
    'ss_permission_button': {
      'en': 'Give Permission',
      'hi': 'अनुमति दें',
      'gu': 'Permission Aapo',
    },
    'ss_empty': {
      'en': 'No status found. Please view a status in WhatsApp first, then refresh here.',
      'hi': 'कोई स्टेटस नहीं मिला। कृपया पहले व्हाट्सएप में कोई स्टेटस देखें, फिर यहां रिफ्रेश करें।',
      'gu': 'Koi status nathi malyo. Pehla WhatsApp kholine kai status joi lo, pachi ahi refresh karo.',
    },
    'ss_web_error': {
      'en': 'Status Saver is not supported on Web',
      'hi': 'वेब पर स्टेटस सेवर समर्थित नहीं है',
      'gu': 'Status Saver is not supported on Web',
    },
    'dc_title': {
      'en': 'Direct Chat',
      'hi': 'डायरेक्ट चैट',
      'gu': 'Direct Chat',
    },
    'dc_error_empty': {
      'en': 'Please enter country code and number',
      'hi': 'कृपया कंट्री कोड और नंबर दर्ज करें',
      'gu': 'Krupa karine country code ane number nakho',
    },
    'dc_error_whatsapp': {
      'en': 'WhatsApp is not installed or could not open',
      'hi': 'व्हाट्सएप इंस्टॉल नहीं है या खुल नहीं सका',
      'gu': 'WhatsApp install nathi ke khulai nathi shakto',
    },
    'dc_explanation': {
      'en': 'Open WhatsApp chat directly with this number without saving it in your contacts.',
      'hi': 'इस नंबर को अपने संपर्कों में सहेजे बिना सीधे व्हाट्सएप चैट खोलें।',
      'gu': 'Aa number ne tamara phone ma contact tarike save karya vagar, seedhu tena sathe WhatsApp chat kholi shakay chhe.',
    },
    'dc_country_code': {
      'en': 'Country Code:',
      'hi': 'कंट्री कोड:',
      'gu': 'Country Code:',
    },
    'dc_country_hint': {
      'en': 'Example: 91',
      'hi': 'उदाहरण: 91',
      'gu': 'Dakhla tarike: 91',
    },
    'dc_phone_label': {
      'en': 'Phone Number (without country code):',
      'hi': 'फोन नंबर (कंट्री कोड के बिना):',
      'gu': 'Phone Number (country code vagar):',
    },
    'dc_phone_hint': {
      'en': 'Example: 9876543210',
      'hi': 'उदाहरण: 9876543210',
      'gu': 'Dakhla tarike: 9876543210',
    },
    'dc_msg_label': {
      'en': 'Message (optional):',
      'hi': 'मैसेज (वैकल्पिक):',
      'gu': 'Message (optional):',
    },
    'dc_msg_hint': {
      'en': 'Example: Hello! How are you?',
      'hi': 'उदाहरण: नमस्ते! आप कैसे हैं?',
      'gu': 'Dakhla tarike: Hello! Kem cho?',
    },
    'dc_opening_msg': {
      'en': 'Opening...',
      'hi': 'खुल रहा है...',
      'gu': 'Khulai rahyu chhe...',
    },
    'dc_open_button': {
      'en': 'Open Chat',
      'hi': 'चैट खोलें',
      'gu': 'Chat Kholo',
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