import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskCategory { work, personal, study, other }
enum TaskPriority { high, medium, low }
enum RecurrenceType { none, daily, weekly, monthly, custom }

class Subtask {
  final String id;
  final String title;
  final bool isCompleted;

  Subtask({
    String? id,
    required this.title,
    this.isCompleted = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Subtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? deadline;
  final TaskCategory category;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final List<Subtask> subtasks;
  final RecurrenceType recurrenceType;
  final int? recurrenceInterval; // For custom recurrence
  final DateTime? recurrenceEndDate;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.deadline,
    this.category = TaskCategory.other,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    DateTime? createdAt,
    List<Subtask>? subtasks,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceInterval,
    this.recurrenceEndDate,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now(),
        subtasks = subtasks ?? [];

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    TaskCategory? category,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    List<Subtask>? subtasks,
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
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
      subtasks: subtasks ?? this.subtasks,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
    );
  }

  // Calculate completion percentage based on subtasks
  double get completionPercentage {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completedSubtasks = subtasks.where((s) => s.isCompleted).length;
    return completedSubtasks / subtasks.length;
  }

  // Check if all subtasks are completed
  bool get areAllSubtasksCompleted {
    if (subtasks.isEmpty) return true;
    return subtasks.every((s) => s.isCompleted);
  }

  // Get next occurrence for recurring tasks
  DateTime? getNextOccurrence() {
    if (recurrenceType == RecurrenceType.none || deadline == null) return null;

    final now = DateTime.now();
    DateTime nextDate = deadline!;

    while (nextDate.isBefore(now)) {
      switch (recurrenceType) {
        case RecurrenceType.daily:
          nextDate = nextDate.add(const Duration(days: 1));
          break;
        case RecurrenceType.weekly:
          nextDate = nextDate.add(const Duration(days: 7));
          break;
        case RecurrenceType.monthly:
          nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
          break;
        case RecurrenceType.custom:
          if (recurrenceInterval != null) {
            nextDate = nextDate.add(Duration(days: recurrenceInterval!));
          }
          break;
        case RecurrenceType.none:
          return null;
      }

      // Check if we've exceeded the end date
      if (recurrenceEndDate != null && nextDate.isAfter(recurrenceEndDate!)) {
        return null;
      }
    }

    return nextDate;
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
      subtasks: (json['subtasks'] as List<dynamic>?)
          ?.map((s) => Subtask.fromJson(s as Map<String, dynamic>))
          .toList() ??
          [],
      recurrenceType: _stringToRecurrenceType(json['recurrenceType']),
      recurrenceInterval: json['recurrenceInterval'],
      recurrenceEndDate: json['recurrenceEndDate'] != null
          ? (json['recurrenceEndDate'] as Timestamp).toDate()
          : null,
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
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'recurrenceType': _recurrenceTypeToString(recurrenceType),
      'recurrenceInterval': recurrenceInterval,
      'recurrenceEndDate': recurrenceEndDate != null ? Timestamp.fromDate(recurrenceEndDate!) : null,
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

  static RecurrenceType _stringToRecurrenceType(String? recurrenceString) {
    if (recurrenceString == null) return RecurrenceType.none;
    switch (recurrenceString) {
      case 'RecurrenceType.daily':
        return RecurrenceType.daily;
      case 'RecurrenceType.weekly':
        return RecurrenceType.weekly;
      case 'RecurrenceType.monthly':
        return RecurrenceType.monthly;
      case 'RecurrenceType.custom':
        return RecurrenceType.custom;
      case 'RecurrenceType.none':
      default:
        return RecurrenceType.none;
    }
  }

  static String _taskCategoryToString(TaskCategory category) {
    return category.toString();
  }

  static String _taskPriorityToString(TaskPriority priority) {
    return priority.toString();
  }

  static String _recurrenceTypeToString(RecurrenceType recurrence) {
    return recurrence.toString();
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

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'None';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case RecurrenceType.none:
        return Icons.event_available;
      case RecurrenceType.daily:
        return Icons.today;
      case RecurrenceType.weekly:
        return Icons.view_week;
      case RecurrenceType.monthly:
        return Icons.calendar_month;
      case RecurrenceType.custom:
        return Icons.settings;
    }
  }
}