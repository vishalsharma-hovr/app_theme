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
class AppTheme {
  /// Out of season this is the look both apps had before dark mode.
  /// The driver app passes [AppPalette.driverLight].
  static ThemeData light({
    SeasonalTheme season = SeasonalTheme.none,
    AppPalette palette = AppPalette.light,
  }) {
    final brand = BrandColors.forSeason(season);
    final seeded = ColorScheme.fromSeed(seedColor: brand.primaryColor);
    return _build(
      // fromSeed shifts primary to a muted tone; in festive seasons Material
      // widgets and the maps show the season's exact colour, as dark does.
      // Out of season the seeded green stays: HOVR's green is under AA on
      // the seeded surface.
      season == SeasonalTheme.none
          ? seeded
          : seeded.copyWith(
              primary: brand.primaryColor,
              onPrimary: palette.white000,
            ),
      palette,
      brand,
    );
  }

  static ThemeData dark({SeasonalTheme season = SeasonalTheme.none}) {
    final brand = BrandColors.forSeason(season).dark;
    const palette = AppPalette.dark;
    return _build(
      ColorScheme.fromSeed(
        seedColor: brand.primaryColor,
        brightness: Brightness.dark,
      ).copyWith(
        primary: brand.primaryColor,
        onPrimary: palette.white000,
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
