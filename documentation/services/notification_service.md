# NotificationService - Service de Notifications

## Fichier: `lib/services/notification_service.dart`

Service Singleton gérant les notifications locales avec flutter_local_notifications et leur stockage dans Firestore.

---

## Dépendances

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
```

---

## Pattern Singleton

Le service utilise le pattern Singleton pour garantir une seule instance dans toute l'application.

```dart
class NotificationService {
  // Instance unique
  static final NotificationService _instance = NotificationService._internal();
  
  // Factory constructor retourne toujours la même instance
  factory NotificationService() => _instance;
  
  // Constructeur privé
  NotificationService._internal();

  // Propriétés
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _checkTimer;
  bool _isInitialized = false;

  String? get _currentUserId => _auth.currentUser?.uid;
}
```

---

## Initialisation

### initialize() - Configuration initiale

Doit être appelé au démarrage de l'application (dans `main()`).

```dart
Future<void> initialize() async {
  if (_isInitialized) return;

  // Initialiser les fuseaux horaires
  tz.initializeTimeZones();

  // Configuration Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Configuration iOS
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Configuration globale
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // Initialiser le plugin
  await _flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _onNotificationTapped,
  );

  // Demander les permissions Android 13+
  await _requestPermissions();

  _isInitialized = true;

  // Démarrer la vérification périodique
  _startPeriodicCheck();
}
```

### _requestPermissions() - Demander les permissions

```dart
Future<void> _requestPermissions() async {
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidImplementation != null) {
    await androidImplementation.requestNotificationsPermission();
  }
}
```

---

## Vérification Périodique des Deadlines

### _startPeriodicCheck() - Démarrer la vérification

```dart
void _startPeriodicCheck() {
  _checkTimer?.cancel();
  
  // Vérifier toutes les minutes
  _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
    _checkTaskDeadlines();
  });
  
  // Vérifier immédiatement au démarrage
  _checkTaskDeadlines();
}
```

### _checkTaskDeadlines() - Vérifier les échéances

```dart
Future<void> _checkTaskDeadlines() async {
  if (_currentUserId == null) return;

  // Vérifier si les notifications sont activées
  final notificationsEnabled = await _areNotificationsEnabled();
  if (!notificationsEnabled) return;

  // Récupérer le délai de rappel configuré
  final reminderMinutes = await _getReminderMinutes();

  try {
    // Récupérer les tâches non complétées
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
  } catch (e) {
    debugPrint('Error checking task deadlines: $e');
  }
}
```

### Diagramme de flux

```
Timer (toutes les minutes)
         │
         ▼
┌────────────────────────┐
│ _checkTaskDeadlines()  │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│ Notifications          │──► Non ──► STOP
│ activées ?             │
└───────────┬────────────┘
            │ Oui
            ▼
