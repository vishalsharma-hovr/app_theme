import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

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

/// WCAG contrast between two `#rrggbb` colours.
double _hexContrast(String a, String b) {
  final la = _hexLuminance(a);
  final lb = _hexLuminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// The rules of map style [file].
List<Map<String, dynamic>> _rules(String file) => (jsonDecode(
      File('assets/map_styles/$file.json').readAsStringSync(),
    ) as List<dynamic>)
        .cast<Map<String, dynamic>>();

/// Every `color` styler in [rules] whose element is one of [elements] and
/// whose feature starts with [featurePrefix].
List<String> _colours(List<Map<String, dynamic>> rules, String featurePrefix, Set<String> elements) => [
      for (final rule in rules)
        if (((rule['featureType'] as String?) ?? 'all').startsWith(featurePrefix) &&
            elements.contains(rule['elementType'] ?? 'all'))
          for (final styler in (rule['stylers'] as List<dynamic>))
            if ((styler as Map<String, dynamic>)['color'] case final String hex) hex.toLowerCase(),
    ];

/// The festive map styles.
const _festiveFiles = ['halloween', 'christmas', 'christmas_dark', 'new_year'];

/// The route line colour: HOVR green in every season (no outline is drawn).
final _route = '#${(BrandColors.standard.primaryColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

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

  test('Christmas has a snowy-night map in dark mode and the snowy map in light', () {
    const light = 'packages/app_theme/assets/map_styles/christmas.json';
    const dark = 'packages/app_theme/assets/map_styles/christmas_dark.json';
    String? asset(ThemeMode mode, Brightness device) =>
        mapStyleAsset(mode: mode, platformBrightness: device, season: SeasonalTheme.christmas);
    expect(asset(ThemeMode.light, Brightness.dark), light);
    expect(asset(ThemeMode.dark, Brightness.light), dark);
    expect(asset(ThemeMode.system, Brightness.dark), dark);
    expect(asset(ThemeMode.system, Brightness.light), light);
    expect(mapStyleAssets, contains(dark));
  });

  group('festive map personalities', () {
    test('every label reads on its outline (WCAG AA 4.5:1)', () {
      for (final file in _festiveFiles) {
        final rules = _rules(file);
        final allStroke = _colours(rules, 'all', {'labels.text.stroke'}).first;
        for (final rule in rules.where((r) => r['elementType'] == 'labels.text.fill')) {
          final feature = (rule['featureType'] as String?) ?? 'all';
          final stroke = _styler(file, feature, 'labels.text.stroke', 'color') ?? allStroke;
          for (final fill in _colours([rule], '', {'labels.text.fill'})) {
            expect(_hexContrast(fill, stroke), greaterThanOrEqualTo(4.5), reason: '$file $feature $fill on $stroke');
          }
        }
      }
    });

    test('the HOVR green route stands out on every road (3:1)', () {
      for (final file in _festiveFiles) {
        for (final road in _colours(_rules(file), 'road', {'all', 'geometry', 'geometry.fill'})) {
          expect(_hexContrast(_route, road), greaterThanOrEqualTo(3), reason: '$file road $road');
        }
      }
    });

    test('no two festive maps share a highway, park or water colour', () {
      for (final (feature, elements) in [
        ('road.highway', {'geometry', 'geometry.fill'}),
        ('poi.park', {'geometry'}),
        ('water', {'geometry'}),
      ]) {
        final seen = <String, String>{};
        for (final file in _festiveFiles) {
          for (final hex in _colours(_rules(file), feature, elements).toSet()) {
            expect(seen[hex], isNull, reason: '$feature $hex in $file and ${seen[hex]}');
            seen[hex] = file;
          }
        }
      }
    });

    test('Halloween and New Year are built differently, not recoloured copies', () {
      Set<String> shape(String file) =>
          {for (final r in _rules(file)) '${r['featureType'] ?? 'all'}/${r['elementType'] ?? 'all'}'};
      expect(shape('halloween'), isNot(shape('new_year')));
    });

    test('Halloween has slime-green parks; New Year lights up transit lines', () {
      final park = HSVColor.fromColor(Color(int.parse('ff${_styler('halloween', 'poi.park', 'geometry', 'color')!.substring(1)}', radix: 16)));
      expect(park.hue, inInclusiveRange(75, 120));
      expect(_hexLuminance(_styler('new_year', 'transit.line', 'geometry', 'color')!), greaterThan(0.3));
    });

    test('the snowy-night map is dark, with pale snowy roads', () {
      expect(_hexLuminance(_colours(_rules('christmas_dark'), 'all', {'geometry'}).first), lessThan(0.15));
      expect(_hexLuminance(_styler('christmas_dark', 'water', 'geometry', 'color')!), lessThan(0.15));
      expect(_hexLuminance(_styler('christmas_dark', 'road.local', 'geometry.fill', 'color')!), greaterThan(0.6));
    });

    test('doc/festive_colors.md lists each map\'s land, highway, park and water colours', () {
      final doc = File('doc/festive_colors.md').readAsStringSync().toLowerCase();
      for (final file in _festiveFiles) {
        final rules = _rules(file);
        for (final hex in {
          _colours(rules, 'all', {'geometry'}).first,
          ..._colours(rules, 'road.highway', {'geometry', 'geometry.fill'}),
          ..._colours(rules, 'poi.park', {'geometry'}),
          ..._colours(rules, 'water', {'geometry'}),
        }) {
          expect(doc, contains(hex), reason: '$file $hex');
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
    for (final file in _festiveFiles) {
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

