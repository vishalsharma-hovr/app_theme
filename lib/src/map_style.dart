// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// Google map-style JSON shared by the driver and rider maps, as asset keys an
/// app passes to `rootBundle.loadString`.
const _mapStyleDir = 'packages/app_theme/assets/map_styles';
const _darkMapStyle = '$_mapStyleDir/dark.json';
const _halloweenMapStyle = '$_mapStyleDir/halloween.json';
const _christmasMapStyle = '$_mapStyleDir/christmas.json';
const _newYearMapStyle = '$_mapStyleDir/new_year.json';

/// Every bundled map style.
const mapStyleAssets = [
  _darkMapStyle,
  _halloweenMapStyle,
  _christmasMapStyle,
  _newYearMapStyle,
];

/// The map style for the app's theme, or null for the map's default look.
/// A festive [season] wins over dark mode.
String? mapStyleAsset({
  required ThemeMode mode,
  required Brightness platformBrightness,
  required SeasonalTheme season,
}) {
  final festive = switch (season) {
    SeasonalTheme.none => null,
    SeasonalTheme.halloween => _halloweenMapStyle,
    SeasonalTheme.christmas => _christmasMapStyle,
    SeasonalTheme.newYear => _newYearMapStyle,
  };
  if (festive != null) return festive;

  final isDark = mode == ThemeMode.dark ||
      (mode == ThemeMode.system && platformBrightness == Brightness.dark);
  return isDark ? _darkMapStyle : null;
}
