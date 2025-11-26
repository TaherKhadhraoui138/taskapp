# Guide d'utilisation - Système de Notifications

## Comment tester la fonctionnalité

### 1. Créer une tâche avec une deadline proche
1. Ouvrez l'application TaskAI
2. Cliquez sur le bouton **+** (Floating Action Button)
3. Créez une nouvelle tâche avec une deadline dans **moins de 30 minutes**
4. Sauvegardez la tâche

### 2. Attendre la notification
Le système vérifie automatiquement toutes les **5 minutes** s'il y a des tâches avec une deadline proche.

Pour tester immédiatement sans attendre :
- La vérification se fait aussi au démarrage de l'application
- Redémarrez l'application après avoir créé la tâche

### 3. Accéder aux notifications
1. Cliquez sur l'icône **🔔 Notifications** dans la barre de navigation (4ème icône)
2. Vous verrez toutes vos notifications
3. Un **badge rouge** sur l'icône indique le nombre de notifications non lues

### 4. Gérer les notifications

#### Marquer comme lu
- Cliquez simplement sur une notification pour la marquer comme lue

#### Supprimer une notification
- Glissez la notification vers la **gauche** pour la supprimer
- Un bouton "Annuler" apparaît si vous changez d'avis

#### Marquer toutes comme lues
- Cliquez sur l'icône **✓✓** en haut à droite

#### Supprimer toutes les notifications
- Cliquez sur l'icône **🗑️** en haut à droite
- Confirmez l'action

### 5. Notifications de complétion
1. Sur l'écran d'accueil, cochez une tâche comme complétée
2. Une notification de félicitations est automatiquement créée
3. Allez dans la page notifications pour la voir

## Caractéristiques visuelles

### Badge de notification
- **Rouge** avec nombre blanc = notifications non lues
- Disparaît quand toutes les notifications sont lues

### Carte de notification
- **Bordure bleue épaisse** = non lue
- **Bordure fine ou sans bordure** = lue
- **Point bleu** à droite du titre = non lue

### Types de notifications
- 🔔 **Orange** : Deadline proche (moins de 30 min)
- ✓ **Vert** : Tâche complétée
- 🔔 **Bleu** : Rappel

## Notes importantes

1. **Fréquence de vérification** : Les tâches sont vérifiées toutes les 5 minutes
2. **Pas de doublons** : Le système ne crée pas de notification multiple pour la même tâche
3. **Persistance** : Les notifications sont sauvegardées dans Firebase et persistent même après redémarrage
4. **Temps réel** : Le badge de notification se met à jour en temps réel

## Exemple de scénario de test

1. Créez 3 tâches :
   - Tâche A : deadline dans 20 minutes
   - Tâche B : deadline dans 1 heure
   - Tâche C : deadline dans 2 jours

2. Attendez 5 minutes ou redémarrez l'app

3. Vous devriez voir :
   - ✅ Notification pour Tâche A (moins de 30 min)
   - ❌ Pas de notification pour Tâche B (plus de 30 min)
   - ❌ Pas de notification pour Tâche C (trop loin)

4. Complétez la Tâche A

5. Vous verrez :
   - Une nouvelle notification de félicitations
   - La notification de deadline reste visible

## Dépannage

### Aucune notification n'apparaît
- Vérifiez que la deadline est bien dans les 30 prochaines minutes
- Vérifiez que la tâche n'est pas marquée comme complétée
- Attendez 5 minutes pour la prochaine vérification
- Ou redémarrez l'application

### Le badge ne se met pas à jour
- Le badge utilise un Stream Firebase et devrait se mettre à jour automatiquement
- Essayez de changer d'onglet puis de revenir

### Les notifications disparaissent
- Vérifiez que vous n'avez pas glissé pour supprimer par accident
- Les notifications sont persistantes dans Firebase

