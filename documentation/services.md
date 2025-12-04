# Services

Vue d'ensemble des services de l'application TaskAI.

## Documentation Détaillée

- [AuthService - Authentification](./services/auth_service.md)
- [TaskService - Gestion des Tâches](./services/task_service.md)
- [NotificationService - Notifications](./services/notification_service.md)

---

## 1. AuthService - Authentification

### Fichier: `lib/services/auth_service.dart`

Service gérant l'authentification avec Firebase Auth et la gestion des profils utilisateurs.

### Méthodes Principales

| Méthode | Description | Retour |
|---------|-------------|--------|
| `register(email, password, name)` | Inscription | `User?` |
| `login(email, password)` | Connexion | `User?` |
| `logout()` | Déconnexion | `void` |
| `getCurrentUser()` | Utilisateur actuel | `User?` |
| `updateUserProfile(...)` | Mise à jour profil | `User?` |

[📖 Documentation complète](./services/auth_service.md)

---

## 2. TaskService - Gestion des Tâches

### Fichier: `lib/services/task_service.dart`

Service CRUD pour les tâches stockées dans Firestore.

### Méthodes Principales

| Méthode | Description | Retour |
|---------|-------------|--------|
| `loadTasks()` | Charger toutes les tâches | `List<Task>` |
| `addTask(task)` | Ajouter une tâche | `void` |
| `updateTask(task)` | Mettre à jour | `void` |
| `deleteTask(taskId)` | Supprimer | `void` |
| `toggleTaskCompletion(task)` | Basculer état | `void` |

[📖 Documentation complète](./services/task_service.md)

---

## 3. NotificationService - Notifications

### Fichier: `lib/services/notification_service.dart`

Service Singleton gérant les notifications locales et leur stockage dans Firestore.

### Caractéristiques

- **Pattern Singleton** : Une seule instance dans l'app
- **Vérification périodique** : Toutes les minutes
- **Notifications programmées** : Support des timezones
- **Stockage Firestore** : Historique des notifications

### Méthodes Principales

| Méthode | Description |
|---------|-------------|
| `initialize()` | Initialisation du service |
| `sendTaskCompletedNotification(task)` | Notification de complétion |
| `scheduleDeadlineNotification(task)` | Programmer un rappel |
| `getNotifications()` | Liste des notifications |
| `getUnreadCount()` | Nombre de non lues |
| `markAsRead(id)` | Marquer comme lue |
| `deleteNotification(id)` | Supprimer |

### Types de Notifications

| Type | Icône | Déclencheur |
|------|-------|-------------|
| Deadline | ⏰ | X minutes avant deadline |
| Overdue | 🚨 | Deadline passée |
| Completed | ✅ | Tâche terminée |

[📖 Documentation complète](./services/notification_service.md)

---

## Architecture des Services

```
┌─────────────────────────────────────────────────────────┐
│                        UI Layer                          │
│  (SplashScreen, LoginScreen, HomeScreen, etc.)          │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    Service Layer                         │
├───────────────┬───────────────┬─────────────────────────┤
│  AuthService  │  TaskService  │  NotificationService    │
│               │               │                          │
│ - register()  │ - loadTasks() │ - initialize()          │
│ - login()     │ - addTask()   │ - sendNotification()    │
│ - logout()    │ - updateTask()│ - scheduleNotification()│
│ - getUser()   │ - deleteTask()│ - getNotifications()    │
└───────┬───────┴───────┬───────┴───────────┬─────────────┘
        │               │                   │
        ▼               ▼                   ▼
┌───────────────────────────────────────────────────────┐
│                    Data Layer                          │
├─────────────────┬─────────────────┬───────────────────┤
│  Firebase Auth  │ Cloud Firestore │ Local Notifications│
│                 │                 │ SharedPreferences  │
│  - Sessions     │ - /users        │                    │
│  - Tokens       │ - /tasks        │                    │
│                 │ - /notifications│                    │
└─────────────────┴─────────────────┴───────────────────┘
```

---

## Utilisation dans main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialiser les notifications
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
      ],
      child: const TaskManagerApp(),
    ),
  );
}
```
