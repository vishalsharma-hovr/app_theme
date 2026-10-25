import 'package:app_theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('seasonalThemeFor', () {
    test('is none the day before Halloween season', () {
      expect(
        seasonalThemeFor(DateTime(2026, 10, 23, 23, 59)),
        SeasonalTheme.none,
      );
    });

    test('starts Halloween at midnight on Oct 24', () {
      expect(seasonalThemeFor(DateTime(2026, 10, 24)), SeasonalTheme.halloween);
    });

    test('keeps Halloween through the last minute of Oct 31', () {
      expect(
        seasonalThemeFor(DateTime(2026, 10, 31, 23, 59)),
        SeasonalTheme.halloween,
      );
    });

    test('ends Halloween on Nov 1', () {
      expect(seasonalThemeFor(DateTime(2026, 11, 1)), SeasonalTheme.none);
    });

    test('is none the day before Christmas season', () {
      expect(
        seasonalThemeFor(DateTime(2026, 12, 19, 23, 59)),
        SeasonalTheme.none,
      );
    });

    test('starts Christmas on Dec 20', () {
      expect(seasonalThemeFor(DateTime(2026, 12, 20)), SeasonalTheme.christmas);
    });

    test('keeps Christmas through Dec 26', () {
      expect(
        seasonalThemeFor(DateTime(2026, 12, 26, 23, 59)),
        SeasonalTheme.christmas,
      );
    });

    test('ends Christmas on Dec 27', () {
      expect(seasonalThemeFor(DateTime(2026, 12, 27)), SeasonalTheme.none);
    });

    test('uses the same windows every year', () {
      expect(seasonalThemeFor(DateTime(2031, 10, 28)), SeasonalTheme.halloween);
      expect(seasonalThemeFor(DateTime(2031, 12, 25)), SeasonalTheme.christmas);
      expect(seasonalThemeFor(DateTime(2031, 7, 1)), SeasonalTheme.none);
    });

    test('Oct 24-31 in other months is none', () {
      expect(seasonalThemeFor(DateTime(2026, 9, 28)), SeasonalTheme.none);
      expect(seasonalThemeFor(DateTime(2026, 11, 22)), SeasonalTheme.none);
    });

    test('is none on Dec 30, between Christmas and New Year', () {
      expect(seasonalThemeFor(DateTime(2026, 12, 30, 23, 59)), SeasonalTheme.none);
    });

    test('New Year runs Dec 31 through Jan 2', () {
      expect(seasonalThemeFor(DateTime(2026, 12, 31)), SeasonalTheme.newYear);
      expect(seasonalThemeFor(DateTime(2027, 1, 1, 12)), SeasonalTheme.newYear);
      expect(seasonalThemeFor(DateTime(2027, 1, 2, 23, 59)), SeasonalTheme.newYear);
    });

    test('ends New Year on Jan 3', () {
      expect(seasonalThemeFor(DateTime(2027, 1, 3)), SeasonalTheme.none);
    });
  });

  test('New Year shows fireworks and party poppers, at the larger size', () {
    expect(SeasonalTheme.newYear.icons, [SeasonalIconKind.fireworks, SeasonalIconKind.partyPopper]);
    expect(SeasonalTheme.newYear.iconSize, 36);
  });
}
