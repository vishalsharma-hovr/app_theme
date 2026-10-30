import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every `#rrggbb` colour in a map-style JSON asset.
List<Color> _styleColors(String file) => RegExp(r'#([0-9a-fA-F]{6})')
    .allMatches(File('assets/map_styles/$file').readAsStringSync())
    .map((m) => Color(0xFF000000 | int.parse(m.group(1)!, radix: 16)))
    .toList();

bool _isRed(Color c) {
  final hsv = HSVColor.fromColor(c);
  return hsv.saturation > 0.4 && (hsv.hue < 15 || hsv.hue >= 345);
}

void main() {
  test('Christmas maps have no red: the palette keeps red for errors', () {
    for (final file in ['christmas.json', 'christmas_dark.json']) {
      expect(_styleColors(file).where(_isRed), isEmpty, reason: file);
    }
  });
}
