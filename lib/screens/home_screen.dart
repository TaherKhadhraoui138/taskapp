import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../widgets/task_list_item.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/empty_state_widget.dart';
import '../core/app_theme.dart';
import '../core/animated_widgets.dart';
import 'add_task_screen.dart';
import 'login_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import 'notifications_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  String _currentFilter = 'All';
  int _selectedIndex = 0;
  int _unreadNotificationsCount = 0;
  late PageController _pageController;
  bool _isSearching = false;
  String _searchQuery = '';
  TaskCategory? _selectedCategory;
  TaskPriority? _selectedPriority;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadUnreadNotificationsCount();
    _pageController = PageController(initialPage: _selectedIndex);
    _searchController.addListener(_onSearchChanged);


    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterTasks(_currentFilter);
    });
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskService.loadTasks();
    setState(() {
      _allTasks = tasks;
      _filterTasks(_currentFilter);
    });
  }

  Future<void> _loadUnreadNotificationsCount() async {
    final count = await _notificationService.getUnreadCount();
    setState(() {
      _unreadNotificationsCount = count;
    });
  }

  void _navigateToNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
    _loadUnreadNotificationsCount();
  }

  void _filterTasks(String filter) {
    setState(() {
      _currentFilter = filter;
      List<Task> filtered = _allTasks;

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((task) {
          return task.title.toLowerCase().contains(_searchQuery) ||
              task.description.toLowerCase().contains(_searchQuery);
        }).toList();
      }

      // Apply category filter
      if (_selectedCategory != null) {
        filtered = filtered.where((task) => task.category == _selectedCategory).toList();
      }

      // Apply priority filter
      if (_selectedPriority != null) {
        filtered = filtered.where((task) => task.priority == _selectedPriority).toList();
      }

      // Apply time filter
      switch (filter) {
        case 'Today':
          final now = DateTime.now();
          filtered = filtered.where((task) {
            if (task.deadline == null) return false;
            return task.deadline!.year == now.year &&
                task.deadline!.month == now.month &&
                task.deadline!.day == now.day &&
                !task.isCompleted;
          }).toList();
          break;
        case 'Completed':
          filtered = filtered.where((task) => task.isCompleted).toList();
          break;
        case 'All':
        default:
          break;
      }

      _filteredTasks = filtered;
      _filteredTasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        if (a.deadline == null && b.deadline != null) return 1;
        if (a.deadline != null && b.deadline == null) return -1;
        if (a.deadline == null && b.deadline == null) return 0;
        return a.deadline!.compareTo(b.deadline!);
      });
    });
  }

  void _toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _taskService.updateTask(updatedTask);

    // Send notification if task is completed
    if (updatedTask.isCompleted) {
      await _notificationService.sendTaskCompletedNotification(updatedTask);
      _loadUnreadNotificationsCount();
    }

    _loadTasks();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                updatedTask.isCompleted ? Icons.check_circle : Icons.refresh,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(updatedTask.isCompleted ? 'Task completed!' : 'Task reactivated.'),
            ],
          ),
          backgroundColor: updatedTask.isCompleted ? secondaryColor : primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _navigateToAddEditTask({Task? task}) async {
    _fabAnimationController.reverse();
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AddTaskScreen(task: task),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
    _fabAnimationController.forward();
    if (result == true) {
      _loadTasks();
    }
  }

  Future<void> _deleteTask(Task task) async {
    await _taskService.deleteTask(task.id);
    _loadTasks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.delete, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Task "${task.title}" deleted')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Tasks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setModalState(() => _selectedCategory = null);
                          setState(() => _selectedCategory = null);
                          _filterTasks(_currentFilter);
                        },
                      ),
                      ...TaskCategory.values.map((category) {
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(category.icon, size: 16),
                              const SizedBox(width: 4),
                              Text(category.toString().split('.').last),
                            ],
                          ),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setModalState(() => _selectedCategory = selected ? category : null);
                            setState(() => _selectedCategory = selected ? category : null);
                            _filterTasks(_currentFilter);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedPriority == null,
                        onSelected: (selected) {
                          setModalState(() => _selectedPriority = null);
                          setState(() => _selectedPriority = null);
                          _filterTasks(_currentFilter);
                        },
                      ),
                      ...TaskPriority.values.map((priority) {
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: priority.color,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(priority.toString().split('.').last),
                            ],
                          ),
                          selected: _selectedPriority == priority,
                          onSelected: (selected) {
                            setModalState(() => _selectedPriority = selected ? priority : null);
                            setState(() => _selectedPriority = selected ? priority : null);
                            _filterTasks(_currentFilter);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedCount = _allTasks.where((t) => t.isCompleted).length;
    final totalTasks = _allTasks.length;
    final progress = totalTasks > 0 ? completedCount / totalTasks : 0.0;
    
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.backgroundDark : AppGradients.backgroundLight,
      ),
      child: RefreshIndicator(
        onRefresh: _loadTasks,
        color: AppColors.primaryStart,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // Animated Header with gradient
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryStart.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${widget.user.name.split(' ').first} 👋',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Notification button with badge
                            GestureDetector(
                              onTap: _navigateToNotifications,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    if (_unreadNotificationsCount > 0)
                                      Positioned(
                                        right: -6,
                                        top: -6,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            _unreadNotificationsCount > 9
                                                ? '9+'
                                                : _unreadNotificationsCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _onItemTapped(3),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(widget.user.profilePictureUrl),
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Progress Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Circular progress
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: Stack(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: progress),
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 6,
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    );
                                  },
                                ),
                                Center(
                                  child: Text(
                                    '${(progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Progress',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$completedCount of $totalTasks tasks completed',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$totalTasks Tasks',
                              style: TextStyle(
                                color: AppColors.primaryStart,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            
            // Search Bar with glass effect
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.small,
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search tasks...',
                            hintStyle: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: AppColors.primaryStart,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedScaleTap(
                      onTap: _showFilterBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: (_selectedCategory != null || _selectedPriority != null)
                              ? AppGradients.primary
                              : null,
                          color: (_selectedCategory != null || _selectedPriority != null)
                              ? null
                              : (isDark ? AppColors.cardDark : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.small,
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: (_selectedCategory != null || _selectedPriority != null)
                              ? Colors.white
                              : AppColors.primaryStart,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Filter Chips with animation
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: ['All', 'Today', 'Completed'].asMap().entries.map((entry) {
                      final index = entry.key;
                      final filter = entry.value;
                      final isSelected = _currentFilter == filter;
                      final icons = [Icons.list_alt_rounded, Icons.today_rounded, Icons.check_circle_rounded];
                      
                      return Padding(
                        padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                        child: AnimatedScaleTap(
                          onTap: () => _filterTasks(filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppGradients.primary : null,
                              color: isSelected ? null : (isDark ? AppColors.cardDark : Colors.white),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryStart.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : AppShadows.small,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  icons[index],
                                  size: 18,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentFilter == 'All'
                          ? 'All Tasks'
                          : _currentFilter == 'Today'
                              ? "Today's Tasks"
                              : 'Completed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryStart.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_filteredTasks.length} tasks',
                        style: TextStyle(
                          color: AppColors.primaryStart,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Task List
            _filteredTasks.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      message: _searchQuery.isNotEmpty
                          ? 'No tasks match your search'
                          : _currentFilter == 'Today'
                              ? 'No tasks for today'
                              : _currentFilter == 'Completed'
                                  ? 'No completed tasks yet'
                                  : 'No tasks yet',
                      actionText: _searchQuery.isEmpty && _currentFilter == 'All' 
                          ? 'Add your first task' 
                          : null,
                      onAction: _searchQuery.isEmpty && _currentFilter == 'All'
                          ? () => _navigateToAddEditTask()
                          : null,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = _filteredTasks[index];
                          return StaggeredListItem(
                            index: index,
                            child: TaskListItem(
                              key: ValueKey(task.id),
                              task: task,
                              onTap: () => _navigateToAddEditTask(task: task),
                              onToggle: () => _toggleTaskCompletion(task),
                              onDelete: () => _deleteTask(task),
                            ),
                          );
                        },
                        childCount: _filteredTasks.length,
                      ),
                    ),
                  ),
            
            // Bottom padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning! Ready to be productive?';
    } else if (hour < 17) {
      return 'Good afternoon! Keep up the great work!';
    } else {
      return 'Good evening! Finishing strong today?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildTaskScreen(),
          const StatsScreen(),
          const CalendarScreen(),
          ProfileScreen(user: widget.user),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? ScaleTransition(
              scale: _fabAnimation,
              child: AnimatedScaleTap(
                onTap: () => _navigateToAddEditTask(),
                scaleValue: 0.9,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryStart.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
              ),
            )
          : null,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}