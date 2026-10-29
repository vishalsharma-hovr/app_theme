import 'dart:math' as math;

import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG relative contrast between [a] and [b].
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Tokens used for buttons, icons and text on white: must stay readable.
List<Color> _strongTokens(BrandColors c) => [
  c.green056,
  c.green400,
  c.green500,
  c.green600,
  c.green700,
  c.green800,
  c.greenButton,
  c.primaryColor,
  c.brandPrimary,
];


/// Every token of [c].
List<Color> _allTokens(BrandColors c) => [
  c.green012,
  c.green025,
  c.green050,
  c.green056,
  c.green100,
  c.green200,
  c.green300,
  c.green400,
  c.green500,
  c.green600,
  c.green700,
  c.green800,
  c.green900,
  c.greenButton,
  c.primaryColor,
  c.brandPrimary,
];

/// Clearly coloured tokens (not near-white or near-black) whose hue lies in
/// [from, to] degrees: e.g. Halloween orange 15–35, New Year gold 40–60.
List<Color> _inHue(BrandColors c, double from, double to) => [
  for (final colour in _allTokens(c))
    if (HSVColor.fromColor(colour) case final hsv
        when hsv.saturation > 0.4 &&
            hsv.value > 0.3 &&
            hsv.hue >= from &&
            hsv.hue <= to)
      colour,
];

void main() {
  group('BrandColors.standard', () {
    test(
      'is exactly the existing app_theme greens (no change out of season)',
      () {
        const s = BrandColors.standard;
        expect(s.green012, DriverAppColor.green012);
        expect(s.green025, DriverAppColor.green025);
        expect(s.green050, DriverAppColor.green050);
        expect(s.green056, DriverAppColor.green056);
        expect(s.green100, DriverAppColor.green100);
        expect(s.green200, DriverAppColor.green200);
        expect(s.green300, DriverAppColor.green300);
        expect(s.green400, DriverAppColor.green400);
        expect(s.green500, DriverAppColor.green500);
        expect(s.green600, DriverAppColor.green600);
        expect(s.green700, DriverAppColor.green700);
        expect(s.green800, DriverAppColor.green800);
        expect(s.green900, DriverAppColor.green900);
        expect(s.greenButton, DriverAppColor.greenButton);
        expect(s.primaryColor, DriverAppColor.primaryColor);
        expect(s.brandPrimary, DriverAppColor.brandPrimary);
      },
    );
  });

  group('BrandColors.forSeason', () {
    test('maps each season to its palette', () {
      expect(BrandColors.forSeason(SeasonalTheme.none), BrandColors.standard);
      expect(
        BrandColors.forSeason(SeasonalTheme.halloween),
        BrandColors.halloween,
      );
      expect(
        BrandColors.forSeason(SeasonalTheme.christmas),
        BrandColors.christmas,
      );
      expect(BrandColors.forSeason(SeasonalTheme.newYear), BrandColors.newYear);
    });

    test('seasonal palettes actually differ from the standard one', () {
      expect(
        BrandColors.halloween.greenButton,
        isNot(BrandColors.standard.greenButton),
      );
      expect(
        BrandColors.christmas.greenButton,
        isNot(BrandColors.standard.greenButton),
      );
      expect(BrandColors.newYear.greenButton, isNot(BrandColors.standard.greenButton));
      expect(BrandColors.newYear.greenButton, isNot(BrandColors.christmas.greenButton));
    });

    for (final season in SeasonalTheme.values) {
      test('${season.name}: strong tokens meet WCAG AA (4.5:1) on white', () {
        for (final color in _strongTokens(BrandColors.forSeason(season))) {
          expect(
            _contrast(color, Colors.white),
            greaterThanOrEqualTo(4.5),
            reason: '$color on white',
          );
        }
      });
    }
  });

  group('ThemeExtension contract', () {
    test('lerp returns the endpoints at 0 and 1', () {
      const a = BrandColors.standard;
      const b = BrandColors.halloween;
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
    });

    test('lerp with a non-BrandColors keeps itself', () {
      expect(BrandColors.halloween.lerp(null, 0.5), BrandColors.halloween);
    });

    test('copyWith replaces only the given token', () {
      final c = BrandColors.standard.copyWith(greenButton: Colors.purple);
      expect(c.greenButton, Colors.purple);
      expect(c.green700, BrandColors.standard.green700);
    });
  });

  group('context.brand', () {
    testWidgets('reads the palette from the theme', (tester) async {
      late BrandColors read;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [BrandColors.christmas]),
          home: Builder(
            builder: (context) {
              read = context.brand;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(read, BrandColors.christmas);
    });

    testWidgets('falls back to standard without the extension', (tester) async {
      late BrandColors read;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              read = context.brand;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(read, BrandColors.standard);
    });
  });

  group('BrandColors.dark', () {
    test('mirrors the scale: light tints become dark, strong greens light', () {
      const s = BrandColors.standard;
      final d = s.dark;
      expect(d.green012, s.green800);
      expect(d.green050, s.green600);
      expect(d.green400, s.green200);
      expect(d.green700, s.green025);
      expect(d.green900, s.green012);
      expect(d.greenButton, s.green200);
      expect(d.brandPrimary, s.green200);
    });

    for (final season in SeasonalTheme.values) {
      test('${season.name}: strong tokens meet WCAG AA on the dark surface', () {
        for (final bg in [AppPalette.dark.white000, AppPalette.dark.bgColor]) {
          for (final color in _strongTokens(BrandColors.forSeason(season).dark)) {
            expect(_contrast(color, bg), greaterThanOrEqualTo(4.5), reason: '$color on $bg');
          }
        }
      });
    }
  });

  group('festive palettes keep to their own colours', () {
    const seasons = {
      'halloween': BrandColors.halloween,
      'christmas': BrandColors.christmas,
      'newYear': BrandColors.newYear,
    };

    test('no two festive seasons share a colour', () {
      for (final MapEntry(key: a, value: ca) in seasons.entries) {
        for (final MapEntry(key: b, value: cb) in seasons.entries) {
          if (a.compareTo(b) >= 0) continue;
          final shared = _allTokens(ca).toSet().intersection(_allTokens(cb).toSet());
          expect(shared, isEmpty, reason: '$a and $b share $shared');
        }
      }
    });

    test('Christmas has no Halloween orange or New Year gold', () {
      expect(_inHue(BrandColors.christmas, 15, 60), isEmpty);
    });

    test('New Year has no Halloween orange', () {
      expect(_inHue(BrandColors.newYear, 15, 35), isEmpty);
    });

    test('Halloween has no New Year gold', () {
      expect(_inHue(BrandColors.halloween, 40, 60), isEmpty);
    });
  });
}

