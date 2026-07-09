import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';
import '../state/app_strings.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';

class BackupReminderScreen extends StatefulWidget {
  const BackupReminderScreen({super.key});

  @override
  State<BackupReminderScreen> createState() => _BackupReminderScreenState();
}

class _BackupReminderScreenState extends State<BackupReminderScreen> {
  static const int _notificationId = 100;
  bool _isReminderOn = false;
  String _frequency = 'Daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isReminderOn = prefs.getBool('reminderOn') ?? false;
      _frequency = prefs.getString('reminderFrequency') ?? 'Daily';
      final savedHour = prefs.getInt('reminderHour') ?? 20;
      final savedMinute = prefs.getInt('reminderMinute') ?? 0;
      _selectedTime = TimeOfDay(hour: savedHour, minute: savedMinute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminderOn', _isReminderOn);
    await prefs.setString('reminderFrequency', _frequency);
    await prefs.setInt('reminderHour', _selectedTime.hour);
    await prefs.setInt('reminderMinute', _selectedTime.minute);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.lightText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      if (_isReminderOn) {
        await _scheduleNotification();
      }
      await _saveSettings();
    }
  }

  Future<void> _scheduleNotification() async {
    if (kIsWeb) return;
    final lang = localeNotifier.value;
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    const androidDetails = AndroidNotificationDetails(
      'backup_reminder_channel',
      'Backup Reminders',
      channelDescription: 'WhatsApp backup karva mate reminder',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    bool canScheduleExact = false;
    try {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      canScheduleExact = exactAlarmStatus.isGranted;
    } catch (e) {
      canScheduleExact = false;
    }

    await notificationsPlugin.zonedSchedule(
      _notificationId,
      AppStrings.get('br_notif_title', lang),
      AppStrings.get('br_notif_body', lang),
      scheduledDate,
      notificationDetails,
      androidScheduleMode: canScheduleExact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _frequency == 'Daily' ? DateTimeComponents.time : DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> _cancelNotification() async {
    if (kIsWeb) return;
    await notificationsPlugin.cancel(_notificationId);
  }

  Future<void> _onToggleChanged(bool value) async {
    final lang = localeNotifier.value;
    if (value) {
      if (!kIsWeb) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppStrings.get('br_perm_error', lang)),
              behavior: SnackBarBehavior.floating,
            ));
          }
          return;
        }
        try {
          await Permission.scheduleExactAlarm.request();
        } catch (e) {}
        await _scheduleNotification();
      }
    } else {
      await _cancelNotification();
    }
    setState(() => _isReminderOn = value);
    await _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        if (kIsWeb) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.get('br_title', lang))),
            body: Center(child: Text(AppStrings.get('bm_whatsapp_error', lang))),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('br_title', lang)),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Illustration area
                Center(
                  child: Container(
                    height: 180,
                    width: 180,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      size: 100,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // Explanation
                Text(
                  AppStrings.get('br_explanation', lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 40),

                // Main Toggle Card
                _buildModernToggleCard(lang, isDark),

                const SizedBox(height: 24),

                // Frequency Control
                Text(
                  AppStrings.get('br_freq_label', lang),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFrequencySelector(lang, isDark),

                const SizedBox(height: 32),

                // Time Selection Card
                _buildTimeCard(lang, isDark),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernToggleCard(String lang, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          AppStrings.get('br_switch_label', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _isReminderOn ? AppStrings.get('br_status_on', lang) : AppStrings.get('br_status_off', lang),
          style: TextStyle(color: _isReminderOn ? AppColors.primary : Colors.grey, fontWeight: FontWeight.bold),
        ),
        value: _isReminderOn,
        activeColor: AppColors.primary,
        onChanged: _onToggleChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
    );
  }

  Widget _buildFrequencySelector(String lang, bool isDark) {
    return Row(
      children: [
        _buildFreqChip('Daily', AppStrings.get('br_freq_daily', lang), isDark),
        const SizedBox(width: 16),
        _buildFreqChip('Weekly', AppStrings.get('br_freq_weekly', lang), isDark),
      ],
    );
  }

  Widget _buildFreqChip(String value, String label, bool isDark) {
    final isSelected = _frequency == value;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => _frequency = value);
          if (_isReminderOn) await _scheduleNotification();
          await _saveSettings();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : (isDark ? Colors.transparent : Colors.grey.shade200),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? AppColors.darkText : AppColors.lightText),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String lang, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('br_time_label', lang),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isDark ? [] : [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.access_time_filled_rounded, color: AppColors.primary),
            ),
            title: Text(
              _selectedTime.format(context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: _pickTime,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}
