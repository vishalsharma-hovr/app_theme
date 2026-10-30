// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// App-wide [ThemeData] for the rider and driver apps:
///
/// ```dart
/// final season = seasonalThemeFor(DateTime.now());
/// MaterialApp(
///   theme: AppTheme.light(season: season),
///   darkTheme: AppTheme.dark(season: season),
/// )
/// ```
///
/// Screens follow dark mode and the season when they read colours from the
/// theme: `context.colors` ([AppPalette]) and `context.brand` ([BrandColors]).
/// Colour codes per season: `doc/festive_colors.md`.
class AppTheme {
  /// Light theme: primary is exactly [season]'s brand primary (HOVR green
  /// `#39851C` out of season) with white on it, on the palette's page colour,
  /// tinted for a festive [season] ([AppPalette.forSeason]).
  /// The driver app passes [AppPalette.driverLight].
  static ThemeData light({
    SeasonalTheme season = SeasonalTheme.none,
    AppPalette palette = AppPalette.light,
  }) {
    final brand = BrandColors.forSeason(season);
    final pages = palette.forSeason(season, dark: false);
    return _build(
      // The seeded surface is tinted, where HOVR green is under AA for text.
      ColorScheme.fromSeed(seedColor: brand.primaryColor).copyWith(
        primary: brand.primaryColor,
        onPrimary: Colors.white,
        surface: pages.white000,
      ),
      pages,
      brand,
    );
  }

  /// Dark theme: out of season the same HOVR primary as light, with white on
  /// it; in a festive [season] that season's lighter dark tone, with dark text on it.
  static ThemeData dark({SeasonalTheme season = SeasonalTheme.none}) {
    final brand = BrandColors.forSeason(season, dark: true);
    final palette = AppPalette.dark.forSeason(season, dark: true);
    return _build(
      ColorScheme.fromSeed(
        seedColor: brand.primaryColor,
        brightness: Brightness.dark,
      ).copyWith(
        primary: brand.primaryColor,
        // White only reads on the dark HOVR green; festive dark tones are light.
        onPrimary: season == SeasonalTheme.none ? Colors.white : palette.white000,
        surface: palette.white000,
        onSurface: palette.black900,
        onSurfaceVariant: palette.textSecondary,
        outline: palette.grey050,
        error: palette.errorColor,
      ),
      palette,
      brand,
    );
  }

  static ThemeData _build(
    ColorScheme scheme,
    AppPalette palette,
    BrandColors brand,
  ) =>
      ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: palette.white000,
        appBarTheme: AppBarTheme(
          backgroundColor: palette.white000,
          foregroundColor: scheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        extensions: [palette, brand],
      );
}
