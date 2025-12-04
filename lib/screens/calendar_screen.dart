import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/task_list_item.dart';
import '../core/app_theme.dart';
import '../core/animated_widgets.dart';
import '../main.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskService _taskService = TaskService();
  DateTime _selectedDay = DateTime.now();
  List<Task> _tasksForSelectedDay = [];
  Map<DateTime, List<Task>> _tasksByDay = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final allTasks = await _taskService.loadTasks();
    final Map<DateTime, List<Task>> tasksByDay = {};

    for (var task in allTasks.where((t) => t.deadline != null)) {
      final day = DateTime(task.deadline!.year, task.deadline!.month, task.deadline!.day);
      if (!tasksByDay.containsKey(day)) {
        tasksByDay[day] = [];
      }
      tasksByDay[day]!.add(task);
    }

    setState(() {
      _tasksByDay = tasksByDay;
      _updateTasksForSelectedDay(_selectedDay);
    });
  }

  void _updateTasksForSelectedDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    setState(() {
      _selectedDay = normalizedDay;
      _tasksForSelectedDay = _tasksByDay[normalizedDay] ?? [];
      _tasksForSelectedDay.sort((a, b) => a.deadline!.compareTo(b.deadline!));
    });
  }

  void _toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _taskService.updateTask(updatedTask);
    _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    await _taskService.deleteTask(task.id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isToday = _selectedDay.year == DateTime.now().year &&
        _selectedDay.month == DateTime.now().month &&
        _selectedDay.day == DateTime.now().day;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purple.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyan.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppGradients.aurora.createShader(bounds),
                        child: Text(
                          'Calendar',
                          style: AppTextStyles.heading1.copyWith(color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _updateTasksForSelectedDay(DateTime.now()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isToday ? AppGradients.aurora : null,
                            color: isToday ? null : (isDark ? AppColors.cardDark : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isToday
                                ? [
                                    BoxShadow(
                                      color: AppColors.purple.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : AppShadows.small,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.today_rounded,
                                size: 18,
                                color: isToday ? Colors.white : AppColors.purple,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Today',
                                style: AppTextStyles.caption.copyWith(
                                  color: isToday ? Colors.white : AppColors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Date Selector
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isDark ? AppColors.cardDark : Colors.white,
                        AppColors.purple.withOpacity(isDark ? 0.15 : 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.medium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _updateTasksForSelectedDay(_selectedDay.subtract(const Duration(days: 1)));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppGradients.aurora,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purple.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDay,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.purple,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: AppColors.charcoal,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null && picked != _selectedDay) {
                            _updateTasksForSelectedDay(picked);
                          }
                        },
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => AppGradients.aurora.createShader(bounds),
                              child: Text(
                                DateFormat('EEEE').format(_selectedDay),
                                style: AppTextStyles.heading3.copyWith(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d MMMM yyyy').format(_selectedDay),
                              style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _updateTasksForSelectedDay(_selectedDay.add(const Duration(days: 1)));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppGradients.aurora,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purple.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Task count badge
                if (_tasksForSelectedDay.isNotEmpty)
                  SlideAnimation(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.purple.withOpacity(0.1),
                            AppColors.cyan.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppGradients.aurora,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.event_note_rounded, size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_tasksForSelectedDay.length} task${_tasksForSelectedDay.length > 1 ? 's' : ''} scheduled',
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppGradients.aurora,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_tasksForSelectedDay.where((t) => t.isCompleted).length}/${_tasksForSelectedDay.length}',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Task list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadTasks,
                    color: AppColors.purple,
                    child: _tasksForSelectedDay.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PulseAnimation(
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.purple.withOpacity(0.1),
                                          AppColors.cyan.withOpacity(0.1),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) => AppGradients.aurora.createShader(bounds),
                                      child: const Icon(
                                        Icons.event_available_rounded,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No tasks scheduled',
                                  style: AppTextStyles.subtitle.copyWith(color: AppColors.charcoal),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('d MMMM').format(_selectedDay),
                                  style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            itemCount: _tasksForSelectedDay.length,
                            itemBuilder: (context, index) {
                              final task = _tasksForSelectedDay[index];
                              return StaggeredListItem(
                                index: index,
                                child: TaskListItem(
                                  key: ValueKey(task.id),
                                  task: task,
                                  onTap: () {
                                    // Navigation logic
                                  },
                                  onToggle: () => _toggleTaskCompletion(task),
                                  onDelete: () => _deleteTask(task),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
