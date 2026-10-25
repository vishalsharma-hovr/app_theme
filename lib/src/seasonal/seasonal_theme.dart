// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// Seasonal decorations shown over the whole app (drawn by [SeasonalOverlay]).
enum SeasonalTheme { none, halloween, christmas, newYear }

const int _halloweenStartDay = 24; // through Oct 31
const int _christmasStartDay = 20;
const int _christmasEndDay = 26;
const int _newYearEndDay = 2; // from Dec 31 through Jan 2

/// The season for [date] on the phone's local calendar; same windows every
/// year: Halloween Oct 24–31, Christmas Dec 20–26, New Year Dec 31–Jan 2,
/// otherwise none.
SeasonalTheme seasonalThemeFor(DateTime date) {
  final day = date.day;
  if (date.month == DateTime.october && day >= _halloweenStartDay) {
    return SeasonalTheme.halloween;
  }
  if (date.month == DateTime.december &&
      day >= _christmasStartDay &&
      day <= _christmasEndDay) {
    return SeasonalTheme.christmas;
  }
  if ((date.month == DateTime.december && day == 31) ||
      (date.month == DateTime.january && day <= _newYearEndDay)) {
    return SeasonalTheme.newYear;
  }
  return SeasonalTheme.none;
}

extension SeasonalThemeDecorations on SeasonalTheme {
  /// Icons drawn by the overlay for this season.
  List<SeasonalIconKind> get icons => switch (this) {
    SeasonalTheme.none => const [],
    SeasonalTheme.halloween => const [
      SeasonalIconKind.pumpkin,
      SeasonalIconKind.bat,
    ],
    SeasonalTheme.christmas => const [
      SeasonalIconKind.snowflake,
      SeasonalIconKind.tree,
    ],
    SeasonalTheme.newYear => const [
      SeasonalIconKind.fireworks,
      SeasonalIconKind.partyPopper,
    ],
  };

  /// Icon size in logical pixels: pumpkins, bats and fireworks read better
  /// larger than snowflakes.
  double get iconSize => this == SeasonalTheme.christmas ? 22 : 36;
}
