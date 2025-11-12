import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/priority_filter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Priority _selectedPriority = Priority.all;
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Réunion équipe projet',
      description: 'Préparer la présentation pour le client',
      priority: Priority.high,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      category: 'Travail',
    ),
    Task(
      id: '2',
      title: 'Faire les courses',
      description: 'Acheter fruits et légumes',
      priority: Priority.medium,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      category: 'Personnel',
    ),
    Task(
      id: '3',
      title: 'Rapport trimestriel',
      description: 'Finaliser les chiffres de vente',
      priority: Priority.high,
      dueDate: DateTime.now().add(const Duration(hours: 5)),
      category: 'Travail',
    ),
  ];

  List<Task> get _filteredTasks {
    if (_selectedPriority == Priority.all) return _tasks;
    return _tasks.where((task) => task.priority == _selectedPriority).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, John 👋',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_filteredTasks.length} tâches aujourd\'hui',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Priority Filter
          PriorityFilter(
            selectedPriority: _selectedPriority,
            onPriorityChanged: (priority) {
              setState(() {
                _selectedPriority = priority;
              });
            },
          ),

          // Tasks List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return TaskCard(task: task);
              },
            ),
          ),
        ],
      ),
    );
  }
}