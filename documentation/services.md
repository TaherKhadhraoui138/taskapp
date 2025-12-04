# Services

## 1. AuthService - Authentification

### Fichier: `lib/services/auth_service.dart`

Service gérant l'authentification avec Firebase Auth et la gestion des profils utilisateurs.

### Dépendances

```dart
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
```

### Méthodes

#### register() - Inscription

```dart
Future<User?> register(String email, String password, String name) async {
  try {
    final fb_auth.UserCredential userCredential = 
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final newUser = User(
      id: userCredential.user!.uid,
      email: email,
      name: name,
      passwordHash: myCustomHash(password)
    );

    await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
    return newUser;
  } on fb_auth.FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      print('Erreur: Cet email existe déjà !');
    }
    return null;
  }
}
```

#### login() - Connexion

```dart
Future<User?> login(String email, String password) async {
  try {
    final fb_auth.UserCredential userCredential = 
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (doc.exists) {
      return User.fromJson(doc.data()!);
    }
    return null;
  } catch (e) {
    print('Login error: $e');
    return null;
  }
}
```

#### getCurrentUser() - Récupérer l'utilisateur actuel

```dart
Future<User?> getCurrentUser() async {
  fb_auth.User? fbUser = _auth.currentUser;
  
  // Attendre que Firebase Auth restaure l'état
  if (fbUser == null) {
    await Future.delayed(const Duration(milliseconds: 500));
    fbUser = _auth.currentUser;
  }
  
  // Écouter les changements d'état si toujours null
  if (fbUser == null) {
    try {
      await for (final user in _auth.authStateChanges().take(1).timeout(
        const Duration(seconds: 3),
        onTimeout: (sink) => sink.close(),
      )) {
        fbUser = user;
        break;
      }
    } catch (e) {
      print('Auth state check error: $e');
    }
  }

  if (fbUser == null) return null;

  final doc = await _firestore.collection('users').doc(fbUser.uid).get();
  if (doc.exists) return User.fromJson(doc.data()!);
  return null;
}
```

#### logout() - Déconnexion

```dart
Future<void> logout() async {
  await _auth.signOut();
}
```

#### updateUserProfile() - Mettre à jour le profil

```dart
Future<User?> updateUserProfile({
  required String userId,
  String? name,
  Uint8List? imageBytes,
  String? imageExtension,
}) async {
  Map<String, dynamic> updates = {};

  if (name != null && name.isNotEmpty) {
    updates['name'] = name;
  }

  if (imageBytes != null && imageExtension != null) {
    // Convertir l'image en base64 data URL
    final base64Image = base64Encode(imageBytes);
    final mimeType = imageExtension == 'png' ? 'image/png' : 'image/jpeg';
    updates['profilePictureUrl'] = 'data:$mimeType;base64,$base64Image';
  }

  if (updates.isNotEmpty) {
    await _firestore.collection('users').doc(userId).update(updates);
  }

  final doc = await _firestore.collection('users').doc(userId).get();
  if (doc.exists) {
    return User.fromJson(doc.data()!);
  }
  return null;
}
```

#### myCustomHash() - Hachage du mot de passe

```dart
String myCustomHash(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}
```

---

## 2. TaskService - Gestion des Tâches

### Fichier: `lib/services/task_service.dart`

Service CRUD pour les tâches stockées dans Firestore.

### Méthodes

#### loadTasks() - Charger les tâches

```dart
Future<List<Task>> loadTasks() async {
  if (_currentUserId == null) return [];

  final snapshot = await _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('tasks')
      .orderBy('createdAt', descending: true)
      .get();

  return snapshot.docs
      .map((doc) => Task.fromJson(doc.data()))
      .toList();
}
```

#### addTask() - Ajouter une tâche

```dart
Future<void> addTask(Task task) async {
  if (_currentUserId == null) return;

  await _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('tasks')
      .doc(task.id)
      .set(task.toJson());
}
```

#### updateTask() - Mettre à jour une tâche

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

#### deleteTask() - Supprimer une tâche

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

#### toggleTaskCompletion() - Basculer l'état de complétion

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

---

## 3. NotificationService - Notifications

### Fichier: `lib/services/notification_service.dart`

Service Singleton gérant les notifications locales et leur stockage dans Firestore.

### Initialisation

```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
}
```

#### initialize() - Initialisation

```dart
Future<void> initialize() async {
  if (_isInitialized) return;

  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  await _flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _onNotificationTapped,
  );

  await _requestPermissions();
  _isInitialized = true;
  _startPeriodicCheck();
}
```

#### _checkTaskDeadlines() - Vérifier les échéances

```dart
Future<void> _checkTaskDeadlines() async {
  if (_currentUserId == null) return;

  final notificationsEnabled = await _areNotificationsEnabled();
  if (!notificationsEnabled) return;

  final reminderMinutes = await _getReminderMinutes();

  final snapshot = await _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('tasks')
      .where('isCompleted', isEqualTo: false)
      .get();

  final now = DateTime.now();

  for (final doc in snapshot.docs) {
    final task = Task.fromJson(doc.data());

    if (task.deadline != null && !task.isCompleted) {
      final timeUntilDeadline = task.deadline!.difference(now);

      // Notification si échéance proche
      if (timeUntilDeadline.inMinutes <= reminderMinutes && 
          timeUntilDeadline.inMinutes > 0) {
        await _sendDeadlineNotification(task, timeUntilDeadline.inMinutes);
      }

      // Notification si échéance dépassée
      if (timeUntilDeadline.inMinutes <= 0 && 
          timeUntilDeadline.inMinutes > -1) {
        await _sendOverdueNotification(task);
      }
    }
  }
}
```

#### _showNotification() - Afficher une notification

```dart
Future<void> _showNotification({
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'task_notifications',
    'Task Notifications',
    channelDescription: 'Notifications for task reminders',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
    icon: '@mipmap/ic_launcher',
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  await _flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    notificationDetails,
    payload: payload,
  );
}
```

#### sendTaskCompletedNotification() - Notification de tâche complétée

```dart
Future<void> sendTaskCompletedNotification(Task task) async {
  final message = 'Congratulations! You completed the task "${task.title}"!';

  await _showNotification(
    id: task.id.hashCode + 2000,
    title: '✅ Task Completed',
    body: message,
    payload: task.id,
  );

  await _saveNotification(AppNotification(
    taskId: task.id,
    taskTitle: task.title,
    message: message,
    type: NotificationType.completed,
  ));
}
```

#### Méthodes de gestion des notifications

| Méthode | Description |
|---------|-------------|
| `getNotifications()` | Récupère toutes les notifications |
| `getUnreadCount()` | Compte les notifications non lues |
| `markAsRead(String id)` | Marque une notification comme lue |
| `markAllAsRead()` | Marque toutes les notifications comme lues |
| `deleteNotification(String id)` | Supprime une notification |
| `deleteAllNotifications()` | Supprime toutes les notifications |

