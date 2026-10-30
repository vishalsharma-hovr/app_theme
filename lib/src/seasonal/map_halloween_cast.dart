// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// The characters that visit the Halloween map ([MapSeasonalLayer]).
enum MapCharacterKind { bat, pumpkin, ghost, spider }

/// One visit by [kind] from [start] to [end], as fractions of
/// [MapSeasonalLayer.castCycle]. [slot] picks its lane or corner.
class _Visit {
  const _Visit(this.kind, this.start, this.end, this.slot);

  final MapCharacterKind kind;
  final double start;
  final double end;
  final int slot;
}

/// The minute-long Halloween timeline. At most
/// [MapSeasonalLayer.maxCharactersOnScreen] overlap, and the map has quiet
/// gaps so the characters feel like visits, not wallpaper.
const _halloweenVisits = [
  _Visit(MapCharacterKind.bat, 0.05, 0.20, 0),
  _Visit(MapCharacterKind.bat, 0.07, 0.22, 1),
  _Visit(MapCharacterKind.pumpkin, 0.24, 0.42, 0),
  _Visit(MapCharacterKind.pumpkin, 0.26, 0.44, 1),
  _Visit(MapCharacterKind.ghost, 0.30, 0.46, 0),
  _Visit(MapCharacterKind.bat, 0.55, 0.70, 2),
  _Visit(MapCharacterKind.bat, 0.57, 0.72, 3),
  _Visit(MapCharacterKind.spider, 0.75, 0.92, 0),
  _Visit(MapCharacterKind.pumpkin, 0.76, 0.90, 1),
];

const double _batSize = 28;
const double _pumpkinSize = 40;
const double _ghostSize = 44;
const double _spiderSize = 22;

/// Where [visit] is at [t] (0–1 through the cycle) on a map of [size], or
/// null when it is off stage. Characters keep to the top quarter and the
/// bottom corners, away from the route, car and pickup pin in the middle.
Rect? _visitBounds(_Visit visit, double t, Size size) {
  assert(visit.end > visit.start, 'a visit needs a length');
  if (t < visit.start || t > visit.end) return null;
  final p = (t - visit.start) / (visit.end - visit.start);
  final arc = math.sin(math.pi * p); // 0 → 1 → 0: rise and fall back
  switch (visit.kind) {
    case MapCharacterKind.bat:
      // Slots 0–1 fly left to right, 2–3 back; the second of a pair trails lower.
      final rightward = visit.slot < 2;
      final travel = size.width + 2 * _batSize;
      final x = rightward ? p * travel - _batSize : size.width + _batSize - p * travel;
      final y = size.height * 0.08 + (visit.slot.isOdd ? _batSize : 0) + math.sin(4 * math.pi * p) * 8;
      return Rect.fromCenter(center: Offset(x, y), width: _batSize, height: _batSize);
    case MapCharacterKind.pumpkin:
      // Peeks up from a bottom corner, bobbing, then sinks back.
      final x = visit.slot == 0 ? size.width * 0.1 : size.width * 0.9;
      final y = size.height + _pumpkinSize / 2 - arc * _pumpkinSize * 0.8 + math.sin(6 * math.pi * p) * 2;
      return Rect.fromCenter(center: Offset(x, y), width: _pumpkinSize, height: _pumpkinSize);
    case MapCharacterKind.ghost:
      final x = -_ghostSize + p * (size.width + 2 * _ghostSize);
      final y = size.height * 0.15 + math.sin(2 * math.pi * p) * 6;
      return Rect.fromCenter(center: Offset(x, y), width: _ghostSize, height: _ghostSize);
    case MapCharacterKind.spider:
      // Lowers on its thread from the top edge, then climbs back up.
      final x = size.width * 0.78 + math.sin(10 * math.pi * p) * 3;
      final bodyY = arc * size.height * 0.16;
      return Rect.fromLTRB(x - _spiderSize / 2, 0, x + _spiderSize / 2, bodyY + _spiderSize / 2);
  }
}

/// Paints the Halloween visitors at [progress] through
/// [MapSeasonalLayer.castCycle]. Paints, icon painters and the ghost outline
/// are made once; frames only move and recolour them.
class _HalloweenCastPainter extends CustomPainter {
  _HalloweenCastPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  // The Halloween map is dark in both modes, so the bat takes its violet.
  final _bat = SeasonalIconPainter(SeasonalIconKind.bat, dark: true);
  final _pumpkin = SeasonalIconPainter(SeasonalIconKind.pumpkin);
  final Paint _glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
  final Paint _ghost = Paint();
  final Paint _ghostEyes = Paint();
  final Paint _spider = Paint()
    ..color = const Color(0xFF0A0610)
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  final Paint _thread = Paint()
    ..color = const Color(0xB3E5E7EB)
    ..strokeWidth = 1;

