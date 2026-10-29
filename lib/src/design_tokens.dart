// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// Spacing scale on a 4-point grid. Use these for padding, margins and gaps
/// instead of one-off numbers.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Smallest tap area for a button or icon (Material and Apple guidelines).
  static const double minTapTarget = 48;
}

/// Font sizes for `TextViewWidget.fontSize`, smallest first. These scale with
/// the device font size setting.
abstract final class AppTextSize {
  static const double micro = 10;
  static const double caption = 12;
  static const double body = 14;
  static const double bodyLarge = 16;
  static const double title = 20;
  static const double headline = 24;
  static const double display = 32;
}
