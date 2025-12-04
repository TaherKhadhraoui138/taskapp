import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { deadline, completed, reminder }

class AppNotification {
  final String id;
  final String taskId;
  final String taskTitle;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    String? id,
    required this.taskId,
    required this.taskTitle,
    required this.message,
    required this.type,
    DateTime? createdAt,
    this.isRead = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  AppNotification copyWith({
    String? id,
    String? taskId,
    String? taskTitle,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'message': message,
      'type': _notificationTypeToString(type),
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      taskId: json['taskId'],
      taskTitle: json['taskTitle'],
      message: json['message'],
      type: _stringToNotificationType(json['type']),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
    );
  }

  static String _notificationTypeToString(NotificationType type) {
    return type.toString();
  }

  static NotificationType _stringToNotificationType(String typeString) {
    switch (typeString) {
      case 'NotificationType.deadline':
        return NotificationType.deadline;
      case 'NotificationType.completed':
        return NotificationType.completed;
      case 'NotificationType.reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.reminder;
    }
  }
}

