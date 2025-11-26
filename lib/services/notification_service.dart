import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';
import '../models/task.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _notificationTimer;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Start checking for tasks with approaching deadlines
  void startNotificationService() {
    // Check every 5 minutes for tasks with approaching deadlines
    _notificationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkTaskDeadlines();
    });
    // Check immediately on start
    _checkTaskDeadlines();
  }

  // Stop the notification service
  void stopNotificationService() {
    _notificationTimer?.cancel();
  }

  // Check for tasks with deadlines within 30 minutes
  Future<void> _checkTaskDeadlines() async {
    if (_currentUserId == null) return;

    try {
      final now = DateTime.now();
      final thirtyMinutesFromNow = now.add(const Duration(minutes: 30));

      // Get all uncompleted tasks
      final tasksSnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .get();

      for (var doc in tasksSnapshot.docs) {
        final taskData = doc.data();
        if (taskData['deadline'] != null) {
          final deadline = (taskData['deadline'] as Timestamp).toDate();

          // Check if deadline is within the next 30 minutes
          if (deadline.isAfter(now) && deadline.isBefore(thirtyMinutesFromNow)) {
            // Check if we already sent a notification for this task
            final existingNotifSnapshot = await _firestore
                .collection('users')
                .doc(_currentUserId)
                .collection('notifications')
                .where('taskId', isEqualTo: taskData['id'])
                .where('type', isEqualTo: 'taskDeadline')
                .get();

            // Only create notification if one doesn't exist for this task
            if (existingNotifSnapshot.docs.isEmpty) {
              final notification = AppNotification(
                title: 'Échéance proche !',
                message: 'La tâche "${taskData['title']}" arrive à échéance dans moins de 30 minutes',
                type: NotificationType.taskDeadline,
                taskId: taskData['id'],
                taskTitle: taskData['title'],
              );

              await addNotification(notification);
            }
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification des échéances: $e');
    }
  }

  // Add a notification
  Future<void> addNotification(AppNotification notification) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toJson());
  }

  // Get all notifications for current user
  Stream<List<AppNotification>> getNotifications() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromJson(doc.data()))
            .toList());
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    if (_currentUserId == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Get unread notification count
  Stream<int> getUnreadCount() {
    if (_currentUserId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create notification when a task is completed
  Future<void> createTaskCompletedNotification(Task task) async {
    final notification = AppNotification(
      title: 'Tâche complétée !',
      message: 'Félicitations ! Vous avez terminé "${task.title}"',
      type: NotificationType.taskCompleted,
      taskId: task.id,
      taskTitle: task.title,
    );

    await addNotification(notification);
  }
}

