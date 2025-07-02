import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern color palette for Jivhala Motors
  static const Color primaryColor = Color(0xFF2563EB); // Blue-600
  static const Color primaryLight = Color(0xFF3B82F6); // Blue-500
  static const Color primaryDark = Color(0xFF1D4ED8); // Blue-700
  static const Color secondaryColor = Color(0xFFF59E0B); // Amber-500
  static const Color accentColor = Color(0xFF10B981); // Emerald-500
  static const Color errorColor = Color(0xFFEF4444); // Red-500
  static const Color warningColor = Color(0xFFF59E0B); // Amber-500
  static const Color successColor = Color(0xFF10B981); // Emerald-500
  static const Color surfaceColor = Color(0xFFF8FAFC); // Slate-50
  static const Color cardColor = Color(0xFFFFFFFF); // White
  static const Color dividerColor = Color(0xFFE2E8F0); // Slate-200

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: createMaterialColor(primaryColor),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: surfaceColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1E293B), // Slate-800
      onError: Colors.white,
      outline: dividerColor,
      surfaceContainerHighest: Color(0xFFF1F5F9), // Slate-100
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: const Color(0xFF1E293B), // Slate-800
      displayColor: const Color(0xFF0F172A), // Slate-900
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ), // More iOS-like radius
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 1, // Reduced elevation for iOS feel
        shadowColor: primaryColor.withValues(alpha: 0.2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), // More iOS-like radius
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor),
      ),
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      elevation: 1, // Reduced elevation for iOS feel
      shadowColor: const Color(0xFF1E293B).withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // More iOS-like radius
      color: cardColor,
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: createMaterialColor(primaryColor),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate-900
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      secondary: secondaryColor,
      surface: Color(0xFF1E293B), // Slate-800
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Color(0xFFF1F5F9), // Slate-100
      onError: Colors.white,
      outline: Color(0xFF475569), // Slate-600
      surfaceContainerHighest: Color(0xFF334155), // Slate-700
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: const Color(0xFFF1F5F9), // Slate-100
      displayColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E293B), // Slate-800
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ), // More iOS-like radius
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 1, // Reduced elevation for iOS feel
        shadowColor: primaryLight.withValues(alpha: 0.2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), // More iOS-like radius
        borderSide: const BorderSide(color: Color(0xFF475569)), // Slate-600
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF475569)), // Slate-600
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor),
      ),
      filled: true,
      fillColor: const Color(0xFF334155), // Slate-700
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      elevation: 1, // Reduced elevation for iOS feel
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // More iOS-like radius
      color: const Color(0xFF1E293B), // Slate-800
    ),
  );

  // Helper method to create MaterialColor from Color
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = (color.r * 255.0).round() & 0xff;
    final int g = (color.g * 255.0).round() & 0xff;
    final int b = (color.b * 255.0).round() & 0xff;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }
}

// Custom colors for specific use cases
class AppColors {
  static const Color vehicleIn = Color(0xFF10B981); // Emerald-500
  static const Color vehicleOut = Color(0xFFF59E0B); // Amber-500
  static const Color pending = Color(0xFFF59E0B); // Amber-500
  static const Color completed = Color(0xFF10B981); // Emerald-500
  static const Color expired = Color(0xFFEF4444); // Red-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF3B82F6), // Blue-500
    Color(0xFF2563EB), // Blue-600
  ];

  static const List<Color> successGradient = [
    Color(0xFF34D399), // Emerald-400
    Color(0xFF10B981), // Emerald-500
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFBBF24), // Amber-400
    Color(0xFFF59E0B), // Amber-500
  ];
}
