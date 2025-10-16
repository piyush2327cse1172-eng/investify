import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Indigo/Purple Gradient
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFA855F7);
  static const Color accent = Color(0xFF06B6D4);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF8B5CF6),
    Color(0xFFA855F7),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];
  
  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFBBF24),
  ];
}

class AppShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    const BoxShadow(
      color: Colors.white,
      blurRadius: 1,
      offset: Offset(0, -1),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> colored(Color color, {double opacity = 0.25}) => [
    BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}