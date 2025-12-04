import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vivid color palette for the TaskAI app
class AppColors {
  // Primary vivid colors
  static const Color coral = Color(0xFFFF6B6B);
  static const Color cyan = Color(0xFF4ECDC4);
  static const Color purple = Color(0xFFA855F7);
  static const Color amber = Color(0xFFF59E0B);
  
  // Neutral colors
  static const Color charcoal = Color(0xFF2D3748);
  static const Color grey = Color(0xFF718096);
  static const Color background = Color(0xFFF7FAFC);
  
  // Primary gradient colors - Vibrant Purple to Pink
  static const Color primaryStart = Color(0xFF667eea);
  static const Color primaryEnd = Color(0xFF764ba2);
  
  // Secondary gradient - Coral Orange
  static const Color secondaryStart = Color(0xFFf093fb);
  static const Color secondaryEnd = Color(0xFFf5576c);
  
  // Accent gradient - Teal Cyan
  static const Color accentStart = Color(0xFF4facfe);
  static const Color accentEnd = Color(0xFF00f2fe);
  
  // Success gradient - Mint Green
  static const Color successStart = Color(0xFF11998e);
  static const Color successEnd = Color(0xFF38ef7d);
  
  // Warning gradient - Sunset Orange
  static const Color warningStart = Color(0xFFf093fb);
  static const Color warningEnd = Color(0xFFf5576c);
  
  // Error gradient - Deep Red
  static const Color errorStart = Color(0xFFeb3349);
  static const Color errorEnd = Color(0xFFf45c43);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFF8FAFF);
  static const Color backgroundDark = Color(0xFF0D0D1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  
  // Card colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF16213E);
  
  // Text colors
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF8FAFF);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  
  // Priority colors
  static const Color priorityHigh = Color(0xFFFF6B6B);
  static const Color priorityMedium = Color(0xFFFFB84D);
  static const Color priorityLow = Color(0xFF4ECDC4);
  
  // Category colors
  static const Color categoryWork = Color(0xFF667eea);
  static const Color categoryPersonal = Color(0xFFf093fb);
  static const Color categoryStudy = Color(0xFF4facfe);
  static const Color categoryOther = Color(0xFF38ef7d);
  
  // Glassmorphism
  static Color glassLight = Colors.white.withOpacity(0.25);
  static Color glassDark = Colors.white.withOpacity(0.1);
  static Color glassBorder = Colors.white.withOpacity(0.2);
}

/// App gradients
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
  
  static const LinearGradient backgroundLight = LinearGradient(
    colors: [Color(0xFFF8FAFF), Color(0xFFE8EEFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient backgroundDark = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient shimmer = LinearGradient(
    colors: [
      Color(0xFFEEEEEE),
      Color(0xFFF5F5F5),
      Color(0xFFEEEEEE),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );
  
  // Priority gradients
  static const LinearGradient priorityHigh = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFee5a5a)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient priorityMedium = LinearGradient(
    colors: [Color(0xFFFFB84D), Color(0xFFffa726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient priorityLow = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF45B7D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// App shadows
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
  
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

/// App borders
class AppBorders {
  static BorderRadius small = BorderRadius.circular(12);
  static BorderRadius medium = BorderRadius.circular(16);
  static BorderRadius large = BorderRadius.circular(24);
  static BorderRadius full = BorderRadius.circular(100);
}

/// App text styles - Static styles for easy access
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

/// App Theme
class AppTheme {
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
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: AppTextStyles.heading3,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: const BorderSide(color: AppColors.primaryStart, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: const BorderSide(color: AppColors.errorStart, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: const BorderSide(color: AppColors.errorStart, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        labelStyle: TextStyle(color: Colors.grey.shade600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryStart,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryStart,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        backgroundColor: AppColors.primaryStart,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryStart,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryStart.withOpacity(0.1),
        selectedColor: AppColors.primaryStart,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorders.full),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppBorders.large),
        backgroundColor: AppColors.surfaceLight,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
  
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
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: const BorderSide(color: AppColors.primaryStart, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade600),
        labelStyle: TextStyle(color: Colors.grey.shade400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryStart,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        backgroundColor: AppColors.primaryStart,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryStart,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppBorders.large),
        backgroundColor: AppColors.surfaceDark,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
