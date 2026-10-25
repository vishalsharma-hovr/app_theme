// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// Seasonal decorations: Lottie animations from `assets/lottie/` (credits in
/// `assets/lottie/CREDITS.md`), with a drawn fallback while they load.
enum SeasonalIconKind { pumpkin, bat, snowflake, tree, fireworks, partyPopper }

/// A [SeasonalIconKind] animation at [size] × [size] logical pixels.
class SeasonalIcon extends StatelessWidget {
  const SeasonalIcon({super.key, required this.kind, required this.size});

  final SeasonalIconKind kind;
  final double size;

  /// The animation file for [kind] in `assets/lottie/`.
  static String assetFor(SeasonalIconKind kind) => switch (kind) {
    SeasonalIconKind.pumpkin => 'pumpkin.json',
    SeasonalIconKind.bat => 'bat.json',
    SeasonalIconKind.snowflake => 'snowflake.json',
    SeasonalIconKind.tree => 'christmas_tree.json',
    SeasonalIconKind.fireworks => 'fireworks.json',
    SeasonalIconKind.partyPopper => 'party_popper.json',
  };

  /// The bat animation is black, which vanishes on dark backgrounds: its
  /// near-black parts turn violet, its yellow eyes stay.
  static Color batColorOnDark(Color color) =>
      color.computeLuminance() < 0.05 ? SeasonalIconPainter._batOnDark : color;

  static final _batOnDarkDelegates = LottieDelegates(
    values: [
      ValueDelegate.color(
        const ['**'],
        callback: (info) =>
            batColorOnDark(info.startValue ?? SeasonalIconPainter._batOnDark),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final drawn = CustomPaint(
      size: Size.square(size),
      painter: SeasonalIconPainter(kind, dark: dark),
    );
    return Lottie.asset(
      'assets/lottie/${assetFor(kind)}',
      package: 'app_theme',
      width: size,
      height: size,
      fit: BoxFit.contain,
      animate: !(MediaQuery.maybeDisableAnimationsOf(context) ?? false),
      delegates: dark && kind == SeasonalIconKind.bat ? _batOnDarkDelegates : null,
      frameBuilder: (context, child, composition) =>
          composition == null ? drawn : child,
      errorBuilder: (context, error, stackTrace) => drawn,
    );
  }
}

/// Paints [kind] on a 24 × 24 grid scaled to the canvas.
class SeasonalIconPainter extends CustomPainter {
  SeasonalIconPainter(this.kind, {this.dark = false});

  final SeasonalIconKind kind;

  /// Drawn on a dark background: swaps colours that would vanish there.
  final bool dark;

  Color get batColor => dark ? _batOnDark : _bat;

  static const double _grid = 24;

  static const Color _pumpkin = Color(0xFFF97316);
  static const Color _pumpkinRib = Color(0xFFC2410C);
  static const Color _stem = Color(0xFF3F6212);
  static const Color _bat = Color(0xFF2E1065);
  static const Color _batOnDark = Color(0xFFA78BFA);
  static const Color _ice = Color(0xFF7DD3FC);
  static const Color _pine = Color(0xFF15803D);
  static const Color _trunk = Color(0xFF78350F);
  static const Color _star = Color(0xFFFACC15);
  static const Color _spark = Color(0xFF14B8A6);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _grid, size.height / _grid);
    switch (kind) {
      case SeasonalIconKind.pumpkin:
        _paintPumpkin(canvas);
      case SeasonalIconKind.bat:
        _paintBat(canvas);
      case SeasonalIconKind.snowflake:
        _paintSnowflake(canvas);
      case SeasonalIconKind.tree:
        _paintTree(canvas);
      case SeasonalIconKind.fireworks:
        _paintFireworks(canvas);
      case SeasonalIconKind.partyPopper:
        _paintPartyPopper(canvas);
    }
    canvas.restore();
  }

