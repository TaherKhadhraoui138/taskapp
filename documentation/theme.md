# Thème et Style

## 1. Palette de Couleurs

### Fichier: `lib/core/app_theme.dart`

### Couleurs Principales

```dart
class AppColors {
  // Couleurs vives principales
  static const Color coral = Color(0xFFFF6B6B);
  static const Color cyan = Color(0xFF4ECDC4);
  static const Color purple = Color(0xFFA855F7);
  static const Color amber = Color(0xFFF59E0B);
  
  // Couleurs neutres
  static const Color charcoal = Color(0xFF2D3748);
  static const Color grey = Color(0xFF718096);
  static const Color background = Color(0xFFF7FAFC);
  
  // Gradient principal - Violet vibrant à Rose
  static const Color primaryStart = Color(0xFF667eea);
  static const Color primaryEnd = Color(0xFF764ba2);
  
  // Gradient secondaire - Corail Orange
  static const Color secondaryStart = Color(0xFFf093fb);
  static const Color secondaryEnd = Color(0xFFf5576c);
  
  // Gradient accent - Teal Cyan
  static const Color accentStart = Color(0xFF4facfe);
  static const Color accentEnd = Color(0xFF00f2fe);
  
  // Gradient succès - Vert menthe
  static const Color successStart = Color(0xFF11998e);
  static const Color successEnd = Color(0xFF38ef7d);
  
  // Gradient erreur - Rouge profond
  static const Color errorStart = Color(0xFFeb3349);
  static const Color errorEnd = Color(0xFFf45c43);
  
  // Couleurs de fond
  static const Color backgroundLight = Color(0xFFF8FAFF);
  static const Color backgroundDark = Color(0xFF0D0D1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  
  // Couleurs des cartes
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF16213E);
  
  // Couleurs du texte
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF8FAFF);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  
  // Couleurs de priorité
  static const Color priorityHigh = Color(0xFFFF6B6B);
  static const Color priorityMedium = Color(0xFFFFB84D);
  static const Color priorityLow = Color(0xFF4ECDC4);
  
  // Couleurs de catégorie
  static const Color categoryWork = Color(0xFF667eea);
  static const Color categoryPersonal = Color(0xFFf093fb);
  static const Color categoryStudy = Color(0xFF4facfe);
  static const Color categoryOther = Color(0xFF38ef7d);
  
  // Glassmorphism
  static Color glassLight = Colors.white.withOpacity(0.25);
  static Color glassDark = Colors.white.withOpacity(0.1);
  static Color glassBorder = Colors.white.withOpacity(0.2);
}
```

---

## 2. Gradients

```dart
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.coral, Color(0xFFFF8E8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondary = LinearGradient(
    colors: [AppColors.cyan, Color(0xFF45B7AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accent = LinearGradient(
    colors: [AppColors.accentStart, AppColors.accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient aurora = LinearGradient(
    colors: [AppColors.purple, Color(0xFFC084FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunset = LinearGradient(
    colors: [AppColors.amber, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient ocean = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient success = LinearGradient(
    colors: [AppColors.successStart, AppColors.successEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient error = LinearGradient(
    colors: [AppColors.errorStart, AppColors.errorEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradients de priorité
  static const LinearGradient priorityHigh = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFee5a5a)],
  );
  
  static const LinearGradient priorityMedium = LinearGradient(
    colors: [Color(0xFFFFB84D), Color(0xFFffa726)],
  );
  
  static const LinearGradient priorityLow = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF45B7D1)],
  );
}
```

---

## 3. Ombres

```dart
class AppShadows {
  static List<BoxShadow> small = [
    BoxShadow(
      color: AppColors.charcoal.withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.charcoal.withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> large = [
    BoxShadow(
      color: AppColors.charcoal.withOpacity(0.16),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
  ];
  
  // Ombre avec effet de lueur
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
```

---

## 4. Bordures

```dart
class AppBorders {
  static BorderRadius small = BorderRadius.circular(12);
  static BorderRadius medium = BorderRadius.circular(16);
  static BorderRadius large = BorderRadius.circular(24);
  static BorderRadius full = BorderRadius.circular(100);
}
```

---

## 5. Styles de Texte

```dart
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.charcoal,
    letterSpacing: -1.0,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.charcoal,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.grey,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
```

---

## 6. Thème Clair

```dart
static ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryStart,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryStart,
      secondary: AppColors.secondaryStart,
      surface: AppColors.surfaceLight,
      error: AppColors.errorStart,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: AppBorders.medium,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorders.medium,
        borderSide: const BorderSide(color: AppColors.primaryStart, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primaryStart,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
      ),
    ),
  );
}
```

---

## 7. Thème Sombre

```dart
static ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryStart,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryStart,
      secondary: AppColors.secondaryStart,
      surface: AppColors.surfaceDark,
      error: AppColors.errorStart,
    ),
    // Configuration similaire avec couleurs sombres
  );
}
```

---

## 8. Widgets Animés

### Fichier: `lib/core/animated_widgets.dart`

### StaggeredListItem - Animation décalée

```dart
class StaggeredListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final Duration delayPerItem;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

### AnimatedScaleTap - Animation de pression

```dart
class AnimatedScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleValue;
  final Duration duration;
}

class _AnimatedScaleTapState extends State<AnimatedScaleTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
```

### FloatingAnimation - Animation flottante

```dart
class FloatingAnimation extends StatefulWidget {
  final Widget child;
  // Widget avec animation de flottement vertical
}
```

