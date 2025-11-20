import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  static const String _appName = 'TaskAI';
  static const String _version = '1.0.0';
  static const String _description =
      'TaskAI is a Flutter mobile application for managing user tasks with the help of artificial intelligence capable of automatically classifying tasks by priority and offering smart reminders.\n\n'
      'Project Goals:\n'
      '• Create an ergonomic and fast mobile application\n'
      '• Allow users to manage their tasks efficiently\n'
      '• Integrate a simple AI engine (NLP) to analyze tasks and deduce their priority level\n'
      '• Synchronize data via Firebase for backup and authentication';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.apps, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(_appName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('Version $_version', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            Text(
              _description,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
