# Modèles de Données

## 1. Task - Modèle de Tâche

### Fichier: `lib/models/task.dart`

Modèle représentant une tâche avec toutes ses propriétés et métadonnées.

### Énumérations

```dart
// Catégories de tâches
enum TaskCategory { work, personal, study, other }

// Niveaux de priorité
enum TaskPriority { high, medium, low }

// Types de récurrence
enum RecurrenceType { none, daily, weekly, monthly, custom }
```

### Extensions des Énumérations

#### TaskCategory

```dart
extension TaskCategoryExtension on TaskCategory {
  IconData get icon {
    switch (this) {
      case TaskCategory.work:
        return Icons.work_rounded;
      case TaskCategory.personal:
        return Icons.person_rounded;
      case TaskCategory.study:
        return Icons.school_rounded;
      case TaskCategory.other:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.work:
        return AppColors.categoryWork;
      case TaskCategory.personal:
        return AppColors.categoryPersonal;
      case TaskCategory.study:
        return AppColors.categoryStudy;
      case TaskCategory.other:
        return AppColors.categoryOther;
    }
  }
}
```

#### TaskPriority

```dart
extension TaskPriorityExtension on TaskPriority {
  Color get color {
    switch (this) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  Gradient get gradient {
    switch (this) {
      case TaskPriority.high:
        return AppGradients.priorityHigh;
      case TaskPriority.medium:
        return AppGradients.priorityMedium;
      case TaskPriority.low:
        return AppGradients.priorityLow;
    }
  }
}
```

---

### Classe Subtask (Sous-tâche)

```dart
class Subtask {
  final String id;           // Identifiant unique auto-généré
  final String title;        // Titre de la sous-tâche
  final bool isCompleted;    // État de complétion

  Subtask({
    String? id,
    required this.title,
    this.isCompleted = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}
```

#### Méthodes Subtask

| Méthode | Description |
|---------|-------------|
| `copyWith()` | Crée une copie avec des modifications |
| `toJson()` | Convertit en Map pour Firestore |
| `fromJson()` | Factory pour créer depuis un Map |

---

### Classe Task (Tâche)

```dart
class Task {
  final String id;                  // Identifiant unique
  final String title;               // Titre de la tâche
  final String description;         // Description (optionnelle)
  final DateTime? deadline;         // Date limite
  final TaskCategory category;      // Catégorie
  final TaskPriority priority;      // Priorité
  final bool isCompleted;           // État de complétion
  final DateTime createdAt;         // Date de création
  final List<Subtask> subtasks;     // Liste des sous-tâches
  final RecurrenceType recurrenceType;     // Type de récurrence
  final int? recurrenceInterval;           // Intervalle personnalisé
  final DateTime? recurrenceEndDate;       // Date de fin de récurrence
}
```

#### Constructeur

```dart
Task({
  String? id,
  required this.title,
  this.description = '',
  this.deadline,
  this.category = TaskCategory.other,
  this.priority = TaskPriority.medium,
  this.isCompleted = false,
  DateTime? createdAt,
  List<Subtask>? subtasks,
  this.recurrenceType = RecurrenceType.none,
  this.recurrenceInterval,
  this.recurrenceEndDate,
})  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt = createdAt ?? DateTime.now(),
      subtasks = subtasks ?? [];
```

#### Méthodes Task

| Méthode | Description |
|---------|-------------|
| `copyWith()` | Crée une copie modifiée |
| `toJson()` | Convertit en Map pour Firestore |
| `fromJson()` | Factory depuis Map Firestore |
| `completionPercentage` | Getter - % de sous-tâches complétées |
| `getNextOccurrence()` | Calcule la prochaine occurrence |

#### toJson() - Sérialisation

```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'title': title,
    'description': description,
    'deadline': deadline?.toIso8601String(),
    'category': category.toString().split('.').last,
    'priority': priority.toString().split('.').last,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
    'recurrenceType': recurrenceType.toString().split('.').last,
    'recurrenceInterval': recurrenceInterval,
    'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
  };
}
```

#### fromJson() - Désérialisation

```dart
factory Task.fromJson(Map<String, dynamic> json) {
  return Task(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    deadline: json['deadline'] != null 
        ? DateTime.parse(json['deadline']) 
        : null,
    category: TaskCategory.values.firstWhere(
      (e) => e.toString().split('.').last == json['category'],
      orElse: () => TaskCategory.other,
    ),
    priority: TaskPriority.values.firstWhere(
      (e) => e.toString().split('.').last == json['priority'],
      orElse: () => TaskPriority.medium,
    ),
    isCompleted: json['isCompleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    subtasks: (json['subtasks'] as List<dynamic>?)
        ?.map((s) => Subtask.fromJson(s))
        .toList() ?? [],
    recurrenceType: RecurrenceType.values.firstWhere(
      (e) => e.toString().split('.').last == json['recurrenceType'],
      orElse: () => RecurrenceType.none,
    ),
    recurrenceInterval: json['recurrenceInterval'],
    recurrenceEndDate: json['recurrenceEndDate'] != null
        ? DateTime.parse(json['recurrenceEndDate'])
        : null,
  );
}
```

