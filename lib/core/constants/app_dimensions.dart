import 'package:flutter/material.dart';

/// Centralized spacing, padding, radius, and sizing constants for FoodExpress.
abstract final class AppSpacing {
  // Base spacing units (Multiples of 4/8)
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Screen Edge Insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets screenPaddingWithTop = EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(12.0);
}

/// Centralized border radius values.
abstract final class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 999.0;

  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(pill));
}

/// Standardized component sizing constants.
abstract final class AppSizes {
  // Buttons
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // Input Fields
  static const double inputHeight = 52.0;

  // Icons
  static const double iconXs = 14.0;
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // App Bar
  static const double appBarHeight = 64.0;

  // Bottom Navigation Bar
  static const double bottomNavBarHeight = 70.0;
}
