import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../core/app_theme.dart';
import '../core/animated_widgets.dart';

class TaskListItem extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  LinearGradient _getPriorityGradient() {
    switch (widget.task.priority) {
      case TaskPriority.high:
        return AppGradients.priorityHigh;
      case TaskPriority.medium:
        return AppGradients.priorityMedium;
      case TaskPriority.low:
        return AppGradients.priorityLow;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.task.category) {
      case TaskCategory.work:
        return Icons.work_outline_rounded;
      case TaskCategory.personal:
        return Icons.person_outline_rounded;
      case TaskCategory.study:
        return Icons.school_outlined;
      case TaskCategory.other:
        return Icons.category_outlined;
    }
  }

  Color _getCategoryColor() {
    switch (widget.task.category) {
      case TaskCategory.work:
        return AppColors.categoryWork;
      case TaskCategory.personal:
        return AppColors.categoryPersonal;
      case TaskCategory.study:
        return AppColors.categoryStudy;
      case TaskCategory.other:
        return AppColors.categoryOther;
    }
  }

  bool _isOverdue() {
    if (widget.task.deadline == null || widget.task.isCompleted) return false;
    return widget.task.deadline!.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = _getPriorityColor();
    final hasSubtasks = widget.task.subtasks.isNotEmpty;
    final completionPercentage = widget.task.completionPercentage;
    final isRecurring = widget.task.recurrenceType != RecurrenceType.none;
    final isOverdue = _isOverdue();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Dismissible(
          key: ValueKey(widget.task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => widget.onDelete(),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: AppBorders.large),
                  backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                  title: Text(
                    "Delete Task?",
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: Text(
                    "Are you sure you want to delete '${widget.task.title}'?",
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              gradient: AppGradients.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: priorityColor.withOpacity(isDark ? 0.2 : 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Priority indicator
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 5,
                      decoration: BoxDecoration(
                        gradient: _getPriorityGradient(),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Checkbox
                            GestureDetector(
                              onTap: widget.onToggle,
                              child: AnimatedCheckMark(
                                isChecked: widget.task.isCompleted,
                                color: priorityColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.task.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: widget.task.isCompleted
                                                ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                            decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ),
                                      if (isRecurring)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: AppGradients.accent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                widget.task.recurrenceType.icon,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                widget.task.recurrenceType.displayName,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Info row
                                  Row(
                                    children: [
                                      // Category
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor().withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getCategoryIcon(),
                                              size: 14,
                                              color: _getCategoryColor(),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              widget.task.category.toString().split('.').last.capitalize(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: _getCategoryColor(),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 8),
                                      
                                      // Deadline
                                      if (widget.task.deadline != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isOverdue
                                                ? AppColors.errorStart.withOpacity(0.1)
                                                : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isOverdue ? Icons.warning_rounded : Icons.schedule_rounded,
                                                size: 14,
                                                color: isOverdue
                                                    ? AppColors.errorStart
                                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatDeadline(widget.task.deadline!),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isOverdue
                                                      ? AppColors.errorStart
                                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                                  fontWeight: FontWeight.w500,
                                                  decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      
                                      const Spacer(),
                                      
                                      // Arrow
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 12,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Subtasks progress
                                  if (hasSubtasks && !widget.task.isCompleted) ...[
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.checklist_rounded,
                                          size: 14,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${widget.task.subtasks.where((s) => s.isCompleted).length}/${widget.task.subtasks.length} subtasks',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${(completionPercentage * 100).toInt()}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: priorityColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.0, end: completionPercentage),
                                        duration: const Duration(milliseconds: 800),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) {
                                          return Stack(
                                            children: [
                                              Container(
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              FractionallySizedBox(
                                                widthFactor: value,
                                                child: Container(
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    gradient: _getPriorityGradient(),
                                                    borderRadius: BorderRadius.circular(10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: priorityColor.withOpacity(0.4),
                                                        blurRadius: 6,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.inDays == 0 && deadline.day == now.day) {
      return 'Today ${DateFormat('HH:mm').format(deadline)}';
    } else if (difference.inDays == 1 || (difference.inDays == 0 && deadline.day == now.day + 1)) {
      return 'Tomorrow ${DateFormat('HH:mm').format(deadline)}';
    } else if (difference.inDays < 7 && difference.inDays > 0) {
      return DateFormat('EEE HH:mm').format(deadline);
    }
    return DateFormat('dd MMM HH:mm').format(deadline);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}