#### completionPercentage - Calcul du pourcentage

```dart
double get completionPercentage {
  if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
  final completed = subtasks.where((s) => s.isCompleted).length;
  return completed / subtasks.length;
}
```

#### getNextOccurrence() - Prochaine occurrence

```dart
DateTime? getNextOccurrence() {
  if (recurrenceType == RecurrenceType.none || deadline == null) {
    return null;
  }

  DateTime next = deadline!;
  final now = DateTime.now();

  while (next.isBefore(now)) {
    switch (recurrenceType) {
      case RecurrenceType.daily:
        next = next.add(const Duration(days: 1));
        break;
      case RecurrenceType.weekly:
        next = next.add(const Duration(days: 7));
        break;
      case RecurrenceType.monthly:
        next = DateTime(next.year, next.month + 1, next.day,
            next.hour, next.minute);
        break;
      case RecurrenceType.custom:
        if (recurrenceInterval != null) {
          next = next.add(Duration(days: recurrenceInterval!));
        }
        break;
      default:
        return null;
    }
  }

  // Vérifier si la date de fin est dépassée
  if (recurrenceEndDate != null && next.isAfter(recurrenceEndDate!)) {
    return null;
  }

  return next;
}
```

---

## 2. User - Modèle Utilisateur

### Fichier: `lib/models/user.dart`

Modèle représentant un utilisateur de l'application.

```dart
class User {
  final String id;                  // ID Firebase Auth
  final String email;               // Adresse email
  final String name;                // Nom complet
  final String profilePictureUrl;   // URL de la photo (data URL ou URL)
  final String? passwordHash;       // Hash du mot de passe (optionnel)

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePictureUrl = 'data:image/png;base64,...', // Image par défaut
    this.passwordHash,
  });
}
```

#### Méthodes User

| Méthode | Description |
|---------|-------------|
| `fromJson()` | Factory depuis Map Firestore |
| `toJson()` | Convertit en Map pour Firestore |

```dart
factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    profilePictureUrl: json['profilePictureUrl'] ?? defaultProfilePicture,
    passwordHash: json['passwordHash'],
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'email': email,
    'name': name,
    'profilePictureUrl': profilePictureUrl,
    'passwordHash': passwordHash,
  };
}
```

---

## 3. AppNotification - Modèle de Notification

### Fichier: `lib/models/app_notification.dart`

Modèle représentant une notification de l'application.

### Énumération

```dart
enum NotificationType {
  deadline,   // Rappel de deadline proche
  completed,  // Tâche terminée
  reminder,   // Rappel général
}
```

### Classe AppNotification

```dart
class AppNotification {
  final String id;              // Identifiant unique
  final String taskId;          // ID de la tâche associée
  final String taskTitle;       // Titre de la tâche
  final String message;         // Message de notification
  final NotificationType type;  // Type de notification
  final DateTime createdAt;     // Date de création
  final bool isRead;            // État lu/non lu

  AppNotification({
    String? id,
    required this.taskId,
    required this.taskTitle,
    required this.message,
    required this.type,
    DateTime? createdAt,
    this.isRead = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();
}
```

#### Méthodes

```dart
// Créer une copie modifiée
AppNotification copyWith({
  String? id,
  String? taskId,
  String? taskTitle,
  String? message,
  NotificationType? type,
  DateTime? createdAt,
  bool? isRead,
}) {
  return AppNotification(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    taskTitle: taskTitle ?? this.taskTitle,
    message: message ?? this.message,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
    isRead: isRead ?? this.isRead,
  );
}

// Convertir en Map pour Firestore
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'taskId': taskId,
    'taskTitle': taskTitle,
    'message': message,
    'type': type.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };
}

// Factory depuis Map Firestore
factory AppNotification.fromJson(Map<String, dynamic> json) {
  return AppNotification(
    id: json['id'],
    taskId: json['taskId'],
    taskTitle: json['taskTitle'],
    message: json['message'],
    type: NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'],
      orElse: () => NotificationType.reminder,
    ),
    createdAt: DateTime.parse(json['createdAt']),
    isRead: json['isRead'] ?? false,
  );
}
```

---

## Structure Firestore

```
firestore/
└── users/
    └── {userId}/
        ├── email: string
        ├── name: string
        ├── profilePictureUrl: string
        ├── passwordHash: string?
        │
        ├── tasks/
        │   └── {taskId}/
        │       ├── id: string
        │       ├── title: string
        │       ├── description: string
        │       ├── deadline: timestamp?
        │       ├── category: string
        │       ├── priority: string
        │       ├── isCompleted: boolean
        │       ├── createdAt: timestamp
        │       ├── subtasks: array
        │       ├── recurrenceType: string
        │       ├── recurrenceInterval: number?
        │       └── recurrenceEndDate: timestamp?
        │
        └── notifications/
            └── {notificationId}/
                ├── id: string
                ├── taskId: string
                ├── taskTitle: string
                ├── message: string
                ├── type: string
                ├── createdAt: timestamp
                └── isRead: boolean
```