  void _paintPumpkin(Canvas canvas) {
    final body = Paint()..color = _pumpkin;
    // Three overlapping lobes read as a ribbed pumpkin.
    canvas.drawOval(const Rect.fromLTWH(3, 7, 10, 14), body);
    canvas.drawOval(const Rect.fromLTWH(11, 7, 10, 14), body);
    canvas.drawOval(const Rect.fromLTWH(7, 6.5, 10, 15), body);
    final rib = Paint()
      ..color = _pumpkinRib
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      const Rect.fromLTWH(7, 7.5, 10, 13),
      math.pi * 0.65,
      math.pi * 0.7,
      false,
      rib,
    );
    canvas.drawArc(
      const Rect.fromLTWH(7, 7.5, 10, 13),
      -math.pi * 0.35,
      math.pi * 0.7,
      false,
      rib,
    );
    final stem = Path()
      ..moveTo(11, 7.5)
      ..quadraticBezierTo(11, 4, 13.5, 2.5)
      ..lineTo(14.2, 3.6)
      ..quadraticBezierTo(12.8, 4.8, 13, 7.5)
      ..close();
    canvas.drawPath(stem, Paint()..color = _stem);
  }

  void _paintBat(Canvas canvas) {
    final wing = Path()
      ..moveTo(12, 9)
      ..quadraticBezierTo(8, 6, 1, 8)
      ..quadraticBezierTo(3, 10, 2.5, 13)
      ..quadraticBezierTo(4.5, 11.5, 6, 13.5)
      ..quadraticBezierTo(7.5, 12, 9, 14)
      ..quadraticBezierTo(10.5, 13, 12, 15)
      ..quadraticBezierTo(13.5, 13, 15, 14)
      ..quadraticBezierTo(16.5, 12, 18, 13.5)
      ..quadraticBezierTo(19.5, 11.5, 21.5, 13)
      ..quadraticBezierTo(21, 10, 23, 8)
      ..quadraticBezierTo(16, 6, 12, 9)
      ..close();
    final paint = Paint()..color = batColor;
    canvas.drawPath(wing, paint);
    // Head with ears.
    final head = Path()
      ..moveTo(10.6, 9.5)
      ..lineTo(10.9, 7)
      ..lineTo(11.6, 8.2)
      ..lineTo(12.4, 8.2)
      ..lineTo(13.1, 7)
      ..lineTo(13.4, 9.5)
      ..quadraticBezierTo(12, 11.5, 10.6, 9.5)
      ..close();
    canvas.drawPath(head, paint);
  }

  void _paintFireworks(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const rays = 12;
    for (var i = 0; i < rays; i++) {
      final angle = i * 2 * math.pi / rays;
      final dir = Offset(math.cos(angle), math.sin(angle));
      paint.color = i.isEven ? _spark : _star;
      canvas.drawLine(const Offset(12, 12) + dir * 4, const Offset(12, 12) + dir * 10, paint);
    }
  }

  void _paintPartyPopper(Canvas canvas) {
    final cone = Path()
      ..moveTo(3, 21)
      ..lineTo(8, 9)
      ..lineTo(15, 16)
      ..close();
    canvas.drawPath(cone, Paint()..color = _star);
    final streamer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = _spark;
    canvas.drawLine(const Offset(13, 8), const Offset(16, 4), streamer);
    canvas.drawLine(const Offset(16, 11), const Offset(21, 9), streamer);
    canvas.drawCircle(const Offset(19, 4), 1.4, Paint()..color = _pumpkin);
  }

  void _paintSnowflake(Canvas canvas) {
    final paint = Paint()
      ..color = _ice
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const center = Offset(12, 12);
    const arms = 6;
    for (var i = 0; i < arms; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * 2 * math.pi / arms);
      canvas.drawLine(Offset.zero, const Offset(0, -10), paint);
      canvas.drawLine(const Offset(0, -6), const Offset(-2.8, -8.6), paint);
      canvas.drawLine(const Offset(0, -6), const Offset(2.8, -8.6), paint);
      canvas.restore();
    }
  }

  void _paintTree(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(10.5, 18.5, 3, 4),
      Paint()..color = _trunk,
    );
    final pine = Paint()..color = _pine;
    for (final (top, bottom, half) in const [
      (4.0, 11.0, 5.0),
      (7.5, 15.0, 7.0),
      (11.0, 19.5, 9.0),
    ]) {
      final tier = Path()
        ..moveTo(12, top)
        ..lineTo(12 + half, bottom)
        ..lineTo(12 - half, bottom)
        ..close();
      canvas.drawPath(tier, pine);
    }
    final star = Path();
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? 2.6 : 1.1;
      final angle = -math.pi / 2 + i * math.pi / points;
      final p = Offset(
        12 + radius * math.cos(angle),
        3.6 + radius * math.sin(angle),
      );
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(star..close(), Paint()..color = _star);
  }

  @override
  bool shouldRepaint(SeasonalIconPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.dark != dark;
}
