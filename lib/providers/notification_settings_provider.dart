import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  static const String _notificationReminderKey = 'notification_reminder_minutes';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  int _reminderMinutes = 30; // Default 30 minutes before deadline
  bool _notificationsEnabled = true;

  int get reminderMinutes => _reminderMinutes;
  bool get notificationsEnabled => _notificationsEnabled;

  NotificationSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _reminderMinutes = prefs.getInt(_notificationReminderKey) ?? 30;
    _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    notifyListeners();
  }

  Future<void> setReminderMinutes(int minutes) async {
    _reminderMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationReminderKey, minutes);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    notifyListeners();
  }

  // Predefined options for reminder time
  static List<int> get reminderOptions => [5, 10, 15, 30, 60, 120, 1440]; // minutes

  static String formatReminderTime(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else if (minutes == 60) {
      return '1 hour';
    } else if (minutes < 1440) {
      return '${minutes ~/ 60} hours';
    } else {
      return '1 day';
    }
  }
}

