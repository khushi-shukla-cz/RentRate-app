import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF9FAFB);
  static const Color softBeige = Color(0xFFF5F5F5);

  // Text
  static const Color textDark = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textBody = Color(0xFF6B7280);

  // Accent
  static const Color primary = Color(0xFFE76F51);
  static const Color primaryDark = Color(0xFFD65A3F);

  // Special
  static const Color rating = Color(0xFFF4A261);
  static const Color trustHigh = Color(0xFF2A9D8F);
  static const Color warning = Color(0xFFE63946);

  // Neutral
  static const Color border = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x1A000000);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.trustHigh,
      surface: AppColors.background,
      error: AppColors.warning,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.softBeige,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.textBody),
    ),
  );
}

class AppConstants {
  // Override at runtime when needed:
  // flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5000/api
  static String get baseUrl {
    const overridden = String.fromEnvironment('API_BASE_URL');
    if (overridden.isNotEmpty) return overridden;

    if (kIsWeb) return 'http://localhost:5000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api'; // Android emulator
    }
    return 'http://localhost:5000/api'; // iOS / desktop
  }
  
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String tenantDashboard = '/tenant';
  static const String ownerDashboard = '/owner';
  static const String profile = '/profile';
  static const String userProfile = '/user/:id';
  static const String properties = '/properties';
  static const String propertyDetails = '/property/:id';
  static const String addProperty = '/property/add';
  static const String editProperty = '/property/edit/:id';
  static const String submitReview = '/review/submit';
  static const String messages = '/messages';
  static const String thread = '/messages/:userId';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String savedProperties = '/saved';
}
