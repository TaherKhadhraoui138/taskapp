import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../core/app_theme.dart';
import '../core/animated_widgets.dart';
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
      return Center(
        child: Column(
          children: [
            Icon(Icons.category_outlined, size: 48, color: AppColors.grey.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text('No tasks to display', style: AppTextStyles.caption.copyWith(color: AppColors.grey)),
          ],
        ),
      );
    }

    final categoryGradients = {
      TaskCategory.work: AppGradients.primary,
      TaskCategory.personal: AppGradients.secondary,
      TaskCategory.study: AppGradients.sunset,
      TaskCategory.other: AppGradients.ocean,
    };

    return Column(
      children: TaskCategory.values.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final count = _tasksByCategory[category] ?? 0;
        final percentage = count / totalCategoryTasks;
        final gradient = categoryGradients[category] ?? AppGradients.primary;

        return SlideAnimation(
          delay: Duration(milliseconds: 100 * index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(category.icon, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.toString().split('.').last.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$count',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: percentage),
                          duration: Duration(milliseconds: 800 + (index * 100)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: value,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient: gradient,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityDistribution() {
    final totalPriorityTasks = _tasksByPriority.values.fold(0, (sum, count) => sum + count);
    if (totalPriorityTasks == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.celebration_rounded, size: 48, color: AppColors.cyan),
              const SizedBox(height: 12),
              Text('All caught up!', style: AppTextStyles.subtitle.copyWith(color: AppColors.cyan)),
              Text('No pending tasks', style: AppTextStyles.caption.copyWith(color: AppColors.grey)),
            ],
          ),
        ),
      );
    }

    final priorityGradients = {
      TaskPriority.low: [const Color(0xFF4CAF50), const Color(0xFF81C784)],
      TaskPriority.medium: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
      TaskPriority.high: [const Color(0xFFF44336), const Color(0xFFE57373)],
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: TaskPriority.values.asMap().entries.map((entry) {
        final index = entry.key;
        final priority = entry.value;
        final count = _tasksByPriority[priority] ?? 0;
        final percentage = count / totalPriorityTasks;
        final colors = priorityGradients[priority]!;

        return Expanded(
          child: SlideAnimation(
            delay: Duration(milliseconds: 200 + (index * 100)),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.first.withOpacity(0.15),
                    colors.last.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.first.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 800 + (index * 200)),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: colors),
                            boxShadow: [
                              BoxShadow(
                                color: colors.first.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              count.toString(),
                              style: AppTextStyles.heading2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    priority.toString().split('.').last.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.first,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.first.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: colors.first,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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
          children: weekDays.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final tasksCompleted = _allTasks.where((task) {
              return task.isCompleted &&
                  task.createdAt.year == day.year &&
                  task.createdAt.month == day.month &&
                  task.createdAt.day == day.day;
            }).length;

            final isToday = day.year == now.year &&
                day.month == now.month &&
                day.day == now.day;

            return SlideAnimation(
              delay: Duration(milliseconds: 50 * index),
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(day)[0],
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? AppColors.coral : AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 500 + (index * 80)),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: tasksCompleted > 0
                                ? AppGradients.primary
                                : null,
                            color: tasksCompleted > 0 ? null : Colors.grey.shade100,
                            border: isToday
                                ? Border.all(color: AppColors.coral, width: 2.5)
                                : null,
                            boxShadow: tasksCompleted > 0
                                ? [
                                    BoxShadow(
                                      color: AppColors.coral.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              tasksCompleted.toString(),
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tasksCompleted > 0 ? Colors.white : AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.coral.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
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
            child: RefreshIndicator(
              onRefresh: _loadStats,
              color: AppColors.coral,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    SlideAnimation(
                      child: Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
                            child: Text(
                              'Statistics',
                              style: AppTextStyles.heading1.copyWith(color: Colors.white),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppGradients.primary,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.coral.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.analytics_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Main Stats Card
                    SlideAnimation(
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              AppColors.coral.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppShadows.medium,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  icon: Icons.check_circle_rounded,
                                  label: 'Completed',
                                  value: _completedTasks.toString(),
                                  gradient: AppGradients.secondary,
                                ),
                                Container(
                                  width: 1.5,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        AppColors.grey.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                _buildStatItem(
                                  icon: Icons.list_alt_rounded,
                                  label: 'Total',
                                  value: _totalTasks.toString(),
                                  gradient: AppGradients.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Completion Rate',
                              style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return Column(
                                  children: [
                                    Container(
                                      height: 24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade200,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          children: [
                                            FractionallySizedBox(
                                              widthFactor: _progressAnimation.value,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: AppGradients.secondary,
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.cyan.withOpacity(0.4),
                                                      blurRadius: 8,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ShaderMask(
                                      shaderCallback: (bounds) => AppGradients.secondary.createShader(bounds),
                                      child: Text(
                                        '${(_progressAnimation.value * 100).toStringAsFixed(1)}%',
                                        style: AppTextStyles.heading1.copyWith(color: Colors.white),
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
                    const SizedBox(height: 28),

                    // Weekly Progress
                    SlideAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: _buildSectionHeader('Weekly Progress', Icons.calendar_view_week_rounded, AppGradients.sunset),
                    ),
                    const SizedBox(height: 16),
                    SlideAnimation(
                      delay: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppShadows.small,
                        ),
                        child: _buildWeeklyProgress(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Category Distribution
                    SlideAnimation(
                      delay: const Duration(milliseconds: 300),
                      child: _buildSectionHeader('Tasks by Category', Icons.pie_chart_rounded, AppGradients.aurora),
                    ),
                    const SizedBox(height: 16),
                    SlideAnimation(
                      delay: const Duration(milliseconds: 350),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppShadows.small,
                        ),
                        child: _buildCategoryChart(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Priority Distribution
                    SlideAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: _buildSectionHeader('Pending by Priority', Icons.flag_rounded, AppGradients.primary),
                    ),
                    const SizedBox(height: 16),
                    _buildPriorityDistribution(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Gradient gradient) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Text(title, style: AppTextStyles.heading3),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 28, color: Colors.white),
        ),
        const SizedBox(height: 12),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) {
            return ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(bounds),
              child: Text(
                val.toString(),
                style: AppTextStyles.heading1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.grey),
        ),
      ],
    );
  }
}