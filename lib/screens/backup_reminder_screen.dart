import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';

// ============================================================
// BACKUP REMINDER - WhatsApp chats backup karva mate periodic
// notification set karva ni screen
// ============================================================
// Concept: User Daily ya Weekly reminder + time select kare chhe.
// Apde flutter_local_notifications vaparine ek "repeating"
// notification schedule karie chhe je e samay par vaage.
// ============================================================
class BackupReminderScreen extends StatefulWidget {
  const BackupReminderScreen({super.key});

  @override
  State<BackupReminderScreen> createState() => _BackupReminderScreenState();
}

class _BackupReminderScreenState extends State<BackupReminderScreen> {
  // Notification ID - jyare cancel karvu hoy tyare aa ID vaparay chhe
  static const int _notificationId = 100;

  bool _isReminderOn = false;
  String _frequency = 'Daily'; // 'Daily' ya 'Weekly'
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0); // Default 8 PM

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  // Pehla thi save thayela settings vaanchva mate
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

  // Settings ne save karva mate
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminderOn', _isReminderOn);
    await prefs.setString('reminderFrequency', _frequency);
    await prefs.setInt('reminderHour', _selectedTime.hour);
    await prefs.setInt('reminderMinute', _selectedTime.minute);
  }

  // Time picker kholva mate
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      // Jo reminder already ON hoy to navi time sathe re-schedule karo
      if (_isReminderOn) {
        await _scheduleNotification();
      }
      await _saveSettings();
    }
  }

  // Actual notification schedule karva mate
  Future<void> _scheduleNotification() async {
    // Aaje na date/time ma selected time set karvi
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Jo aaje nu selected time pasar thai gayu hoy, to kale thi shuru karo
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'backup_reminder_channel', // Channel ID
      'Backup Reminders', // Channel naam (Android settings ma dekhay)
      channelDescription: 'WhatsApp backup karva mate reminder',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await notificationsPlugin.zonedSchedule(
      _notificationId,
      'WhatsApp Backup Reminder',
      'Tamara WhatsApp chats backup karvanu na bhulso!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Purana flutter_local_notifications version ma aa parameter
      // required chhe - "absoluteTime" no matlab e ke apde je
      // scheduledDate nakhi chhe e j exact samay par notification aavse
      // (device timezone pramane, koi conversion vagar)
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      // matchDateTimeComponents = repeat karva mate:
      // .time = daily (roj aa samay e)
      // .dayOfWeekAndTime = weekly (aa vaar ane samay e)
      matchDateTimeComponents: _frequency == 'Daily'
          ? DateTimeComponents.time
          : DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Reminder ne cancel/band karva mate
  Future<void> _cancelNotification() async {
    await notificationsPlugin.cancel(_notificationId);
  }

  // Toggle switch dabave tyare
  Future<void> _onToggleChanged(bool value) async {
    if (value) {
      // ON karva mate pehla notification permission check karo
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Notification permission jaruri chhe')),
          );
        }
        return;
      }
      await _scheduleNotification();
    } else {
      await _cancelNotification();
    }

    setState(() => _isReminderOn = value);
    await _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Reminder'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Explanation card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'WhatsApp automatically chats backup nathi karta jyare '
                  'sudhi tame manually na karo. Aa reminder tamane yaad '
                  'karavse jethi tame kadi apna important chats na guma.',
              style: TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(height: 24),

          // Main ON/OFF toggle
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text('Reminder Chalu Karo'),
              subtitle: Text(_isReminderOn ? 'Chalu chhe' : 'Band chhe'),
              value: _isReminderOn,
              activeColor: Colors.green,
              onChanged: _onToggleChanged,
            ),
          ),

          const SizedBox(height: 16),

          // Frequency selection (Daily/Weekly)
          const Text(
            'Ketli vaar yaad karavvu:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Daily'),
                  selected: _frequency == 'Daily',
                  selectedColor: Colors.green[200],
                  onSelected: (selected) async {
                    setState(() => _frequency = 'Daily');
                    if (_isReminderOn) await _scheduleNotification();
                    await _saveSettings();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Weekly'),
                  selected: _frequency == 'Weekly',
                  selectedColor: Colors.green[200],
                  onSelected: (selected) async {
                    setState(() => _frequency = 'Weekly');
                    if (_isReminderOn) await _scheduleNotification();
                    await _saveSettings();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Time selection
          const Text(
            'Kaya samay e:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.access_time, color: Colors.green),
              title: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: _pickTime,
            ),
          ),
        ],
      ),
    );
  }
}
