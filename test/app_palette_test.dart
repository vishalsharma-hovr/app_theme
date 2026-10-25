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
        ]) {
          expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: '$fg on $bg');
        }
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
}