  /// A ghost on a 24 × 24 grid: round head, wavy hem.
  static final Path _ghostShape = Path()
    ..moveTo(4, 22)
    ..lineTo(4, 11)
    ..arcToPoint(const Offset(20, 11), radius: const Radius.circular(8))
    ..lineTo(20, 22)
    ..quadraticBezierTo(18, 19, 16, 22)
    ..quadraticBezierTo(14, 19, 12, 22)
    ..quadraticBezierTo(10, 19, 8, 22)
    ..quadraticBezierTo(6, 19, 4, 22)
    ..close();

  static const Color _ghostWhite = Color(0xFFF8FAFC);
  static const Color _ghostEyeColor = Color(0xFF1E1B2E);
  static const Color _candle = Color(0xFFFDBA74);

  @override
  void paint(Canvas canvas, Size size) {
    assert(size.isFinite, 'MapSeasonalLayer needs a bounded size');
    if (size.isEmpty) return;
    final t = progress.value;
    for (final visit in _halloweenVisits) {
      final bounds = _visitBounds(visit, t, size);
      if (bounds == null) continue;
      final p = (t - visit.start) / (visit.end - visit.start);
      switch (visit.kind) {
        case MapCharacterKind.bat:
          _paintBat(canvas, bounds, p);
        case MapCharacterKind.pumpkin:
          _paintPumpkin(canvas, bounds, p);
        case MapCharacterKind.ghost:
          _paintGhost(canvas, bounds, math.sin(math.pi * p));
        case MapCharacterKind.spider:
          _paintSpider(canvas, bounds, p);
      }
    }
  }

  /// The bat icon, squashed and stretched so its wings flap.
  void _paintBat(Canvas canvas, Rect bounds, double p) {
    final flap = 0.55 + 0.45 * math.sin(24 * math.pi * p).abs();
    canvas.save();
    canvas.translate(bounds.left, bounds.center.dy);
    canvas.scale(1, flap);
    canvas.translate(0, -bounds.height / 2);
    _bat.paint(canvas, bounds.size);
    canvas.restore();
  }

  /// The pumpkin icon over a flickering candle glow.
  void _paintPumpkin(Canvas canvas, Rect bounds, double p) {
    final flicker = 0.35 + 0.15 * math.sin(30 * math.pi * p);
    _glow.color = _candle.withValues(alpha: flicker);
    canvas.drawCircle(bounds.center, bounds.width * 0.55, _glow);
    canvas.save();
    canvas.translate(bounds.left, bounds.top);
    _pumpkin.paint(canvas, bounds.size);
    canvas.restore();
  }

  /// The ghost, faded in and out by [opacity] (0–1).
  void _paintGhost(Canvas canvas, Rect bounds, double opacity) {
    assert(opacity >= 0 && opacity <= 1);
    _ghost.color = _ghostWhite.withValues(alpha: 0.85 * opacity);
    _ghostEyes.color = _ghostEyeColor.withValues(alpha: opacity);
    final scale = bounds.width / 24;
    canvas.save();
    canvas.translate(bounds.left, bounds.top);
    canvas.scale(scale);
    canvas.drawPath(_ghostShape, _ghost);
    canvas.drawCircle(const Offset(9.5, 11), 1.4, _ghostEyes);
    canvas.drawCircle(const Offset(14.5, 11), 1.4, _ghostEyes);
    canvas.restore();
  }

  /// The spider at the bottom of [bounds], hanging from a thread at the top.
  void _paintSpider(Canvas canvas, Rect bounds, double p) {
    final body = Offset(bounds.center.dx, bounds.bottom - _spiderSize / 2);
    canvas.drawLine(Offset(body.dx, bounds.top), body, _thread);
    final wiggle = math.sin(16 * math.pi * p) * 2;
    for (var leg = 0; leg < 4; leg++) {
      final dy = (leg - 1.5) * 3.5;
      final reach = _spiderSize / 2 - (leg == 0 || leg == 3 ? 1 : 0);
      canvas.drawLine(body, body.translate(-reach, dy + wiggle), _spider);
      canvas.drawLine(body, body.translate(reach, dy - wiggle), _spider);
    }
    canvas.drawCircle(body, 4.5, _spider);
    canvas.drawCircle(body.translate(0, -5), 3, _spider);
  }

  @override
  bool shouldRepaint(_HalloweenCastPainter oldDelegate) => oldDelegate.progress != progress;
}
