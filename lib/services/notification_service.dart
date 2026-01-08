import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';

/// Service untuk mengelola notifikasi lokal dan menyimpan preferensi
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Preference keys
  static const String _keyBreakfastEnabled = 'notif_breakfast_enabled';
  static const String _keyLunchEnabled = 'notif_lunch_enabled';
  static const String _keyDinnerEnabled = 'notif_dinner_enabled';
  static const String _keyWeeklyEnabled = 'notif_weekly_enabled';
  static const String _keyBreakfastHour = 'notif_breakfast_hour';
  static const String _keyBreakfastMinute = 'notif_breakfast_minute';
  static const String _keyLunchHour = 'notif_lunch_hour';
  static const String _keyLunchMinute = 'notif_lunch_minute';
  static const String _keyDinnerHour = 'notif_dinner_hour';
  static const String _keyDinnerMinute = 'notif_dinner_minute';
  static const String _keyThemeMode = 'theme_mode';

  // Notification IDs
  static const int _breakfastNotifId = 1;
  static const int _lunchNotifId = 2;
  static const int _dinnerNotifId = 3;
  static const int _weeklyNotifId = 4;

  /// Initialize notification service
  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    // Set local timezone (Asia/Jakarta for WIB)
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      // Fallback to UTC if timezone not found
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Request permission for Android 13+
    await _requestPermission();
  }

  Future<void> _requestPermission() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  // ===== PREFERENCE METHODS =====

  /// Load notification preferences from SharedPreferences
  Future<NotificationPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    return NotificationPreferences(
      breakfastEnabled: prefs.getBool(_keyBreakfastEnabled) ?? true,
      lunchEnabled: prefs.getBool(_keyLunchEnabled) ?? true,
      dinnerEnabled: prefs.getBool(_keyDinnerEnabled) ?? true,
      weeklyEnabled: prefs.getBool(_keyWeeklyEnabled) ?? false,
      breakfastTime: TimeOfDay(
        hour: prefs.getInt(_keyBreakfastHour) ?? 7,
        minute: prefs.getInt(_keyBreakfastMinute) ?? 0,
      ),
      lunchTime: TimeOfDay(
        hour: prefs.getInt(_keyLunchHour) ?? 12,
        minute: prefs.getInt(_keyLunchMinute) ?? 0,
      ),
      dinnerTime: TimeOfDay(
        hour: prefs.getInt(_keyDinnerHour) ?? 19,
        minute: prefs.getInt(_keyDinnerMinute) ?? 0,
      ),
    );
  }

  /// Save notification preferences and schedule notifications
  Future<void> savePreferences(NotificationPreferences prefs) async {
    try {
      // ignore: avoid_print
      print('Saving notification preferences...');

      final storage = await SharedPreferences.getInstance();

      // Save enabled states
      await storage.setBool(_keyBreakfastEnabled, prefs.breakfastEnabled);
      await storage.setBool(_keyLunchEnabled, prefs.lunchEnabled);
      await storage.setBool(_keyDinnerEnabled, prefs.dinnerEnabled);
      await storage.setBool(_keyWeeklyEnabled, prefs.weeklyEnabled);

      // Save times
      await storage.setInt(_keyBreakfastHour, prefs.breakfastTime.hour);
      await storage.setInt(_keyBreakfastMinute, prefs.breakfastTime.minute);
      await storage.setInt(_keyLunchHour, prefs.lunchTime.hour);
      await storage.setInt(_keyLunchMinute, prefs.lunchTime.minute);
      await storage.setInt(_keyDinnerHour, prefs.dinnerTime.hour);
      await storage.setInt(_keyDinnerMinute, prefs.dinnerTime.minute);

      // ignore: avoid_print
      print('Preferences saved. Scheduling notifications...');

      // Reschedule all notifications
      await _scheduleAllNotifications(prefs);

      // ignore: avoid_print
      print('All notifications scheduled successfully!');
    } catch (e) {
      // ignore: avoid_print
      print('Error saving preferences: $e');
    }
  }

  // ===== THEME PREFERENCE =====

  /// Save theme mode preference
  Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyThemeMode, isDark);
  }

  /// Load theme mode preference
  Future<bool> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyThemeMode) ?? true; // Default: dark mode
  }

  // ===== NOTIFICATION SCHEDULING =====

  Future<void> _scheduleAllNotifications(NotificationPreferences prefs) async {
    // Cancel all existing notifications
    await _notifications.cancelAll();

    // Schedule based on preferences
    if (prefs.breakfastEnabled) {
      await _scheduleDailyNotification(
        id: _breakfastNotifId,
        title: '🍳 Saatnya Sarapan!',
        body: 'Jangan lupa catat sarapanmu di NutriCare',
        time: prefs.breakfastTime,
      );
    }

    if (prefs.lunchEnabled) {
      await _scheduleDailyNotification(
        id: _lunchNotifId,
        title: '🍱 Waktunya Makan Siang',
        body: 'Sudah makan siang? Catat makananmu sekarang',
        time: prefs.lunchTime,
      );
    }

    if (prefs.dinnerEnabled) {
      await _scheduleDailyNotification(
        id: _dinnerNotifId,
        title: '🍽️ Makan Malam',
        body: 'Jangan lupa catat makan malammu',
        time: prefs.dinnerTime,
      );
    }

    if (prefs.weeklyEnabled) {
      await _scheduleWeeklyNotification(
        id: _weeklyNotifId,
        title: '📊 Ringkasan Mingguan',
        body: 'Lihat progress nutrisimu minggu ini',
      );
    }
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Debug: print scheduled time
      // ignore: avoid_print
      print('Scheduling notification $id for: $scheduledDate');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Pengingat Makan',
            channelDescription: 'Notifikasi pengingat waktu makan',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      // ignore: avoid_print
      print('Notification $id scheduled successfully');
    } catch (e) {
      // ignore: avoid_print
      print('Error scheduling notification $id: $e');
    }
  }

  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      // Calculate days until next Sunday
      int daysUntilSunday = DateTime.sunday - now.weekday;
      if (daysUntilSunday <= 0) {
        daysUntilSunday += 7;
      }

      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + daysUntilSunday,
        9, // 09:00
        0,
      );

      // ignore: avoid_print
      print('Scheduling weekly notification for: $scheduledDate');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_summary',
            'Ringkasan Mingguan',
            channelDescription: 'Notifikasi ringkasan mingguan',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      // ignore: avoid_print
      print('Weekly notification scheduled successfully');
    } catch (e) {
      // ignore: avoid_print
      print('Error scheduling weekly notification: $e');
    }
  }

  /// Show immediate test notification
  Future<void> showTestNotification() async {
    await _notifications.show(
      0,
      '✅ Notifikasi Aktif!',
      'NutriCare siap mengingatkan jadwal makanmu',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'For testing notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Test scheduled notification (10 seconds in future)
  Future<bool> testScheduledNotification() async {
    try {
      final scheduledTime = tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 10));

      // ignore: avoid_print
      print('Testing scheduled notification for: $scheduledTime');

      await _notifications.zonedSchedule(
        99, // Test ID
        '⏰ Scheduled Test!',
        'Ini adalah test scheduled notification',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_scheduled',
            'Test Scheduled',
            channelDescription: 'For testing scheduled notifications',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // ignore: avoid_print
      print('Scheduled test notification created successfully!');
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating scheduled test notification: $e');
      return false;
    }
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}

/// Data class untuk menyimpan preferensi notifikasi
class NotificationPreferences {
  final bool breakfastEnabled;
  final bool lunchEnabled;
  final bool dinnerEnabled;
  final bool weeklyEnabled;
  final TimeOfDay breakfastTime;
  final TimeOfDay lunchTime;
  final TimeOfDay dinnerTime;

  const NotificationPreferences({
    this.breakfastEnabled = true,
    this.lunchEnabled = true,
    this.dinnerEnabled = true,
    this.weeklyEnabled = false,
    this.breakfastTime = const TimeOfDay(hour: 7, minute: 0),
    this.lunchTime = const TimeOfDay(hour: 12, minute: 0),
    this.dinnerTime = const TimeOfDay(hour: 19, minute: 0),
  });

  NotificationPreferences copyWith({
    bool? breakfastEnabled,
    bool? lunchEnabled,
    bool? dinnerEnabled,
    bool? weeklyEnabled,
    TimeOfDay? breakfastTime,
    TimeOfDay? lunchTime,
    TimeOfDay? dinnerTime,
  }) {
    return NotificationPreferences(
      breakfastEnabled: breakfastEnabled ?? this.breakfastEnabled,
      lunchEnabled: lunchEnabled ?? this.lunchEnabled,
      dinnerEnabled: dinnerEnabled ?? this.dinnerEnabled,
      weeklyEnabled: weeklyEnabled ?? this.weeklyEnabled,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
    );
  }
}
