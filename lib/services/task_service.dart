import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import 'notification_service.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Load tasks for current user
  Future<List<Task>> loadTasks() async {
    if (_currentUserId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Task.fromJson(doc.data()))
        .toList();
  }

  // Add new task
  Future<void> addTask(Task task) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson());
  }

  // Update task
  Future<void> updateTask(Task updatedTask) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .doc(updatedTask.id)
        .update(updatedTask.toJson());
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(Task task) async {
    if (_currentUserId == null) return;

    final wasCompleted = task.isCompleted;
    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .doc(task.id)
        .update({'isCompleted': !task.isCompleted});

    // Create notification when task is completed
    if (!wasCompleted) {
      final notificationService = NotificationService();
      await notificationService.createTaskCompletedNotification(task);
    }
  }
}