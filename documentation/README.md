# TaskAI - Documentation Complète

## Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Modèles de données](./models.md)
4. [Services](./services.md)
5. [Providers](./providers.md)
6. [Écrans](./screens.md)
7. [Widgets](./widgets.md)
8. [Thème et Style](./theme.md)

---

## Vue d'ensemble

**TaskAI** est une application Flutter de gestion de tâches avec les fonctionnalités suivantes :

- ✅ Authentification utilisateur (Firebase Auth)
- 📝 Gestion complète des tâches (CRUD)
- 📅 Calendrier intégré
- 📊 Statistiques et analyses
- 🔔 Notifications locales
- 🎨 Thème clair/sombre
- 🤖 Génération de sous-tâches par IA (Gemini)
- 🔄 Tâches récurrentes

---

## Architecture

```
lib/
├── main.dart              # Point d'entrée de l'application
├── firebase_options.dart  # Configuration Firebase
├── core/                  # Thème et widgets animés
├── models/               # Modèles de données
├── providers/            # Gestion d'état (Provider)
├── screens/              # Écrans de l'application
├── services/             # Services (Auth, Task, Notification)
└── widgets/              # Widgets réutilisables
```

---

## Technologies Utilisées

- **Flutter** - Framework UI
- **Firebase** - Backend (Auth + Firestore)
- **Provider** - Gestion d'état
- **Gemini AI** - Génération de sous-tâches
- **flutter_local_notifications** - Notifications locales
- **shared_preferences** - Stockage local des préférences

