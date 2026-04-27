import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primarySurface = Color(0x1A2196F3);

  // Surfaces
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE0E0E0);

  // Text
  static const Color textPrimary = Color(0xDD000000);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textMuted = Color(0xFF9E9E9E);

  // Status
  static const Color statusWaiting = Color(0xFFFB8C00);
  static const Color statusMarshalling = Color(0xFF1E88E5);
  static const Color statusInProgress = Color(0xFFFFB300);
  static const Color statusFinished = Color(0xFF43A047);
  static const Color statusError = Color(0xFFE53935);

  // Rank medals
  static const Color rankGold = Color(0xFFFFA000);
  static const Color rankSilver = Color(0xFF757575);
  static const Color rankBronze = Color(0xFF6D4C41);
}
