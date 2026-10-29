import 'dart:convert';
import 'dart:io';

import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reads a `packages/app_theme/...` asset key from this package's own folder.
File _file(String assetKey) =>
    File(assetKey.replaceFirst('packages/app_theme/', ''));

/// The first [key] styler value for [feature]/[element] in map style [file].
String? _styler(String file, String feature, String element, String key) {
  final rules = (jsonDecode(
    File('assets/map_styles/$file.json').readAsStringSync(),
  ) as List<dynamic>).cast<Map<String, dynamic>>();
  for (final rule in rules) {
    if (rule['featureType'] != feature || rule['elementType'] != element) {
      continue;
    }
    for (final entry in (rule['stylers'] as List<dynamic>)) {
      final value = (entry as Map<String, dynamic>)[key];
      if (value != null) return value as String;
    }
  }
  return null;
}

double _hexLuminance(String hex) =>
    Color(int.parse('ff${hex.substring(1)}', radix: 16)).computeLuminance();

void main() {
  group('mapStyleAsset', () {
    test('light mode outside a season uses the default Google style', () {
      expect(
        mapStyleAsset(
          mode: ThemeMode.light,
          platformBrightness: Brightness.dark,
          season: SeasonalTheme.none,
        ),
        isNull,
      );
    });

    test('dark mode uses the dark style', () {
      expect(
        mapStyleAsset(
          mode: ThemeMode.dark,
          platformBrightness: Brightness.light,
          season: SeasonalTheme.none,
        ),
        'packages/app_theme/assets/map_styles/dark.json',
      );
    });

    test('system mode follows the device brightness', () {
      expect(
        mapStyleAsset(
          mode: ThemeMode.system,
          platformBrightness: Brightness.dark,
          season: SeasonalTheme.none,
        ),
        'packages/app_theme/assets/map_styles/dark.json',
      );
      expect(
        mapStyleAsset(
          mode: ThemeMode.system,
          platformBrightness: Brightness.light,
          season: SeasonalTheme.none,
        ),
        isNull,
      );
    });

    test('a festive season wins over light and dark mode', () {
      const expected = {
        SeasonalTheme.halloween:
            'packages/app_theme/assets/map_styles/halloween.json',
        SeasonalTheme.christmas:
            'packages/app_theme/assets/map_styles/christmas.json',
        SeasonalTheme.newYear:
            'packages/app_theme/assets/map_styles/new_year.json',
      };
      for (final MapEntry(key: season, value: asset) in expected.entries) {
        for (final mode in ThemeMode.values) {
          expect(
            mapStyleAsset(
              mode: mode,
              platformBrightness: Brightness.dark,
              season: season,
            ),
            asset,
            reason: '$season in $mode',
          );
        }
      }
    });
  });

  test('every map style file is a JSON list of style rules', () {
    for (final asset in mapStyleAssets) {
      final decoded = jsonDecode(_file(asset).readAsStringSync());
      expect(decoded, isA<List<dynamic>>(), reason: asset);
      expect(decoded, isNotEmpty, reason: asset);
    }
  });

  test('festive maps hide business pins to cut clutter for drivers', () {
    for (final file in ['halloween', 'christmas', 'new_year']) {
      expect(_styler(file, 'poi.business', 'all', 'visibility'), 'off',
          reason: file);
    }
  });

  test('festive maps keep main roads distinct from side streets', () {
    for (final file in ['halloween', 'new_year']) {
      final arterial = _styler(file, 'road.arterial', 'geometry', 'color');
      expect(arterial, isNotNull, reason: file);
      expect(arterial, isNot(_styler(file, 'road', 'geometry', 'color')),
          reason: file);
    }
  });

  group('christmas map style', () {
    String? styler(String feature, String element, String key) =>
        _styler('christmas', feature, element, key);

    test('highways are white with pine edges; red stays the error colour', () {
      expect(styler('road.highway', 'geometry.fill', 'color'), '#ffffff');
      expect(styler('road.highway', 'geometry.stroke', 'color'), '#15803d');
    });

    test('parks and water look frosted, not dark green or deep blue', () {
      for (final feature in ['poi.park', 'water']) {
        expect(_hexLuminance(styler(feature, 'geometry', 'color')!),
            greaterThan(0.6),
            reason: feature);
      }
    });

    test('park labels stay readable on frosted parks', () {
      expect(_hexLuminance(styler('poi.park', 'labels.text.fill', 'color')!),
          lessThan(0.2));
    });
  });

  test('the dark map style uses light label text', () {
    // Festive dark styles keep their themed orange/gold labels on purpose.
    for (final asset in ['packages/app_theme/assets/map_styles/dark.json']) {
      final rules =
          (jsonDecode(_file(asset).readAsStringSync()) as List<dynamic>)
              .cast<Map<String, dynamic>>();
      for (final rule in rules) {
        if (rule['elementType'] != 'labels.text.fill') continue;
        for (final styler in (rule['stylers'] as List<dynamic>)) {
          final hex = (styler as Map<String, dynamic>)['color'] as String?;
          if (hex == null) continue;
          final color = Color(int.parse('ff${hex.substring(1)}', radix: 16));
          expect(
            color.computeLuminance(),
            greaterThan(0.5),
            reason: '$asset ${rule['featureType'] ?? 'all'} $hex',
          );
        }
      }
    }
  });

  test('the Christmas map style has no Halloween orange or New Year gold', () {
    final rules = (jsonDecode(
      _file('packages/app_theme/assets/map_styles/christmas.json').readAsStringSync(),
    ) as List<dynamic>).cast<Map<String, dynamic>>();
    for (final rule in rules) {
      for (final styler in (rule['stylers'] as List<dynamic>)) {
        final hex = (styler as Map<String, dynamic>)['color'] as String?;
        if (hex == null) continue;
        final hsv = HSVColor.fromColor(
          Color(int.parse('ff${hex.substring(1)}', radix: 16)),
        );
        final orangeOrGold =
            hsv.saturation > 0.4 && hsv.hue >= 15 && hsv.hue <= 60;
        expect(orangeOrGold, isFalse, reason: '$hex in ${rule['featureType']}');
      }
    }
  });
}

