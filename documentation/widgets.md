# Widgets Réutilisables

## 1. CustomBottomNavBar - Barre de Navigation

### Fichier: `lib/widgets/custom_bottom_nav_bar.dart`

Barre de navigation personnalisée avec effet glassmorphism et animations.

### Propriétés

```dart
class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
}
```

### Configuration des icônes

```dart
final List<IconData> _icons = [
  Icons.home_rounded,
  Icons.bar_chart_rounded,
  Icons.calendar_today_rounded,
  Icons.person_rounded,
];

final List<IconData> _selectedIcons = [
  Icons.home_filled,
  Icons.bar_chart_rounded,
  Icons.calendar_today_rounded,
  Icons.person_rounded,
];

final List<String> _labels = [
  'Home',
  'Stats',
  'Calendar',
  'Profile',
];
```

### Structure du widget

```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.cardDark.withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              // Items avec animation
            }),
          ),
        ),
      ),
    ),
  );
}
```

---

## 2. CustomButton - Bouton Personnalisé

### Fichier: `lib/widgets/custom_button.dart`

Bouton avec animation de scale et support de gradient.

### Propriétés

```dart
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final bool isOutline;
  final bool isLoading;
  final IconData? icon;
  final Gradient? gradient;
  final double height;
}
```

### Animation de pression

```dart
@override
void initState() {
  super.initState();
  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );
}

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTapDown: (_) => _controller.forward(),
    onTapUp: (_) {
      _controller.reverse();
      if (!widget.isLoading) widget.onPressed();
    },
    onTapCancel: () => _controller.reverse(),
    child: ScaleTransition(
      scale: _scale,
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.gradient ?? AppGradients.primary,
          borderRadius: AppBorders.medium,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryStart.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        // ...
      ),
    ),
  );
}
```

### Mode Outline

```dart
if (widget.isOutline) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: AppBorders.medium,
      border: Border.all(
        color: widget.color ?? AppColors.primaryStart,
        width: 2,
      ),
    ),
    // ...
  );
}
```

---

## 3. TaskListItem - Élément de Liste de Tâche

### Fichier: `lib/widgets/task_list_item.dart`

Widget pour afficher une tâche dans une liste avec gestes de suppression.

### Propriétés

```dart
class TaskListItem extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
}
```

### Méthodes de style

```dart
// Couleur selon la priorité
Color _getPriorityColor() {
  switch (widget.task.priority) {
    case TaskPriority.high:
      return AppColors.priorityHigh;
    case TaskPriority.medium:
      return AppColors.priorityMedium;
    case TaskPriority.low:
      return AppColors.priorityLow;
  }
}

// Gradient selon la priorité
LinearGradient _getPriorityGradient() {
  switch (widget.task.priority) {
    case TaskPriority.high:
      return AppGradients.priorityHigh;
    case TaskPriority.medium:
      return AppGradients.priorityMedium;
    case TaskPriority.low:
      return AppGradients.priorityLow;
  }
}

// Icône selon la catégorie
IconData _getCategoryIcon() {
  switch (widget.task.category) {
    case TaskCategory.work:
      return Icons.work_outline_rounded;
    case TaskCategory.personal:
      return Icons.person_outline_rounded;
    case TaskCategory.study:
      return Icons.school_outlined;
    case TaskCategory.other:
      return Icons.category_outlined;
  }
}

// Vérification si en retard
bool _isOverdue() {
  if (widget.task.deadline == null || widget.task.isCompleted) return false;
  return widget.task.deadline!.isBefore(DateTime.now());
}
```

### Suppression avec Dismissible

```dart
Dismissible(
  key: ValueKey(widget.task.id),
  direction: DismissDirection.endToStart,
  onDismissed: (direction) => widget.onDelete(),
  confirmDismiss: (direction) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Task?"),
          content: Text(
            "Are you sure you want to delete '${widget.task.title}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  },
  child: // Contenu de la tâche
)
```

---

## 4. EmptyStateWidget - État Vide

### Fichier: `lib/widgets/empty_state_widget.dart`

Widget affiché quand une liste est vide.

### Propriétés

```dart
class EmptyStateWidget extends StatefulWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;
}
```

### Animations

```dart
@override
void initState() {
  super.initState();
  // Animation de flottement
  _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);
  
  // Animation de pulsation
  _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);
  
  _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
    CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
  );
  
  _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
    CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
  );
}
```

### Structure

```dart
@override
Widget build(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icône animée avec effet de flottement
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: child,
            );
          },
          child: // Icône avec effet de pulsation
        ),
        
        // Message
        Text(widget.message),
        
        // Bouton d'action optionnel
        if (widget.actionText != null)
          CustomButton(
            text: widget.actionText!,
            onPressed: widget.onAction ?? () {},
          ),
      ],
    ),
  );
}
```

