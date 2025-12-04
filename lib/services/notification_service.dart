import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';
import '../models/app_notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _checkTimer;
  bool _isInitialized = false;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _requestPermissions();

    _isInitialized = true;

    // Start periodic check for task deadlines
    _startPeriodicCheck();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific task
    debugPrint('Notification tapped: ${response.payload}');
  }

  // Start periodic check for task deadlines (every minute)
  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkTaskDeadlines();
    });
    // Also check immediately
    _checkTaskDeadlines();
  }

  // Stop periodic check
  void stopPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  // Check all tasks for upcoming deadlines
  Future<void> _checkTaskDeadlines() async {
    if (_currentUserId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .get();

      final now = DateTime.now();

      for (final doc in snapshot.docs) {
        final task = Task.fromJson(doc.data());

        if (task.deadline != null && !task.isCompleted) {
          final timeUntilDeadline = task.deadline!.difference(now);

          // Check if deadline is within 30 minutes and more than 0
          if (timeUntilDeadline.inMinutes <= 30 && timeUntilDeadline.inMinutes > 0) {
            await _sendDeadlineNotification(task, timeUntilDeadline.inMinutes);
          }

          // Check if deadline has passed
          if (timeUntilDeadline.inMinutes <= 0 && timeUntilDeadline.inMinutes > -1) {
            await _sendOverdueNotification(task);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking task deadlines: $e');
    }
  }

  // Send notification for upcoming deadline
  Future<void> _sendDeadlineNotification(Task task, int minutesLeft) async {
    // Check if we already sent a notification for this task recently
    final existingNotification = await _checkExistingNotification(
      task.id,
      NotificationType.deadline,
      const Duration(minutes: 30),
    );

    if (existingNotification) return;

    final message = 'Task "${task.title}" is due in $minutesLeft minutes!';

    // Send local notification
    await _showNotification(
      id: task.id.hashCode,
      title: '⏰ Task Reminder',
      body: message,
      payload: task.id,
    );

    // Save notification to Firestore
    await _saveNotification(AppNotification(
      taskId: task.id,
      taskTitle: task.title,
      message: message,
      type: NotificationType.deadline,
    ));
  }

  // Send notification for overdue task
  Future<void> _sendOverdueNotification(Task task) async {
    // Check if we already sent a notification for this task recently
    final existingNotification = await _checkExistingNotification(
      task.id,
      NotificationType.completed,
      const Duration(hours: 1),
    );

    if (existingNotification) return;

    final message = 'Task "${task.title}" is overdue!';

    // Send local notification
    await _showNotification(
      id: task.id.hashCode + 1000,
      title: '🚨 Overdue Task',
      body: message,
      payload: task.id,
    );

    // Save notification to Firestore
    await _saveNotification(AppNotification(
      taskId: task.id,
      taskTitle: task.title,
      message: message,
      type: NotificationType.completed,
    ));
  }

  // Send notification when task is completed
  Future<void> sendTaskCompletedNotification(Task task) async {
    final message = 'Congratulations! You completed the task "${task.title}"!';

    // Send local notification
    await _showNotification(
      id: task.id.hashCode + 2000,
      title: '✅ Task Completed',
      body: message,
      payload: task.id,
    );

    // Save notification to Firestore
    await _saveNotification(AppNotification(
      taskId: task.id,
      taskTitle: task.title,
      message: message,
      type: NotificationType.completed,
    ));
  }

  // Check if a similar notification was already sent recently
  Future<bool> _checkExistingNotification(
    String taskId,
    NotificationType type,
    Duration within,
  ) async {
    if (_currentUserId == null) return false;

    try {
      final cutoffTime = DateTime.now().subtract(within);
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('notifications')
          .where('taskId', isEqualTo: taskId)
          .where('type', isEqualTo: type.toString())
          .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking existing notification: $e');
      return false;
    }
  }

  // Show local notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_notifications',
      'Task Notifications',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Save notification to Firestore
  Future<void> _saveNotification(AppNotification notification) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  // Get all notifications for current user
  Future<List<AppNotification>> getNotifications() async {
    if (_currentUserId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      return [];
    }
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    if (_currentUserId == null) return 0;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    if (_currentUserId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('notifications')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
    }
  }

  // Schedule a notification for a specific time (30 min before deadline)
  Future<void> scheduleDeadlineNotification(Task task) async {
    if (task.deadline == null) return;

    final scheduledTime = task.deadline!.subtract(const Duration(minutes: 30));

    if (scheduledTime.isBefore(DateTime.now())) return;

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_task_notifications',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for tasks',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode + 3000,
      '⏰ Task Reminder',
      'Task "${task.title}" is due in 30 minutes!',
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: task.id,
    );
  }

  // Cancel scheduled notification for a task
  Future<void> cancelScheduledNotification(String taskId) async {
    await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode + 3000);
  }
}

