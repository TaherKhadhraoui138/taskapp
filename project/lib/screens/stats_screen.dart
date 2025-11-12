import 'package:flutter/material.dart';
import '../services/task_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final TaskService _taskService = TaskService();
  int _totalTasks = 0;
  int _completedTasks = 0;
  double _completionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final tasks = await _taskService.loadTasks();
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;

    setState(() {
      _totalTasks = total;
      _completedTasks = completed;
      _completionRate = total > 0 ? (completed / total) : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
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
              const Text(
                'Aperçu de la Productivité',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.playlist_add_check, color: Colors.green),
                        title: const Text('Tâches Complétées'),
                        trailing: Text(
                          '$_completedTasks',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.list, color: Colors.blue),
                        title: const Text('Tâches Totales'),
                        trailing: Text(
                          '$_totalTasks',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Taux de Complétion',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _completionRate,
                  minHeight: 20,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '${(_completionRate * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
