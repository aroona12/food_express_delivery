import 'package:flutter/material.dart';

/// Centralized color palette for FoodExpress.
///
/// Follows the brand direction:
/// - Primary: Warm food-inspired orange/coral
/// - Secondary: Dark charcoal
/// - Background/Surface: Clean light background with crisp white surfaces
/// - Supporting: Grayscale, success, warning, error
abstract final class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFFF5722); // Vibrant Food Orange/Coral
  static const Color primaryLight = Color(0xFFFF8A50);
  static const Color primaryDark = Color(0xFFE64A19);
  static const Color primaryContainer = Color(0xFFFFEDE6);

  static const Color secondary = Color(0xFF1E232A); // Dark Charcoal
  static const Color secondaryLight = Color(0xFF3B4048);
  static const Color secondaryContainer = Color(0xFFF1F3F5);

  // Accent
  static const Color accent = Color(0xFFFF9F1C); // Warm Amber Gold

  // Background & Surface
  static const Color background = Color(0xFFF9FAFB); // Soft Off-White
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Neutral / Grayscale
  static const Color textPrimary = Color(0xFF1F2937); // Deep Charcoal Text
  static const Color textSecondary = Color(0xFF6B7280); // Muted Gray Text
  static const Color textTertiary = Color(0xFF9CA3AF); // Placeholder / Disabled Text
  static const Color border = Color(0xFFE5E7EB); // Subtle Dividers & Outlines
  static const Color borderFocused = Color(0xFFFF5722);

  // Status & Feedback
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Warm Warning Amber
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Clear Coral Red
  static const Color errorContainer = Color(0xFFFEE2E2);

  // Shimmer / Skeletons
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);
}