┌────────────────────────┐
│ Charger tâches         │
│ non complétées         │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────────────────────┐
│ Pour chaque tâche avec deadline:       │
│                                        │
│ ┌─────────────────────────────────┐    │
│ │ Deadline dans X min ?           │    │
│ │ (X = reminderMinutes)           │    │
│ └──────────────┬──────────────────┘    │
│                │ Oui                   │
│                ▼                       │
│ ┌─────────────────────────────────┐    │
│ │ _sendDeadlineNotification()     │    │
│ └─────────────────────────────────┘    │
│                                        │
│ ┌─────────────────────────────────┐    │
│ │ Deadline passée ?               │    │
│ └──────────────┬──────────────────┘    │
│                │ Oui                   │
│                ▼                       │
│ ┌─────────────────────────────────┐    │
│ │ _sendOverdueNotification()      │    │
│ └─────────────────────────────────┘    │
└────────────────────────────────────────┘
```

---

## Envoi de Notifications

### _showNotification() - Afficher une notification

```dart
Future<void> _showNotification({
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'task_notifications',           // Channel ID
    'Task Notifications',           // Channel name
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

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
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

### _sendDeadlineNotification() - Notification de deadline proche

```dart
Future<void> _sendDeadlineNotification(Task task, int minutesLeft) async {
  // Vérifier si notification déjà envoyée récemment
  final existingNotification = await _checkExistingNotification(
    task.id,
    NotificationType.deadline,
    const Duration(minutes: 30),
  );

  if (existingNotification) return;

  final message = 'Task "${task.title}" is due in $minutesLeft minutes!';

  // Envoyer la notification locale
  await _showNotification(
    id: task.id.hashCode,
    title: '⏰ Task Reminder',
    body: message,
    payload: task.id,
  );

  // Sauvegarder dans Firestore
  await _saveNotification(AppNotification(
    taskId: task.id,
    taskTitle: task.title,
    message: message,
    type: NotificationType.deadline,
  ));
}
```

### _sendOverdueNotification() - Notification de tâche en retard

```dart
Future<void> _sendOverdueNotification(Task task) async {
  final existingNotification = await _checkExistingNotification(
    task.id,
    NotificationType.completed,
    const Duration(hours: 1),
  );

  if (existingNotification) return;

  final message = 'Task "${task.title}" is overdue!';

  await _showNotification(
    id: task.id.hashCode + 1000,
    title: '🚨 Overdue Task',
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

### sendTaskCompletedNotification() - Notification de tâche terminée

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

---

## Notifications Programmées

### scheduleDeadlineNotification() - Programmer une notification

Programme une notification à un moment précis (X minutes avant la deadline).

```dart
Future<void> scheduleDeadlineNotification(Task task) async {
  if (task.deadline == null) return;

  // Vérifier si les notifications sont activées
  final notificationsEnabled = await _areNotificationsEnabled();
  if (!notificationsEnabled) return;

  // Calculer le moment de la notification
  final reminderMinutes = await _getReminderMinutes();
  final scheduledTime = task.deadline!.subtract(Duration(minutes: reminderMinutes));

  // Ne pas programmer si le moment est déjà passé
  if (scheduledTime.isBefore(DateTime.now())) return;

  // Convertir en timezone locale
  final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'scheduled_task_notifications',
    'Scheduled Notifications',
    channelDescription: 'Scheduled notifications for tasks',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  final reminderText = _formatReminderTime(reminderMinutes);

  await _flutterLocalNotificationsPlugin.zonedSchedule(
    task.id.hashCode + 3000,
    '⏰ Task Reminder',
    'Task "${task.title}" is due in $reminderText!',
    tzScheduledTime,
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    payload: task.id,
  );
}
```

### cancelScheduledNotification() - Annuler une notification programmée

```dart
Future<void> cancelScheduledNotification(String taskId) async {
  await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode + 3000);
}
```

---

## Gestion des Notifications (Firestore)

### getNotifications() - Récupérer toutes les notifications

```dart
Future<List<AppNotification>> getNotifications() async {
  if (_currentUserId == null) return [];

  try {
    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AppNotification.fromJson(doc.data()))
        .toList();
  } catch (e) {
    debugPrint('Error getting notifications: $e');
    return [];
  }
}
```

### getUnreadCount() - Compter les non lues

```dart
Future<int> getUnreadCount() async {
  if (_currentUserId == null) return 0;

  try {
    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  } catch (e) {
    debugPrint('Error getting unread count: $e');
    return 0;
  }
}
```

### markAsRead() - Marquer comme lue

```dart
Future<void> markAsRead(String notificationId) async {
  if (_currentUserId == null) return;

  try {
    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  } catch (e) {
    debugPrint('Error marking notification as read: $e');
  }
}
```

### markAllAsRead() - Tout marquer comme lu

```dart
Future<void> markAllAsRead() async {
  if (_currentUserId == null) return;

  try {
    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  } catch (e) {
    debugPrint('Error marking all as read: $e');
  }
}
```

### deleteNotification() - Supprimer une notification

```dart
Future<void> deleteNotification(String notificationId) async {
  if (_currentUserId == null) return;

  try {
    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  } catch (e) {
    debugPrint('Error deleting notification: $e');
  }
}
```

### deleteAllNotifications() - Tout supprimer

```dart
Future<void> deleteAllNotifications() async {
  if (_currentUserId == null) return;

  try {
    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  } catch (e) {
    debugPrint('Error deleting all notifications: $e');
  }
}
```

---

## Paramètres de Notification

### _getReminderMinutes() - Obtenir le délai configuré

```dart
Future<int> _getReminderMinutes() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('notification_reminder_minutes') ?? 30;
}
```

### _areNotificationsEnabled() - Vérifier si activées

```dart
Future<bool> _areNotificationsEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('notifications_enabled') ?? true;
}
```

---

## Types de Notifications

| Type | ID Offset | Titre | Déclencheur |
|------|-----------|-------|-------------|
| Deadline | `hashCode` | ⏰ Task Reminder | X min avant deadline |
| Overdue | `hashCode + 1000` | 🚨 Overdue Task | Deadline passée |
| Completed | `hashCode + 2000` | ✅ Task Completed | Tâche terminée |
| Scheduled | `hashCode + 3000` | ⏰ Task Reminder | Programmée |

---

## Configuration Android

### AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

<application>
    <!-- Receivers pour les notifications programmées -->
    <receiver android:exported="false" 
              android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
    <receiver android:exported="false" 
              android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"/>
            <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
            <action android:name="android.intent.action.QUICKBOOT_POWERON" />
            <category android:name="android.intent.category.DEFAULT" />
        </intent-filter>
    </receiver>
</application>
```

### build.gradle.kts (Desugaring)

```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

