import 'package:flutter/material.dart';

enum Priority { low, medium, high, all }

class Task {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final DateTime dueDate;
  final String category;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.category,
    this.isCompleted = false,
  });

  String get priorityText {
    switch (priority) {
      case Priority.low:
        return 'Basse';
      case Priority.medium:
        return 'Moyenne';
      case Priority.high:
        return 'Haute';
      case Priority.all:
        return 'Toutes';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.all:
        return Colors.blue;
    }
  }
}