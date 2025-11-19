import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskCategory { work, personal, study, other }
enum TaskPriority { high, medium, low }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? deadline;
  final TaskCategory category;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.deadline,
    this.category = TaskCategory.other,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    TaskCategory? category,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: json['deadline'] != null ? (json['deadline'] as Timestamp).toDate() : null,
      category: _stringToTaskCategory(json['category']),
      priority: _stringToTaskPriority(json['priority']),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'category': _taskCategoryToString(category),
      'priority': _taskPriorityToString(priority),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Helper methods for enum conversion
  static TaskCategory _stringToTaskCategory(String categoryString) {
    switch (categoryString) {
      case 'TaskCategory.work':
        return TaskCategory.work;
      case 'TaskCategory.personal':
        return TaskCategory.personal;
      case 'TaskCategory.study':
        return TaskCategory.study;
      case 'TaskCategory.other':
      default:
        return TaskCategory.other;
    }
  }

  static TaskPriority _stringToTaskPriority(String priorityString) {
    switch (priorityString) {
      case 'TaskPriority.high':
        return TaskPriority.high;
      case 'TaskPriority.medium':
        return TaskPriority.medium;
      case 'TaskPriority.low':
      default:
        return TaskPriority.low;
    }
  }

  static String _taskCategoryToString(TaskCategory category) {
    return category.toString();
  }

  static String _taskPriorityToString(TaskPriority priority) {
    return priority.toString();
  }
}

extension TaskCategoryExtension on TaskCategory {
  IconData get icon {
    switch (this) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.study:
        return Icons.book;
      case TaskCategory.other:
        return Icons.category;
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  Color get color {
    switch (this) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}