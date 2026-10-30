// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// Google map-style JSON shared by the driver and rider maps, as asset keys an
/// app passes to `rootBundle.loadString`.
const _mapStyleDir = 'packages/app_theme/assets/map_styles';
const _darkMapStyle = '$_mapStyleDir/dark.json';
const _halloweenMapStyle = '$_mapStyleDir/halloween.json';
const _christmasMapStyle = '$_mapStyleDir/christmas.json';
const _christmasDarkMapStyle = '$_mapStyleDir/christmas_dark.json';
const _newYearMapStyle = '$_mapStyleDir/new_year.json';

/// Every bundled map style.
const mapStyleAssets = [
  _darkMapStyle,
  _halloweenMapStyle,
  _christmasMapStyle,
  _christmasDarkMapStyle,
  _newYearMapStyle,
];

/// The map style for the app's theme, or null for the map's default look.
///
/// A festive [season] wins over dark mode: Halloween ("haunted night") and
/// New Year ("city of lights") are night maps in both modes; Christmas is a
/// snowy village in light mode and a snowy night in dark mode. Every festive
/// map keeps roads very dark or very light so the HOVR green route stands out.
/// Colour codes: `doc/festive_colors.md`.
String? mapStyleAsset({
  required ThemeMode mode,
  required Brightness platformBrightness,
  required SeasonalTheme season,
}) {
  final isDark = mode == ThemeMode.dark ||
      (mode == ThemeMode.system && platformBrightness == Brightness.dark);
  final festive = switch (season) {
    SeasonalTheme.none => null,
    SeasonalTheme.halloween => _halloweenMapStyle,
    SeasonalTheme.christmas => isDark ? _christmasDarkMapStyle : _christmasMapStyle,
    SeasonalTheme.newYear => _newYearMapStyle,
  };
  return festive ?? (isDark ? _darkMapStyle : null);
}
