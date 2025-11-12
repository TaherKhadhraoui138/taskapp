import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../widgets/task_list_item.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'add_task_screen.dart';
import 'login_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import '../main.dart'; // Import pour accéder à textColor et primaryColor

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  String _currentFilter = 'All';
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      switch (filter) {
        case 'Today':
          final now = DateTime.now();
          _filteredTasks = _allTasks.where((task) {
            if (task.deadline == null) return false;
            return task.deadline!.year == now.year &&
                task.deadline!.month == now.month &&
                task.deadline!.day == now.day &&
                !task.isCompleted;
          }).toList();
          break;
        case 'Completed':
          _filteredTasks = _allTasks.where((task) => task.isCompleted).toList();
          break;
        case 'All':
        default:
          _filteredTasks = _allTasks;
          break;
      }
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(updatedTask.isCompleted ? 'Tâche complétée !' : 'Tâche réactivée.')),
    );
  }

  void _navigateToAddEditTask({Task? task}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(task: task),
      ),
    );
    if (result == true) {
      _loadTasks();
    }
  }

  Future<void> _deleteTask(Task task) async {
    await _taskService.deleteTask(task.id);
    _loadTasks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tâche "${task.title}" supprimée')),
      );
    }
  }

  void _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Widget _buildTaskScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0, bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${widget.user.name.split(' ').first}',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadTasks,
            child: _filteredTasks.isEmpty
                ? const Center(child: Text('Aucune tâche pour le moment.'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return TaskListItem(
                  key: ValueKey(task.id),
                  task: task,
                  onTap: () => _navigateToAddEditTask(task: task),
                  onToggle: () => _toggleTaskCompletion(task),
                  onDelete: () => _deleteTask(task),
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
          ? FloatingActionButton(
        onPressed: () => _navigateToAddEditTask(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
