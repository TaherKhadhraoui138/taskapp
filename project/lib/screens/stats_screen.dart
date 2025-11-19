import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../main.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  int _totalTasks = 0;
  int _completedTasks = 0;
  double _completionRate = 0.0;
  Map<TaskCategory, int> _tasksByCategory = {};
  Map<TaskPriority, int> _tasksByPriority = {};
  List<Task> _allTasks = [];
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final tasks = await _taskService.loadTasks();
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final completionRate = total > 0 ? (completed / total) : 0.0;

    // Calculate tasks by category
    final Map<TaskCategory, int> categoryMap = {};
    for (var category in TaskCategory.values) {
      categoryMap[category] = tasks.where((t) => t.category == category).length;
    }

    // Calculate tasks by priority
    final Map<TaskPriority, int> priorityMap = {};
    for (var priority in TaskPriority.values) {
      priorityMap[priority] = tasks.where((t) => t.priority == priority && !t.isCompleted).length;
    }

    setState(() {
      _allTasks = tasks;
      _totalTasks = total;
      _completedTasks = completed;
      _completionRate = completionRate;
      _tasksByCategory = categoryMap;
      _tasksByPriority = priorityMap;
    });

    // Animate progress bar
    _progressAnimation = Tween<double>(begin: 0.0, end: completionRate).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward(from: 0.0);
  }

  Widget _buildCategoryChart() {
    final totalCategoryTasks = _tasksByCategory.values.fold(0, (sum, count) => sum + count);
    if (totalCategoryTasks == 0) {
      return const Center(child: Text('No tasks to display', style: TextStyle(color: Colors.grey)));
    }

    return Column(
      children: TaskCategory.values.map((category) {
        final count = _tasksByCategory[category] ?? 0;
        final percentage = count / totalCategoryTasks;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(category.icon, size: 24, color: primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.toString().split('.').last.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$count tasks',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityDistribution() {
    final totalPriorityTasks = _tasksByPriority.values.fold(0, (sum, count) => sum + count);
    if (totalPriorityTasks == 0) {
      return const Center(child: Text('No pending tasks', style: TextStyle(color: Colors.grey)));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: TaskPriority.values.map((priority) {
        final count = _tasksByPriority[priority] ?? 0;
        final percentage = count / totalPriorityTasks;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: priority.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: priority.color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: priority.color.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: priority.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  priority.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: priority.color,
                  ),
                ),
                Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyProgress() {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) {
            final tasksCompleted = _allTasks.where((task) {
              return task.isCompleted &&
                  task.createdAt.year == day.year &&
                  task.createdAt.month == day.month &&
                  task.createdAt.day == day.day;
            }).length;

            final isToday = day.year == now.year &&
                day.month == now.month &&
                day.day == now.day;

            return Column(
              children: [
                Text(
                  DateFormat('E').format(day)[0],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? primaryColor : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tasksCompleted > 0
                        ? primaryColor.withOpacity(0.8)
                        : Colors.grey.shade200,
                    border: isToday ? Border.all(color: primaryColor, width: 2) : null,
                  ),
                  child: Center(
                    child: Text(
                      tasksCompleted.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: tasksCompleted > 0 ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Stats Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.playlist_add_check,
                            label: 'Completed',
                            value: _completedTasks.toString(),
                            color: secondaryColor,
                          ),
                          Container(width: 1, height: 50, color: Colors.grey.shade300),
                          _buildStatItem(
                            icon: Icons.list,
                            label: 'Total',
                            value: _totalTasks.toString(),
                            color: primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Completion Rate',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _progressAnimation.value,
                                  minHeight: 20,
                                  backgroundColor: Colors.grey.shade300,
                                  color: secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(_progressAnimation.value * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: secondaryColor,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Weekly Progress
              const Text(
                'Weekly Progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildWeeklyProgress(),
                ),
              ),
              const SizedBox(height: 24),

              // Category Distribution
              const Text(
                'Tasks by Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildCategoryChart(),
                ),
              ),
              const SizedBox(height: 24),

              // Priority Distribution
              const Text(
                'Pending Tasks by Priority',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPriorityDistribution(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}