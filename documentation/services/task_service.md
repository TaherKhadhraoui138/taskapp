# TaskService - Service de Gestion des Tâches

## Fichier: `lib/services/task_service.dart`

Service CRUD (Create, Read, Update, Delete) pour les tâches stockées dans Cloud Firestore.

---

## Dépendances

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
```

---

## Initialisation

```dart
class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer l'ID de l'utilisateur connecté
  String? get _currentUserId => _auth.currentUser?.uid;
}
```

---

## Structure Firestore

```
firestore/
└── users/
    └── {userId}/
        └── tasks/
            └── {taskId}/
                ├── id: string
                ├── title: string
                ├── description: string
                ├── deadline: timestamp (nullable)
                ├── category: string (work|personal|study|other)
                ├── priority: string (high|medium|low)
                ├── isCompleted: boolean
                ├── createdAt: timestamp
                ├── subtasks: array
                │   └── [{id, title, isCompleted}, ...]
                ├── recurrenceType: string
                ├── recurrenceInterval: number (nullable)
                └── recurrenceEndDate: timestamp (nullable)
```

---

## Méthodes

### 1. loadTasks() - Charger toutes les tâches

Récupère toutes les tâches de l'utilisateur, triées par date de création (plus récentes en premier).

```dart
Future<List<Task>> loadTasks() async {
  // Vérifier que l'utilisateur est connecté
  if (_currentUserId == null) return [];

  // Requête Firestore avec tri
  final snapshot = await _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('tasks')
      .orderBy('createdAt', descending: true)
      .get();

  // Convertir les documents en objets Task
  return snapshot.docs
      .map((doc) => Task.fromJson(doc.data()))
      .toList();
}
```

**Utilisation:**
```dart
final taskService = TaskService();
final tasks = await taskService.loadTasks();

// Filtrer les tâches complétées
final completedTasks = tasks.where((t) => t.isCompleted).toList();

// Filtrer les tâches d'aujourd'hui
final today = DateTime.now();
final todayTasks = tasks.where((t) {
  if (t.deadline == null) return false;
  return t.deadline!.year == today.year &&
         t.deadline!.month == today.month &&
         t.deadline!.day == today.day;
}).toList();
```

---

### 2. addTask() - Ajouter une tâche

Crée une nouvelle tâche dans Firestore.

```dart
Future<void> addTask(Task task) async {
  if (_currentUserId == null) return;

  await _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('tasks')
      .doc(task.id)  // Utilise l'ID généré par le modèle
      .set(task.toJson());
}
```

**Exemple d'utilisation:**
```dart
final newTask = Task(
  title: 'Faire les courses',
  description: 'Acheter du lait, pain, œufs',
  deadline: DateTime.now().add(Duration(hours: 2)),
  category: TaskCategory.personal,
  priority: TaskPriority.medium,
  subtasks: [
    Subtask(title: 'Lait'),
    Subtask(title: 'Pain'),
    Subtask(title: 'Œufs'),
  ],
);

await taskService.addTask(newTask);
```

---

### 3. updateTask() - Mettre à jour une tâche

Met à jour une tâche existante avec de nouvelles données.

```dart
Future<void> updateTask(Task updatedTask) async {
  if (_currentUserId == null) return;

  await _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('tasks')
      .doc(updatedTask.id)
      .update(updatedTask.toJson());
}
```

**Exemple - Modifier le titre:**
```dart
final updatedTask = existingTask.copyWith(
  title: 'Nouveau titre',
  description: 'Nouvelle description',
);

await taskService.updateTask(updatedTask);
```

**Exemple - Compléter une sous-tâche:**
```dart
final updatedSubtasks = task.subtasks.map((s) {
  if (s.id == subtaskId) {
    return s.copyWith(isCompleted: true);
  }
  return s;
}).toList();

final updatedTask = task.copyWith(subtasks: updatedSubtasks);
await taskService.updateTask(updatedTask);
```

---

### 4. deleteTask() - Supprimer une tâche

Supprime définitivement une tâche de Firestore.

```dart
Future<void> deleteTask(String taskId) async {
  if (_currentUserId == null) return;

  await _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('tasks')
      .doc(taskId)
      .delete();
}
```

**Utilisation avec confirmation:**
```dart
void _confirmDeleteTask(Task task) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Task'),
      content: Text('Are you sure you want to delete "${task.title}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await taskService.deleteTask(task.id);
            Navigator.pop(context);
            _loadTasks(); // Recharger la liste
          },
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
```

---

### 5. toggleTaskCompletion() - Basculer l'état de complétion

Marque une tâche comme complétée ou non complétée.

```dart
Future<void> toggleTaskCompletion(Task task) async {
  if (_currentUserId == null) return;

  await _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('tasks')
      .doc(task.id)
      .update({'isCompleted': !task.isCompleted});
}
```

**Utilisation avec notification:**
```dart
Future<void> _toggleTaskCompletion(Task task) async {
  await taskService.toggleTaskCompletion(task);
  
  // Envoyer une notification si la tâche est complétée
  if (!task.isCompleted) {
    await NotificationService().sendTaskCompletedNotification(task);
  }
  
  // Recharger la liste
  _loadTasks();
  
  // Afficher un message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        task.isCompleted 
            ? 'Task marked as incomplete' 
            : 'Task completed! 🎉'
      ),
    ),
  );
}
```

---

## Requêtes Avancées

### Filtrer par catégorie

```dart
Future<List<Task>> getTasksByCategory(TaskCategory category) async {
  if (_currentUserId == null) return [];

  final snapshot = await _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('tasks')
      .where('category', isEqualTo: category.toString().split('.').last)
      .get();

  return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
}
```

### Tâches non complétées avec deadline proche

```dart
Future<List<Task>> getUpcomingTasks() async {
  if (_currentUserId == null) return [];

  final now = DateTime.now();
  final tomorrow = now.add(Duration(days: 1));

  final snapshot = await _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('tasks')
      .where('isCompleted', isEqualTo: false)
      .where('deadline', isGreaterThan: now.toIso8601String())
      .where('deadline', isLessThan: tomorrow.toIso8601String())
      .get();

  return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
}
```

---

## Diagramme de Flux

```
┌─────────────────────────────────────────────────┐
│                   HomeScreen                     │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│                  TaskService                     │
├─────────────────────────────────────────────────┤
│  loadTasks()        ──► Liste des tâches        │
│  addTask(task)      ──► Création                │
│  updateTask(task)   ──► Modification            │
│  deleteTask(id)     ──► Suppression             │
│  toggleCompletion() ──► Toggle état             │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│              Cloud Firestore                     │
├─────────────────────────────────────────────────┤
│  /users/{userId}/tasks/{taskId}                 │
│                                                  │
│  Opérations:                                     │
│  - get()    : Lecture                           │
│  - set()    : Création                          │
│  - update() : Modification                      │
│  - delete() : Suppression                       │
└─────────────────────────────────────────────────┘
```

---

## Gestion des Erreurs

```dart
Future<List<Task>> loadTasks() async {
  if (_currentUserId == null) return [];

  try {
    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Task.fromJson(doc.data()))
        .toList();
  } on FirebaseException catch (e) {
    print('Firebase error: ${e.message}');
    return [];
  } catch (e) {
    print('Unknown error: $e');
    return [];
  }
}
```

---

## Bonnes Pratiques

1. **Toujours vérifier `_currentUserId`** avant les opérations
2. **Utiliser `copyWith()`** pour modifier les tâches (immutabilité)
3. **Recharger la liste** après chaque modification
4. **Gérer les erreurs** avec try-catch
5. **Utiliser des index Firestore** pour les requêtes complexes

