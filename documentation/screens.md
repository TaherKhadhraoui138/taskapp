# Écrans de l'Application

## 1. SplashScreen - Écran de Démarrage

### Fichier: `lib/screens/splash_screen.dart`

Écran d'accueil animé avec vérification de l'authentification.

### Fonctionnalités
- Animation du logo avec effet élastique
- Animation du texte avec fondu et glissement
- Arrière-plan animé avec dégradé
- Animation de particules
- Vérification automatique de l'état d'authentification

### Animations

```dart
void _initAnimations() {
  // Animation du logo
  _logoController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  
  _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ),
  );
  
  _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
    CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ),
  );

  // Animation du texte
  _textController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  
  _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _textController, curve: Curves.easeIn),
  );
}
```

---

## 2. LoginScreen - Connexion

### Fichier: `lib/screens/login_screen.dart`

Écran de connexion avec animations sophistiquées.

### Fonctionnalités
- Formulaire de connexion (email/mot de passe)
- Validation des champs
- Animation d'arrière-plan avec dégradé rotatif
- Cercles décoratifs animés
- Navigation vers l'inscription

### Méthode de connexion

```dart
void _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    final user = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageTransitions.fadeScale(HomeScreen(user: user)),
        );
      }
    } else {
      if (mounted) {
        _showErrorSnackBar('Login failed. Please check your credentials.');
      }
    }
  }
}
```

---

## 3. RegisterScreen - Inscription

### Fichier: `lib/screens/register_screen.dart`

Écran d'inscription avec les mêmes animations que LoginScreen.

### Fonctionnalités
- Formulaire d'inscription (nom, email, mot de passe)
- Validation des champs
- Création de compte via AuthService

### Méthode d'inscription

```dart
void _register() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    final user = await _authService.register(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      Navigator.of(context).pushReplacement(
        PageTransitions.fadeScale(HomeScreen(user: user)),
      );
    } else {
      _showErrorSnackBar('Registration failed. This email may already be in use.');
    }
  }
}
```

---

## 4. HomeScreen - Écran Principal

### Fichier: `lib/screens/home_screen.dart`

Écran principal avec navigation par pages et gestion des tâches.

### Fonctionnalités
- PageView avec 4 pages (Home, Stats, Calendar, Profile)
- Barre de navigation personnalisée
- Recherche et filtrage des tâches
- Badge de notifications non lues
- FAB animé pour ajouter des tâches

### Méthodes principales

#### Charger les tâches

```dart
Future<void> _loadTasks() async {
  final tasks = await _taskService.loadTasks();
  setState(() {
    _allTasks = tasks;
    _filterTasks(_currentFilter);
  });
}
```

#### Filtrer les tâches

```dart
void _filterTasks(String filter) {
  setState(() {
    _currentFilter = filter;
    List<Task> filtered = _allTasks;

    // Filtre de recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(_searchQuery) ||
            task.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Filtre par catégorie
    if (_selectedCategory != null) {
      filtered = filtered.where((task) => 
          task.category == _selectedCategory).toList();
    }

    // Filtre par priorité
    if (_selectedPriority != null) {
      filtered = filtered.where((task) => 
          task.priority == _selectedPriority).toList();
    }

    // Filtre temporel
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
    }

    _filteredTasks = filtered;
    // Tri: non complétées d'abord, puis par date d'échéance
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
```

#### Basculer la complétion d'une tâche

```dart
void _toggleTaskCompletion(Task task) async {
  final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
  await _taskService.updateTask(updatedTask);

  // Envoyer une notification si la tâche est complétée
  if (updatedTask.isCompleted) {
    await _notificationService.sendTaskCompletedNotification(updatedTask);
    _loadUnreadNotificationsCount();
  }

  _loadTasks();
}
```

---

## 5. AddTaskScreen - Ajout/Modification de Tâche

### Fichier: `lib/screens/add_task_screen.dart`

Écran de création et d'édition de tâches avec onglets.

### Fonctionnalités
- Deux onglets : Informations de base et Sous-tâches
- Sélection de date et heure
- Choix de catégorie et priorité
- Gestion des tâches récurrentes
- Génération de sous-tâches par IA (Gemini)

### Génération de sous-tâches par IA

```dart
Future<void> _generateSubtasks() async {
  if (_title.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a title for the task first.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isGeneratingSubtasks = true;
  });

  try {
    final existingSubtasks = _subtasks.map((s) => s.title).join(', ');
    final prompt =
        'You are a sub-task suggestion assistant. Given a main task title, '
        'its detailed description, and a list of existing sub-tasks, '
        'suggest the next single, logical sub-task. '
        'Do not repeat any of the existing sub-tasks. '
        'Main task title: "$_title", '
        'Main task description: "$_description", '
        'Existing sub-tasks: [$existingSubtasks]. '
        'Return only the text of the new sub-task suggestion.';

    final response = await Gemini.instance.text(prompt);

    if (response != null && response.output != null) {
      final suggestion = response.output!.trim()
          .replaceAll(RegExp(r'^"|"| ^\*|\*$'), '').trim();
      if (suggestion.isNotEmpty) {
        setState(() {
          _subtasks.add(Subtask(title: suggestion));
        });
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to generate sub-tasks: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isGeneratingSubtasks = false;
    });
  }
}
```

### Sauvegarde de la tâche

