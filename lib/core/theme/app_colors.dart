import 'package:flutter/material.dart';

class AppColors {
  // Primary Navy Theme
  static const Color primary = Color(0xFF053061);
  static const Color primaryLight = Color(0xFF1E4C82);
  static const Color accent = Color(0xFF5C93E6);
  
  // Splash Screen & Dark UI Elements
  static const Color splashBg = Color(0xFF1E2638);
  static const Color splashGears = Color(0xFF28324A);
  
  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  
  // Alert & Trend Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Platform Brand Colors (Simulated badges)
  static const Color ebay = Color(0xFFE53238);
  static const Color chrono24 = Color(0xFF0C2440);
  static const Color grailzee = Color(0xFF111111);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);
}

extension ThemeColors on BuildContext {
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
  
  Color get scaffoldBg => isDarkTheme ? AppColors.backgroundDark : AppColors.background;
  Color get surfaceBg => isDarkTheme ? AppColors.surfaceDark : AppColors.surface;
  Color get textPrimaryColor => isDarkTheme ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color get textSecondaryColor => isDarkTheme ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color get borderColor => isDarkTheme ? AppColors.borderDark : AppColors.border;
  Color get primaryNav => isDarkTheme ? AppColors.accent : AppColors.primary;
  Color get cardBg => isDarkTheme ? AppColors.surfaceDark : Colors.white;
  Color get chipBg => isDarkTheme ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
}
