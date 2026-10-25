import 'dart:math' as math;

import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _icon(SeasonalIconKind kind) =>
    find.byWidgetPredicate((w) => w is SeasonalIcon && w.kind == kind);

void main() {
  late int taps;

  setUp(() => taps = 0);

  Widget app(SeasonalTheme theme, {bool disableAnimations = false, int playCount = 0}) {
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: SeasonalOverlay(theme: theme, playCount: playCount, child: child!),
      ),
      home: Scaffold(
        body: SizedBox.expand(
          child: ElevatedButton(
            onPressed: () => taps++,
            child: const Text('Tap me'),
          ),
        ),
      ),
    );
  }

  testWidgets('Halloween shows pumpkins and bats', (tester) async {
    await tester.pumpWidget(app(SeasonalTheme.halloween));

    expect(find.byKey(SeasonalOverlay.decorationKey), findsOneWidget);
    expect(_icon(SeasonalIconKind.pumpkin), findsWidgets);
    expect(_icon(SeasonalIconKind.bat), findsWidgets);
  });

  testWidgets('Christmas shows snowflakes and trees', (tester) async {
    await tester.pumpWidget(app(SeasonalTheme.christmas));

    expect(_icon(SeasonalIconKind.snowflake), findsWidgets);
    expect(_icon(SeasonalIconKind.tree), findsWidgets);
  });

  testWidgets('none draws nothing and keeps the screen', (tester) async {
    await tester.pumpWidget(app(SeasonalTheme.none));

    expect(find.byKey(SeasonalOverlay.decorationKey), findsNothing);
    expect(find.text('Tap me'), findsOneWidget);
  });

  testWidgets('taps pass through the decorations', (tester) async {
    await tester.pumpWidget(app(SeasonalTheme.halloween));

    await tester.tap(find.text('Tap me'), warnIfMissed: false);
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('decorations are hidden from screen readers', (tester) async {
    await tester.pumpWidget(app(SeasonalTheme.halloween));

    expect(
      find.descendant(
        of: find.byType(ExcludeSemantics),
        matching: find.byKey(SeasonalOverlay.decorationKey),
      ),
      findsOneWidget,
    );
  });

  testWidgets('animates when motion is allowed', (tester) async {
    await tester.pumpWidget(app(SeasonalTheme.christmas));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('reduce motion shows no overlay at all', (tester) async {
    await tester.pumpWidget(
      app(SeasonalTheme.halloween, disableAnimations: true),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SeasonalIcon), findsNothing);
    expect(find.text('Tap me'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('switching season swaps the icons', (tester) async {
    await tester.pumpWidget(app(SeasonalTheme.halloween));
    await tester.pumpWidget(app(SeasonalTheme.christmas));

    expect(_icon(SeasonalIconKind.pumpkin), findsNothing);
    expect(_icon(SeasonalIconKind.snowflake), findsWidgets);
  });

  for (final season in [SeasonalTheme.halloween, SeasonalTheme.christmas]) {
    testWidgets('${season.name} icons spread over the whole screen', (tester) async {
      await tester.pumpWidget(app(season));
      await tester.pump(const Duration(seconds: 3));

      final screen = tester.getSize(find.byType(Scaffold));
      final ys = tester
          .widgetList<SeasonalIcon>(find.byType(SeasonalIcon))
          .map((w) => tester.getCenter(find.byWidget(w)).dy)
          .toList();
      expect(ys.reduce(math.min), lessThan(screen.height / 3), reason: '$ys');
      expect(ys.reduce(math.max), greaterThan(screen.height * 2 / 3), reason: '$ys');
    });
  }

  testWidgets('pumpkins and bats are larger than the Christmas icons', (tester) async {
    Size iconSize() => tester.getSize(find.byType(SeasonalIcon).first);

    await tester.pumpWidget(app(SeasonalTheme.halloween));
    expect(iconSize(), const Size.square(36));
    await tester.pumpWidget(app(SeasonalTheme.christmas));
    expect(iconSize(), const Size.square(22));
  });

  group('burst', () {
    testWidgets('plays, then fades out and stops', (tester) async {
      await tester.pumpWidget(app(SeasonalTheme.newYear));
      await tester.pump(const Duration(seconds: 1));
      expect(_icon(SeasonalIconKind.fireworks), findsWidgets);
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pump(SeasonalOverlay.burst);
      await tester.pump();
      expect(find.byType(SeasonalIcon), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.text('Tap me'), findsOneWidget);
    });

    testWidgets('plays again when playCount changes', (tester) async {
      await tester.pumpWidget(app(SeasonalTheme.halloween));
      await tester.pump(SeasonalOverlay.burst + const Duration(seconds: 1));
      await tester.pump();
      expect(find.byType(SeasonalIcon), findsNothing);

      await tester.pumpWidget(app(SeasonalTheme.halloween, playCount: 1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_icon(SeasonalIconKind.pumpkin), findsWidgets);
    });

    testWidgets('the screen underneath is never rebuilt by the burst', (tester) async {
      var builds = 0;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => SeasonalOverlay(theme: SeasonalTheme.christmas, child: child!),
          home: Builder(builder: (context) {
            builds++;
            return const SizedBox.expand();
          }),
        ),
      );
      final before = builds;
      await tester.pump(const Duration(seconds: 2));
      expect(builds, before);
    });
  });
}
