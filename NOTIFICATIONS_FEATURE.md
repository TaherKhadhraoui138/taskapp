# Fonctionnalité de Notifications

## Vue d'ensemble
Cette fonctionnalité ajoute un système de notifications à l'application TaskAI pour informer les utilisateurs des tâches dont la deadline approche.

## Composants créés

### 1. Modèle de Notification (`lib/models/notification.dart`)
- Définit la structure d'une notification
- Types de notifications :
  - `taskDeadline` : Notification d'échéance proche
  - `taskCompleted` : Notification de tâche complétée
  - `taskReminder` : Rappel de tâche

### 2. Service de Notifications (`lib/services/notification_service.dart`)
- **Vérification automatique** : Vérifie toutes les 5 minutes s'il y a des tâches avec une deadline dans les 30 prochaines minutes
- **Création de notifications** : Crée automatiquement des notifications pour :
  - Les tâches dont la deadline approche (moins de 30 minutes)
  - Les tâches complétées
- **Gestion des notifications** :
  - Marquer comme lu / non lu
  - Supprimer des notifications
  - Obtenir le nombre de notifications non lues

### 3. Écran de Notifications (`lib/screens/notifications_screen.dart`)
- Affiche toutes les notifications de l'utilisateur
- Permet de :
  - Marquer toutes les notifications comme lues
  - Supprimer toutes les notifications
  - Glisser pour supprimer une notification individuelle
  - Voir les détails de chaque notification

### 4. Barre de Navigation mise à jour (`lib/widgets/custom_bottom_nav_bar.dart`)
- Ajout d'une icône de notifications avec un badge indiquant le nombre de notifications non lues
- Le badge est mis à jour en temps réel

## Utilisation

### Démarrage du service
Le service de notifications démarre automatiquement lorsque l'utilisateur se connecte et arrive sur l'écran d'accueil :

```dart
_notificationService.startNotificationService();
```

### Arrêt du service
Le service s'arrête automatiquement lorsque l'utilisateur quitte l'application :

```dart
_notificationService.stopNotificationService();
```

## Navigation
La page de notifications est accessible via la barre de navigation en bas de l'écran (4ème icône).

## Fonctionnalités principales

1. **Notifications automatiques de deadline**
   - Le système vérifie toutes les 5 minutes
   - Crée une notification si une tâche non complétée a une deadline dans les 30 prochaines minutes
   - Ne crée pas de doublons (vérifie si une notification existe déjà)

2. **Notifications de complétion**
   - Lorsqu'une tâche est marquée comme complétée, une notification de félicitations est créée

3. **Interface intuitive**
   - Badge avec compteur sur l'icône de notifications
   - Glisser pour supprimer
   - Distinction visuelle entre notifications lues et non lues
   - Actions en masse (marquer tout comme lu, tout supprimer)

## Structure Firebase
Les notifications sont stockées dans Firestore :
```
users/{userId}/notifications/{notificationId}
```

Chaque notification contient :
- `id` : Identifiant unique
- `title` : Titre de la notification
- `message` : Message détaillé
- `type` : Type de notification
- `createdAt` : Date de création
- `isRead` : État lu/non lu
- `taskId` : ID de la tâche concernée (optionnel)
- `taskTitle` : Titre de la tâche concernée (optionnel)

## Améliorations futures possibles
- Notifications push avec Firebase Cloud Messaging
- Personnalisation de l'intervalle de vérification
- Notifications pour d'autres événements (nouvelles tâches, modifications, etc.)
- Sons et vibrations
- Catégories de notifications personnalisables