```dart
void _saveTask() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final Task newTask = Task(
      id: widget.task?.id,
      title: _title,
      description: _description,
      deadline: _hasDeadline ? _deadline : null,
      category: _category,
      priority: _priority,
      isCompleted: widget.task?.isCompleted ?? false,
      subtasks: _subtasks,
      recurrenceType: _recurrenceType,
      recurrenceInterval: _recurrenceType == RecurrenceType.custom 
          ? _recurrenceInterval : null,
      recurrenceEndDate: _recurrenceType != RecurrenceType.none 
          ? _recurrenceEndDate : null,
    );

    if (widget.task == null) {
      await _taskService.addTask(newTask);
    } else {
      await _taskService.updateTask(newTask);
      await _notificationService.cancelScheduledNotification(newTask.id);
    }

    // Planifier la notification
    if (_hasDeadline && newTask.deadline != null) {
      await _notificationService.scheduleDeadlineNotification(newTask);
    }

    Navigator.of(context).pop(true);
  }
}
```

---

## 6. CalendarScreen - Calendrier

### Fichier: `lib/screens/calendar_screen.dart`

Vue calendrier des tâches avec leurs échéances.

### Fonctionnalités
- Navigation par jour
- Affichage des tâches du jour sélectionné
- Bouton "Aujourd'hui" pour revenir à la date actuelle
- Indicateurs visuels pour les jours avec des tâches

### Chargement des tâches par jour

```dart
Future<void> _loadTasks() async {
  final allTasks = await _taskService.loadTasks();
  final Map<DateTime, List<Task>> tasksByDay = {};

  for (var task in allTasks.where((t) => t.deadline != null)) {
    final day = DateTime(
        task.deadline!.year, 
        task.deadline!.month, 
        task.deadline!.day
    );
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
    _tasksForSelectedDay.sort((a, b) => 
        a.deadline!.compareTo(b.deadline!));
  });
}
```

---

## 7. StatsScreen - Statistiques

### Fichier: `lib/screens/stats_screen.dart`

Tableau de bord avec statistiques des tâches.

### Fonctionnalités
- Taux de complétion global
- Répartition par catégorie
- Répartition par priorité
- Animations des barres de progression

### Chargement des statistiques

```dart
Future<void> _loadStats() async {
  final tasks = await _taskService.loadTasks();
  final total = tasks.length;
  final completed = tasks.where((t) => t.isCompleted).length;
  final completionRate = total > 0 ? (completed / total) : 0.0;

  // Calcul par catégorie
  final Map<TaskCategory, int> categoryMap = {};
  for (var category in TaskCategory.values) {
    categoryMap[category] = tasks.where((t) => 
        t.category == category).length;
  }

  // Calcul par priorité (tâches non complétées)
  final Map<TaskPriority, int> priorityMap = {};
  for (var priority in TaskPriority.values) {
    priorityMap[priority] = tasks.where((t) => 
        t.priority == priority && !t.isCompleted).length;
  }

  setState(() {
    _allTasks = tasks;
    _totalTasks = total;
    _completedTasks = completed;
    _completionRate = completionRate;
    _tasksByCategory = categoryMap;
    _tasksByPriority = priorityMap;
  });

  // Animation de la barre de progression
  _progressAnimation = Tween<double>(begin: 0.0, end: completionRate).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
  );
  _animationController.forward(from: 0.0);
}
```

---

## 8. ProfileScreen - Profil

### Fichier: `lib/screens/profile_screen.dart`

Écran de profil utilisateur.

### Fonctionnalités
- Affichage de l'avatar et du nom
- Navigation vers l'édition du profil
- Navigation vers les paramètres
- Navigation vers À propos
- Déconnexion

### Déconnexion

```dart
void _logout(BuildContext context) async {
  await AuthService().logout();
  if (context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
```

---

## 9. EditProfileScreen - Édition du Profil

### Fichier: `lib/screens/edit_profile_screen.dart`

Écran de modification du profil.

### Fonctionnalités
- Modification du nom
- Changement de photo de profil (galerie)
- Sauvegarde via AuthService

---

## 10. SettingsScreen - Paramètres

### Fichier: `lib/screens/settings_screen.dart`

Écran des paramètres de l'application.

### Fonctionnalités
- Basculement thème clair/sombre
- Configuration du temps de rappel
- Activation/désactivation des notifications

### Sélecteur de temps de rappel

```dart
void _showReminderTimePicker(
    BuildContext context, 
    NotificationSettingsProvider settings) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        children: NotificationSettingsProvider.reminderOptions.map((minutes) {
          final isSelected = settings.reminderMinutes == minutes;
          return InkWell(
            onTap: () {
              settings.setReminderMinutes(minutes);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: isSelected ? AppGradients.ocean : null,
              ),
              child: Row(
                children: [
                  Icon(isSelected 
                      ? Icons.check_circle_rounded 
                      : Icons.circle_outlined),
                  const SizedBox(width: 16),
                  Text(NotificationSettingsProvider
                      .formatReminderTime(minutes)),
                ],
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}
```

---

## 11. NotificationsScreen - Notifications

### Fichier: `lib/screens/notifications_screen.dart`

Liste des notifications reçues.

### Fonctionnalités
- Liste des notifications avec état lu/non lu
- Marquer comme lu
- Supprimer une notification
- Supprimer toutes les notifications
- Pull-to-refresh

---

## 12. AboutScreen - À Propos

### Fichier: `lib/screens/about_screen.dart`

Informations sur l'application.

### Contenu
- Nom de l'application : TaskAI
- Version : 1.0.0
- Design avec arrière-plan décoratif

