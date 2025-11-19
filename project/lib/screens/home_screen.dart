import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../widgets/task_list_item.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/empty_state_widget.dart';
import 'add_task_screen.dart';
import 'login_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  String _currentFilter = 'All';
  int _selectedIndex = 0;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${widget.user.name.split(' ').first}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Today's tasks",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(widget.user.profilePictureUrl),
                radius: 20,
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: (_selectedCategory != null || _selectedPriority != null)
                      ? primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: (_selectedCategory != null || _selectedPriority != null)
                        ? Colors.white
                        : textColor,
                  ),
                  onPressed: _showFilterBottomSheet,
                ),
              ),
            ],
          ),
        ),

        // Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Today', 'Completed'].map((filter) {
                final isSelected = _currentFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _filterTasks(filter);
                      }
                    },
                    backgroundColor: Colors.white,
                    selectedColor: primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Task List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadTasks,
            child: _filteredTasks.isEmpty
                ? EmptyStateWidget(
              message: _searchQuery.isNotEmpty
                  ? 'No tasks match your search'
                  : _currentFilter == 'Today'
                  ? 'No tasks for today'
                  : _currentFilter == 'Completed'
                  ? 'No completed tasks yet'
                  : 'No tasks yet',
              actionText: _searchQuery.isEmpty && _currentFilter == 'All' ? 'Add your first task' : null,
              onAction: _searchQuery.isEmpty && _currentFilter == 'All'
                  ? () => _navigateToAddEditTask()
                  : null,
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: TaskListItem(
                    key: ValueKey(task.id),
                    task: task,
                    onTap: () => _navigateToAddEditTask(task: task),
                    onToggle: () => _toggleTaskCompletion(task),
                    onDelete: () => _deleteTask(task),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
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
        child: FloatingActionButton(
          onPressed: () => _navigateToAddEditTask(),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
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