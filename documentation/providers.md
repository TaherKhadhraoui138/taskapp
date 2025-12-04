# Providers (Gestion d'État)

## 1. ThemeProvider - Gestion du Thème

### Fichier: `lib/providers/theme_provider.dart`

Provider pour basculer entre le thème clair et sombre, avec persistance via SharedPreferences.

```dart
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }
```

### Méthodes

#### toggleTheme() - Basculer le thème

```dart
void toggleTheme() {
  _isDarkMode = !_isDarkMode;
  _saveThemePreference();
  notifyListeners();
}
```

#### _loadThemePreference() - Charger la préférence

```dart
Future<void> _loadThemePreference() async {
  final prefs = await SharedPreferences.getInstance();
  _isDarkMode = prefs.getBool('darkMode') ?? false;
  notifyListeners();
}
```

#### _saveThemePreference() - Sauvegarder la préférence

```dart
Future<void> _saveThemePreference() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('darkMode', _isDarkMode);
}
```

---

## 2. NotificationSettingsProvider - Paramètres de Notification

### Fichier: `lib/providers/notification_settings_provider.dart`

Provider pour gérer les paramètres des notifications de rappel.

```dart
class NotificationSettingsProvider extends ChangeNotifier {
  static const String _notificationReminderKey = 'notification_reminder_minutes';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  int _reminderMinutes = 30; // Par défaut 30 minutes avant l'échéance
  bool _notificationsEnabled = true;

  int get reminderMinutes => _reminderMinutes;
  bool get notificationsEnabled => _notificationsEnabled;

  NotificationSettingsProvider() {
    _loadSettings();
  }
}
```

### Méthodes

#### _loadSettings() - Charger les paramètres

```dart
Future<void> _loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  _reminderMinutes = prefs.getInt(_notificationReminderKey) ?? 30;
  _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
  notifyListeners();
}
```

#### setReminderMinutes() - Définir le temps de rappel

```dart
Future<void> setReminderMinutes(int minutes) async {
  _reminderMinutes = minutes;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_notificationReminderKey, minutes);
  notifyListeners();
}
```

#### setNotificationsEnabled() - Activer/Désactiver les notifications

```dart
Future<void> setNotificationsEnabled(bool enabled) async {
  _notificationsEnabled = enabled;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_notificationsEnabledKey, enabled);
  notifyListeners();
}
```

### Options prédéfinies

```dart
// Options de temps de rappel disponibles (en minutes)
static List<int> get reminderOptions => [5, 10, 15, 30, 60, 120, 1440];

// Formatage du temps de rappel pour l'affichage
static String formatReminderTime(int minutes) {
  if (minutes < 60) {
    return '$minutes minutes';
  } else if (minutes == 60) {
    return '1 hour';
  } else if (minutes < 1440) {
    return '${minutes ~/ 60} hours';
  } else {
    return '1 day';
  }
}
```

---

## Utilisation dans main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().initialize();
  Gemini.init(apiKey: 'API_KEY');
  
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

### Consommation du ThemeProvider

```dart
class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
```

