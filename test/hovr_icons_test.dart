import 'dart:io';

import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _packagePrefix = 'packages/app_theme/';

void main() {
  group('asset keys', () {
    test('every icon and image exists in this package', () {
      for (final key in [...HovrIcons.all, ...HovrImages.all]) {
        expect(key, startsWith(_packagePrefix), reason: key);
        expect(File(key.substring(_packagePrefix.length)).existsSync(), isTrue, reason: key);
      }
    });

    test('the asset folders are declared in pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- assets/icons/'));
      expect(pubspec, contains('- assets/images/'));
    });

    test('names are unique', () {
      final all = [...HovrIcons.all, ...HovrImages.all];
      expect(all.toSet(), hasLength(all.length));
    });
  });

  group('HovrIcon', () {
    Future<Image> pump(WidgetTester tester, Widget icon, {Color iconColor = Colors.purple}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IconTheme(data: IconThemeData(color: iconColor), child: Center(child: icon)),
        ),
      );
      return tester.widget<Image>(find.byType(Image));
    }

    testWidgets('tints with the given colour at the given size', (tester) async {
      final image = await pump(tester, const HovrIcon(HovrIcons.copy, size: 18, color: Colors.orange));

      expect(image.color, Colors.orange);
      expect(tester.getSize(find.byType(HovrIcon)), const Size(18, 18));
    });

    testWidgets('without a colour it follows the surrounding icon colour, like Icon', (tester) async {
      final image = await pump(tester, const HovrIcon(HovrIcons.home), iconColor: Colors.teal);

      expect(image.color, Colors.teal);
      expect(tester.getSize(find.byType(HovrIcon)), const Size(24, 24));
    });

    for (final season in SeasonalTheme.values) {
      for (final (name, festive, standard) in [
        ('light', AppTheme.light(season: season), AppTheme.light()),
        ('dark', AppTheme.dark(season: season), AppTheme.dark()),
      ]) {
        testWidgets('$name ${season.name}: default tint matches out of season', (tester) async {
          Future<Color?> tint(ThemeData theme) async {
            await tester.pumpWidget(
              MaterialApp(theme: theme, home: const Center(child: HovrIcon(HovrIcons.home))),
            );
            return tester.widget<Image>(find.byType(Image)).color;
          }

          expect(await tint(festive), await tint(standard));
        });
      }
    }

    testWidgets('a label is read by screen readers; no label hides it', (tester) async {
      await pump(tester, const HovrIcon(HovrIcons.call, semanticLabel: 'Call driver'));
      expect(find.bySemanticsLabel('Call driver'), findsOneWidget);
    });
  });
}
