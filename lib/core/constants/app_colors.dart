import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryDark = Color(0xFF0D1257);
  static const Color accent = Color(0xFFFFD700);
  static const Color accentDark = Color(0xFFFFA000);

  // Background
  static const Color background = Color(0xFF0A0E2A);
  static const Color surface = Color(0xFF111535);
  static const Color surfaceLight = Color(0xFF1A1F45);
  static const Color card = Color(0xFF1E2348);
  static const Color cardBorder = Color(0xFF2A3060);

  // Stats Colors
  static const Color economy = Color(0xFF00C853);
  static const Color economyDark = Color(0xFF1B5E20);
  static const Color military = Color(0xFFFF5722);
  static const Color militaryDark = Color(0xFFBF360C);
  static const Color diplomacy = Color(0xFF2196F3);
  static const Color diplomacyDark = Color(0xFF0D47A1);
  static const Color social = Color(0xFF9C27B0);
  static const Color socialDark = Color(0xFF4A148C);
  static const Color approval = Color(0xFFFFEB3B);

  // Resource Colors
  static const Color food = Color(0xFF76C442);
  static const Color resources = Color(0xFFFF6D00);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color info = Color(0xFF03A9F4);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF546E7A);
  static const Color textAccent = Color(0xFFFFD700);

  // Approval gradient
  static Color approvalColor(double value) {
    if (value >= 70) return success;
    if (value >= 40) return warning;
    return danger;
  }

  // Region colors
  static const Map<String, Color> continentColors = {
    'Asia': Color(0xFF00BCD4),
    'Europe': Color(0xFF3F51B5),
    'Africa': Color(0xFFFF9800),
    'North America': Color(0xFF4CAF50),
    'South America': Color(0xFF9C27B0),
    'Oceania': Color(0xFFE91E63),
    'Antarctica': Color(0xFF607D8B),
  };
}
