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
  test('light and dark have the matching brightness', () {
    expect(AppTheme.light().brightness, Brightness.light);
    expect(AppTheme.light().colorScheme.brightness, Brightness.light);
    expect(AppTheme.dark().brightness, Brightness.dark);
    expect(AppTheme.dark().colorScheme.brightness, Brightness.dark);
  });

  test('light primary is the exact HOVR green on a white surface', () {
    final t = AppTheme.light();
    expect(t.colorScheme.primary, BrandColors.standard.primaryColor);
    expect(t.colorScheme.onPrimary, Colors.white);
    expect(t.colorScheme.surface, AppColors.white000);
    expect(t.scaffoldBackgroundColor, AppColors.white000);
    expect(t.appBarTheme.backgroundColor, AppColors.white000);
    expect(t.appBarTheme.scrolledUnderElevation, 0);
  });

  test('attaches the palette and the HOVR brand for the given brightness', () {
    expect(AppTheme.light().extension<AppPalette>(), AppPalette.light);
    expect(AppTheme.light(palette: AppPalette.driverLight).extension<AppPalette>(), AppPalette.driverLight);
    expect(AppTheme.dark().extension<AppPalette>(), AppPalette.dark);
    for (final season in SeasonalTheme.values) {
      expect(AppTheme.light(season: season).extension<BrandColors>(), BrandColors.forSeason(season));
      expect(
        AppTheme.dark(season: season).extension<BrandColors>(),
        BrandColors.forSeason(season, dark: true),
      );
    }
  });

  test('festive Material primary is exactly the season\'s brand colour, light and dark', () {
    for (final season in SeasonalTheme.values.where((s) => s != SeasonalTheme.none)) {
      expect(AppTheme.light(season: season).colorScheme.primary, BrandColors.forSeason(season).primaryColor);
      expect(
        AppTheme.dark(season: season).colorScheme.primary,
        BrandColors.forSeason(season, dark: true).primaryColor,
      );
    }
  });

  test('dark primary is the same exact HOVR green as light, with white on it', () {
    final s = AppTheme.dark().colorScheme;
    expect(s.primary, BrandColors.standard.primaryColor);
    expect(s.onPrimary, Colors.white);
  });

  test('dark theme uses the dark palette for surfaces and text', () {
    final t = AppTheme.dark();
    expect(t.scaffoldBackgroundColor, AppPalette.dark.white000);
    expect(t.colorScheme.surface, AppPalette.dark.white000);
    expect(t.colorScheme.onSurface, AppPalette.dark.black900);
    expect(t.appBarTheme.backgroundColor, AppPalette.dark.white000);
    expect(t.appBarTheme.foregroundColor, AppPalette.dark.black900);
  });

  for (final season in SeasonalTheme.values) {
    for (final MapEntry(key: name, value: theme) in {
      'light': AppTheme.light(season: season),
      'dark': AppTheme.dark(season: season),
    }.entries) {
      test('$name ${season.name}: text, brand and error meet WCAG AA', () {
        final s = theme.colorScheme;
        // HOVR green is fixed; on dark it meets the 3:1 AA level for buttons and icons.
        final minPrimary = name == 'dark' && season == SeasonalTheme.none ? 3.0 : 4.5;
        for (final bg in [s.surface, theme.scaffoldBackgroundColor]) {
          expect(_contrast(s.onSurface, bg), greaterThanOrEqualTo(4.5));
          expect(_contrast(s.onSurfaceVariant, bg), greaterThanOrEqualTo(4.5));
          expect(_contrast(s.primary, bg), greaterThanOrEqualTo(minPrimary));
          expect(_contrast(s.error, bg), greaterThanOrEqualTo(4.5));
        }
        expect(_contrast(s.onPrimary, s.primary), greaterThanOrEqualTo(4.5));
      });
    }
  }

  group('MaterialApp integration', () {
    Widget app(ThemeMode mode) => MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Title')),
              body: ColoredBox(
                color: context.colors.white000,
                child: Text('${Theme.of(context).brightness}'),
              ),
            ),
          ),
        );

    testWidgets('follows the phone setting in system mode', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(app(ThemeMode.system));
      expect(find.text('${Brightness.dark}'), findsOneWidget);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(find.text('${Brightness.light}'), findsOneWidget);
      expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox).last).color,
        AppPalette.light.white000,
      );
    });

    testWidgets('paints the dark scaffold, app bar and palette colours', (tester) async {
      await tester.pumpWidget(app(ThemeMode.dark));

      final scaffold = tester.widget<Material>(
        find.descendant(of: find.byType(Scaffold), matching: find.byType(Material)).first,
      );
      expect(scaffold.color, AppPalette.dark.white000);
      final appBar = tester.widget<Material>(
        find.descendant(of: find.byType(AppBar), matching: find.byType(Material)).first,
      );
      expect(appBar.color, AppPalette.dark.white000);
      expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox).last).color,
        AppPalette.dark.white000,
      );
    });
  });
}
