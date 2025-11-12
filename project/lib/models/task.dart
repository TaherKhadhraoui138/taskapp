import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.deadline,
    this.category = TaskCategory.other,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Task copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    TaskCategory? category,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      category: TaskCategory.values.firstWhere((e) => e.toString() == json['category']),
      priority: TaskPriority.values.firstWhere((e) => e.toString() == json['priority']),
      isCompleted: json['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'category': category.toString(),
      'priority': priority.toString(),
      'isCompleted': isCompleted,
    };
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
