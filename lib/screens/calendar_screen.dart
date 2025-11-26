import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/task_list_item.dart';
import '../main.dart'; // Import pour accéder à primaryColor

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Sélecteur de date simple
          Container(
            color: primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () {
                    _updateTasksForSelectedDay(_selectedDay.subtract(const Duration(days: 1)));
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDay,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null && picked != _selectedDay) {
                      _updateTasksForSelectedDay(picked);
                    }
                  },
                  child: Text(
                    DateFormat('EEEE, d MMMM yyyy', 'fr').format(_selectedDay),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () {
                    _updateTasksForSelectedDay(_selectedDay.add(const Duration(days: 1)));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTasks,
              child: _tasksForSelectedDay.isEmpty
                  ? Center(child: Text('Aucune tâche prévue pour le ${DateFormat('d MMMM', 'fr').format(_selectedDay)}.'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: _tasksForSelectedDay.length,
                itemBuilder: (context, index) {
                  final task = _tasksForSelectedDay[index];
                  return TaskListItem(
                    key: ValueKey(task.id),
                    task: task,
                    onTap: () {
                      // Logique de navigation vers l'édition de tâche
                    },
                    onToggle: () => _toggleTaskCompletion(task),
                    onDelete: () => _deleteTask(task),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
