import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  // Compositions are cached app-wide; start each test before anything loaded.
  setUp(Lottie.cache.clear);

  group('SeasonalTheme.icons', () {
    test('none has no icons', () {
      expect(SeasonalTheme.none.icons, isEmpty);
    });

    test('Halloween has a pumpkin and a bat', () {
      expect(SeasonalTheme.halloween.icons, [
        SeasonalIconKind.pumpkin,
        SeasonalIconKind.bat,
      ]);
    });

    test('Christmas has a snowflake and a tree', () {
      expect(SeasonalTheme.christmas.icons, [
        SeasonalIconKind.snowflake,
        SeasonalIconKind.tree,
      ]);
    });
  });

  for (final kind in SeasonalIconKind.values) {
    testWidgets('${kind.name} paints at its size without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: SeasonalIcon(kind: kind, size: 32)),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(SeasonalIcon)), const Size.square(32));
    });
  }

  test('repaints only when the kind changes', () {
    final a = SeasonalIconPainter(SeasonalIconKind.bat);
    expect(a.shouldRepaint(SeasonalIconPainter(SeasonalIconKind.bat)), isFalse);
    expect(
      a.shouldRepaint(SeasonalIconPainter(SeasonalIconKind.pumpkin)),
      isTrue,
    );
  });

  test('repaints when the brightness changes', () {
    final a = SeasonalIconPainter(SeasonalIconKind.bat);
    expect(a.shouldRepaint(SeasonalIconPainter(SeasonalIconKind.bat, dark: true)), isTrue);
  });

  test('bat stays visible on the dark surface (3:1)', () {
    double contrast(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
    }

    final dark = SeasonalIconPainter(SeasonalIconKind.bat, dark: true).batColor;
    expect(contrast(dark, AppPalette.dark.white000), greaterThanOrEqualTo(3));
    final light = SeasonalIconPainter(SeasonalIconKind.bat).batColor;
    expect(contrast(light, AppPalette.light.white000), greaterThanOrEqualTo(3));
  });

  testWidgets('SeasonalIcon picks the dark colours from a dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const SeasonalIcon(kind: SeasonalIconKind.bat, size: 24),
      ),
    );
    final paint = tester.widget<CustomPaint>(
      find.descendant(of: find.byType(SeasonalIcon), matching: find.byType(CustomPaint)),
    );
    expect((paint.painter! as SeasonalIconPainter).dark, isTrue);
  });

  group('Lottie animations', () {
    test('every kind has a bundled animation that decodes', () async {
      for (final kind in SeasonalIconKind.values) {
        final bytes = File('assets/lottie/${SeasonalIcon.assetFor(kind)}').readAsBytesSync();
        final composition = await LottieComposition.fromBytes(bytes);
        expect(composition.duration, greaterThan(Duration.zero), reason: kind.name);
      }
    });

    testWidgets('each kind plays its own animation from this package', (tester) async {
      for (final kind in SeasonalIconKind.values) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SeasonalIcon(kind: kind, size: 24),
          ),
        );
        final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder)).lottie as AssetLottie;
        expect(lottie.assetName, 'assets/lottie/${SeasonalIcon.assetFor(kind)}');
        expect(lottie.package, 'app_theme');
      }
    });

    testWidgets('shows the drawn icon until the animation loads', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SeasonalIcon(kind: SeasonalIconKind.pumpkin, size: 24),
        ),
      );
      final painters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((p) => p.painter)
          .whereType<SeasonalIconPainter>();
      expect(painters.single.kind, SeasonalIconKind.pumpkin);
    });

    testWidgets('renders the animation once loaded', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SeasonalIcon(kind: SeasonalIconKind.tree, size: 24),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
      await tester.pump();
      expect(find.byType(RawLottie), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stays still when reduce motion is on', (tester) async {
      Future<bool?> animate(bool disable) async {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(disableAnimations: disable),
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: SeasonalIcon(kind: SeasonalIconKind.bat, size: 24),
            ),
          ),
        );
        return tester.widget<LottieBuilder>(find.byType(LottieBuilder)).animate;
      }

      expect(await animate(true), isFalse);
      expect(await animate(false), isTrue);
    });

    testWidgets('recolours only the bat, and only on dark backgrounds', (tester) async {
      Future<LottieDelegates?> delegates(SeasonalIconKind kind, Brightness b) async {
        await tester.pumpWidget(
          Theme(
            data: ThemeData(brightness: b),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SeasonalIcon(kind: kind, size: 24),
            ),
          ),
        );
        return tester.widget<LottieBuilder>(find.byType(LottieBuilder)).delegates;
      }

      expect(await delegates(SeasonalIconKind.bat, Brightness.dark), isNotNull);
      expect(await delegates(SeasonalIconKind.bat, Brightness.light), isNull);
      expect(await delegates(SeasonalIconKind.pumpkin, Brightness.dark), isNull);
    });

    test('dark-mode bat: black body turns violet, yellow eyes stay', () {
      const body = Color.fromARGB(255, 35, 31, 32);
      const eyes = Color.fromARGB(255, 249, 237, 50);
      final violet = SeasonalIconPainter(SeasonalIconKind.bat, dark: true).batColor;
      expect(SeasonalIcon.batColorOnDark(body), violet);
      expect(SeasonalIcon.batColorOnDark(eyes), eyes);
    });
  });
}
