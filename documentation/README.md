# TaskAI - Documentation Complète

## Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Installation](#installation)
4. [Configuration Firebase](#configuration-firebase)
5. [Modèles de données](./models.md)
6. [Services](./services.md)
7. [Providers](./providers.md)
8. [Écrans](./screens.md)
9. [Widgets](./widgets.md)
10. [Thème et Style](./theme.md)

---

## Vue d'ensemble

**TaskAI** est une application Flutter de gestion de tâches intelligente avec les fonctionnalités suivantes :

### Fonctionnalités Principales

| Fonctionnalité | Description |
|----------------|-------------|
| ✅ Authentification | Connexion/Inscription via Firebase Auth |
| 📝 Gestion des tâches | CRUD complet avec sous-tâches |
| 📅 Calendrier | Vue calendrier des tâches |
| 📊 Statistiques | Analyses de productivité |
| 🔔 Notifications | Rappels personnalisables (5min à 1 jour) |
| 🎨 Thèmes | Mode clair/sombre |
| 🔄 Récurrence | Tâches répétitives (daily, weekly, monthly) |
| 🏷️ Catégories | Work, Personal, Study, Other |
| ⚡ Priorités | High, Medium, Low |

---

## Architecture

```
lib/
├── main.dart                 # Point d'entrée + configuration MultiProvider
├── firebase_options.dart     # Configuration Firebase auto-générée
│
├── core/                     # Thème et utilitaires
│   ├── app_theme.dart        # Couleurs, gradients, styles
│   └── animated_widgets.dart # Widgets avec animations
│
├── models/                   # Modèles de données
│   ├── task.dart             # Modèle Task + Subtask
│   ├── user.dart             # Modèle User
│   └── app_notification.dart # Modèle AppNotification
│
├── providers/                # Gestion d'état (Provider)
│   ├── theme_provider.dart   # Gestion thème clair/sombre
│   └── notification_settings_provider.dart # Paramètres notifications
│
├── services/                 # Logique métier
│   ├── auth_service.dart     # Authentification Firebase
│   ├── task_service.dart     # CRUD Firestore pour tâches
│   └── notification_service.dart # Notifications locales
│
├── screens/                  # Écrans de l'application (12 écrans)
│   ├── splash_screen.dart    # Écran de démarrage animé
│   ├── login_screen.dart     # Connexion
│   ├── register_screen.dart  # Inscription
│   ├── home_screen.dart      # Écran principal + navigation
│   ├── add_task_screen.dart  # Ajout/modification de tâche
│   ├── calendar_screen.dart  # Vue calendrier
│   ├── stats_screen.dart     # Statistiques
│   ├── profile_screen.dart   # Profil utilisateur
│   ├── edit_profile_screen.dart # Modification profil
│   ├── settings_screen.dart  # Paramètres
│   ├── notifications_screen.dart # Liste des notifications
│   └── about_screen.dart     # À propos
│
└── widgets/                  # Widgets réutilisables
    ├── task_list_item.dart   # Item de tâche
    ├── custom_button.dart    # Bouton personnalisé
    ├── custom_bottom_nav_bar.dart # Barre de navigation
    └── empty_state_widget.dart # État vide
```

---

## Installation

### Prérequis

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code
- Compte Firebase

### Étapes

```bash
# 1. Cloner le projet
git clone <repository-url>
cd taskapp

# 2. Installer les dépendances
flutter pub get

# 3. Configurer Firebase (voir section suivante)

# 4. Lancer l'application
flutter run
```

---

## Configuration Firebase

### 1. Créer un projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Créer un nouveau projet
3. Activer **Authentication** (Email/Password)
4. Créer une base **Cloud Firestore**

### 2. Configurer FlutterFire

```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurer le projet
flutterfire configure
```

### 3. Règles Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == userId;
      
      match /tasks/{taskId} {
        allow read, write: if request.auth != null 
                           && request.auth.uid == userId;
      }
      
      match /notifications/{notificationId} {
        allow read, write: if request.auth != null 
                           && request.auth.uid == userId;
      }
    }
  }
}
```

---

## Technologies Utilisées

| Technologie | Version | Usage |
|-------------|---------|-------|
| Flutter | ≥3.0.0 | Framework UI |
| Firebase Auth | ^4.20.0 | Authentification |
| Cloud Firestore | ^4.17.5 | Base de données |
| Provider | ^6.1.1 | Gestion d'état |
| flutter_local_notifications | ^17.2.2 | Notifications |
| shared_preferences | ^2.2.2 | Stockage local |
| intl | ^0.19.0 | Internationalisation |

---

## Démarrage Rapide

### 1. Lancer en mode debug

```bash
flutter run
```

### 2. Construire l'APK

```bash
flutter build apk --release
```

### 3. Construire pour iOS

```bash
flutter build ios --release
```

---

## Structure des Données Firestore

```
firestore/
└── users/
    └── {userId}/
        ├── email: string
        ├── name: string
        ├── profilePictureUrl: string
        │
        ├── tasks/ (sous-collection)
        │   └── {taskId}/
        │       └── [données de la tâche]
        │
        └── notifications/ (sous-collection)
            └── {notificationId}/
                └── [données de la notification]
```

---

## Flux de l'Application

```
┌──────────────┐
│ SplashScreen │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│ Vérification Auth    │
└──────┬───────────────┘
       │
       ├─── Non connecté ──► LoginScreen ──► RegisterScreen
       │                           │
       │                           ▼
       └─── Connecté ─────► HomeScreen
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
              StatsScreen  CalendarScreen  ProfileScreen
                                │
                                ▼
                         SettingsScreen
```

---

## Auteur

**TaskAI** - Application de gestion de tâches intelligente

Version: 1.0.0
