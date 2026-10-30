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

void main() {
  group('AppPalette.light', () {
    test('is exactly AppColors, so the rider app looks unchanged', () {
      const p = AppPalette.light;
      expect(p.white000, AppColors.white000);
      expect(p.black900, AppColors.black900);
      expect(p.grey012, AppColors.grey012);
      expect(p.grey500, AppColors.grey500);
      expect(p.textPrimary, AppColors.textPrimary);
      expect(p.errorColor, AppColors.errorColor);
      expect(p.bgMuted, AppColors.bgMuted);
      expect(p.white, Colors.white);
      expect(p.black, Colors.black);
    });
  });

  group('AppPalette.driverLight', () {
    test('keeps the driver-only values of DriverAppColor', () {
      const p = AppPalette.driverLight;
      expect(p.grey012, DriverAppColor.grey012);
      expect(p.errorColor, DriverAppColor.errorColor);
      expect(p.grey444, DriverAppColor.grey444);
      expect(p.white000, DriverAppColor.white000);
      expect(p.grey500, DriverAppColor.grey500);
    });
  });

  group('AppPalette.dark', () {
    const d = AppPalette.dark;

    test('page and card backgrounds are dark', () {
      for (final bg in [
        d.white000,
        d.white,
        d.bgColor,
        d.grey012,
        d.grey025,
        d.bgMuted,
        d.greyColor,
        d.buttonBackgroundColor,
        d.textFormFieldBackgroundColor,
        d.warningAlertsBackgroundColor,
        d.criticalAlertsBackgroundColor,
        d.blue050,
        d.orange050,
      ]) {
        expect(bg.computeLuminance(), lessThan(0.05), reason: '$bg');
      }
    });

    test('text colours meet WCAG AA (4.5:1) on dark backgrounds', () {
      for (final bg in [d.white000, d.bgColor, d.grey012, d.grey025]) {
        for (final fg in [
          d.black900,
          d.black,
          d.textPrimary,
          d.textSecondary,
          d.grey500,
          d.grey600,
          d.grey700,
          d.grey800,
          d.grey900,
          d.grey444,
          d.unKnownTextColor,
          d.textMuted61,
          d.textMuted2,
          d.iconMuted,
          d.errorColor,
          d.criticalAlertIconColor,
          d.logoutIconAndTextColors,
          d.textColor,
          d.lightBlue,
          d.recommededNextStep,
          d.warningColorsStringColors,
          d.grey300,
          d.textMuted,
        ]) {
          expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: '$fg on $bg');
        }
      }
    });

    test('locked/disabled grey stays legible (3:1) on dark backgrounds', () {
      for (final bg in [d.white000, d.bgColor, d.grey012, d.grey025]) {
        expect(_contrast(d.grey200, bg), greaterThanOrEqualTo(3), reason: 'grey200 on $bg');
      }
    });

    test('dividers and borders differ from the card colour', () {
      for (final line in [d.grey100, d.grey200, d.grey300, d.grey400]) {
        expect(_contrast(line, d.white000), greaterThanOrEqualTo(1.3), reason: '$line');
      }
    });
  });

  group('context.colors', () {
    Future<AppPalette> read(WidgetTester tester, ThemeData? theme) async {
      late AppPalette p;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(builder: (context) {
            p = context.colors;
            return const SizedBox();
          }),
        ),
      );
      return p;
    }

    testWidgets('reads the palette from the theme', (tester) async {
      expect(await read(tester, ThemeData(extensions: const [AppPalette.dark])), AppPalette.dark);
    });

    testWidgets('falls back to light without the extension', (tester) async {
      expect(await read(tester, null), AppPalette.light);
    });
  });

  test('lerp snaps to the nearer end', () {
    expect(AppPalette.light.lerp(AppPalette.dark, 0.4), AppPalette.light);
    expect(AppPalette.light.lerp(AppPalette.dark, 0.6), AppPalette.dark);
    expect(AppPalette.light.lerp(null, 0.6), AppPalette.light);
  });

  group('status colours', () {
    test('success and warning read on the page background in light and dark', () {
      for (final p in [AppPalette.light, AppPalette.driverLight, AppPalette.dark]) {
        expect(_contrast(p.successColor, p.white000), greaterThanOrEqualTo(4.5));
        expect(_contrast(p.warningColor, p.white000), greaterThanOrEqualTo(4.5));
      }
    });

    test('keep their meaning: success is green and warning amber in every palette', () {
      for (final p in [AppPalette.light, AppPalette.dark]) {
        final success = HSVColor.fromColor(p.successColor).hue;
        final warning = HSVColor.fromColor(p.warningColor).hue;
        expect(success, inInclusiveRange(90, 160));
        expect(warning, inInclusiveRange(25, 50));
      }
    });
  });

  group('festive page backgrounds', () {
    const pages = {
      SeasonalTheme.halloween: (Color(0xFFFFF9F2), Color(0xFFFFF1E0), Color(0xFF1F140F), Color(0xFF150D09)),
      SeasonalTheme.christmas: (Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFF0F1A14), Color(0xFF09110D)),
      SeasonalTheme.newYear: (Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFF12111F), Color(0xFF0B0A15)),
    };

    // Text and icon colours a screen draws on its page background.
    List<Color> textColours(AppPalette p) => [
          p.black900, p.black, p.textPrimary, p.textSecondary, p.textMuted, p.textMuted61, p.textMuted2,
          p.grey500, p.grey600, p.grey700, p.grey800, p.grey900, p.grey444, p.unKnownTextColor, p.iconMuted,
          p.errorColor, p.textColor, p.logoutIconAndTextColors, p.criticalAlertIconColor, p.lightBlue,
          p.recommededNextStep, p.warningColorsStringColors, p.successColor, p.warningColor,
        ];

    test('out of season the pages stay exactly as they are', () {
      for (final (base, dark) in [(AppPalette.light, false), (AppPalette.driverLight, false), (AppPalette.dark, true)]) {
        expect(identical(base.forSeason(SeasonalTheme.none, dark: dark), base), isTrue);
      }
    });

    for (final MapEntry(key: season, value: (light, lightBg, dark, darkBg)) in pages.entries) {
      test('${season.name}: pages take the festive tint, everything else stays', () {
        final l = AppPalette.light.forSeason(season, dark: false);
        final d = AppPalette.dark.forSeason(season, dark: true);
        expect((l.white000, l.bgColor, d.white000, d.bgColor), (light, lightBg, dark, darkBg));
        for (final (festive, base) in [(l, AppPalette.light), (d, AppPalette.dark)]) {
          expect(festive.white, base.white, reason: 'white is also text on buttons');
          expect(textColours(festive), textColours(base));
          expect(festive.grey025, base.grey025);
        }
        expect(AppPalette.driverLight.forSeason(season, dark: false).grey012, AppPalette.driverLight.grey012);
      });

      test('${season.name}: text that reads on the normal page still reads on the festive one', () {
        for (final (base, dark) in [(AppPalette.light, false), (AppPalette.dark, true)]) {
          final festive = base.forSeason(season, dark: dark);
          for (final (page, festivePage) in [(base.white000, festive.white000), (base.bgColor, festive.bgColor)]) {
            for (final fg in textColours(base)) {
              if (_contrast(fg, page) < 4.5) continue; // already a non-text colour on this page
              expect(_contrast(fg, festivePage), greaterThanOrEqualTo(4.5), reason: '$season dark=$dark $fg');
            }
          }
        }
      });

      test('${season.name}: the season\'s brand text reads on its festive page', () {
        for (final (brand, page) in [
          (BrandColors.forSeason(season), AppPalette.light.forSeason(season, dark: false).white000),
          (BrandColors.forSeason(season, dark: true), AppPalette.dark.forSeason(season, dark: true).white000),
        ]) {
          for (final fg in [brand.green700, brand.green600, brand.greenButton, brand.primaryColor, brand.brandPrimary]) {
            expect(_contrast(fg, page), greaterThanOrEqualTo(4.5), reason: '$season $fg on $page');
          }
        }
      });

      test('${season.name}: the app theme paints festive pages, light and dark', () {
        for (final (theme, page) in [
          (AppTheme.light(season: season), light),
          (AppTheme.dark(season: season), dark),
        ]) {
          expect(theme.scaffoldBackgroundColor, page);
          expect(theme.colorScheme.surface, page);
          expect(theme.appBarTheme.backgroundColor, page);
          expect(theme.extension<AppPalette>()!.white000, page);
        }
      });
    }
  });
}

