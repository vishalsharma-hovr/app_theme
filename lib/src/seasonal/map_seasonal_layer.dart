// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// Seasonal decorations for the map, stacked over a `GoogleMap` (style JSON
/// can only recolour the map, not draw on it): snowballs at Christmas,
/// glowing embers at Halloween, gold sparkles at New Year. Loops for as long
/// as it is shown. Never takes taps, hidden from screen readers, and shows
/// nothing outside a season or when the OS "reduce motion" setting is on.
///
/// ```dart
/// Stack(children: [GoogleMap(...), MapSeasonalLayer(season: season)])
/// ```
class MapSeasonalLayer extends StatefulWidget {
  const MapSeasonalLayer({super.key, required this.season});

  final SeasonalTheme season;

  /// One loop of the animation.
  static const Duration cycle = Duration(seconds: 12);

  /// On the decoration layer; lets tests find it.
  static const Key decorationKey = ValueKey('map-seasonal-decorations');

  /// Snowball body and its shaded edge.
  static const Color snow = Color(0xFFFFFFFF);
  static const Color snowShade = Color(0xFFCBD5E1);

  @override
  State<MapSeasonalLayer> createState() => _MapSeasonalLayerState();
}

class _MapSeasonalLayerState extends State<MapSeasonalLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MapSeasonalLayer.cycle,
  );
  late _MapDecorationPainter _painter =
      _MapDecorationPainter(widget.season, _controller);
  bool _visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(MapSeasonalLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.season != widget.season) {
      _painter = _MapDecorationPainter(widget.season, _controller);
    }
    _syncAnimation();
  }

  /// Runs the controller only while something is drawn, so a hidden layer
  /// costs no frames.
  void _syncAnimation() {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _visible = widget.season != SeasonalTheme.none && !reduceMotion;
    if (!_visible) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      // Repeats until hidden or disposed on purpose: decorations last all season.
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: ExcludeSemantics(
          // Own layer so animation frames don't repaint the map.
          child: RepaintBoundary(
            child: CustomPaint(
              key: MapSeasonalLayer.decorationKey,
              painter: _painter,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints [_count] decorations for [season] at [progress] through a
/// [MapSeasonalLayer.cycle]. Positions are fixed per slot (no randomness) so
/// frames are stable; paints are created once and only recoloured per frame.
class _MapDecorationPainter extends CustomPainter {
  _MapDecorationPainter(this.season, this.progress) : super(repaint: progress);

  final SeasonalTheme season;
  final Animation<double> progress;

  static const int _count = 12;
  static const double _sway = 8;
  static const Color _emberCore = Color(0xFFFDBA74);

  final Paint _fill = Paint();
  final Paint _shade = Paint()..color = MapSeasonalLayer.snowShade;
  final Paint _glow = Paint()
    ..color = SeasonalIconPainter._pumpkin.withValues(alpha: 0.35)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Paint _ray = Paint()
    ..strokeWidth = 1.2
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    assert(size.isFinite, 'MapSeasonalLayer needs a bounded size');
    if (size.isEmpty) return;
    final t = progress.value;
    for (var slot = 0; slot < _count; slot++) {
      final lane = (slot + 0.5) / _count;
      final phase = (t * (1 + slot % 2) + slot * 0.37) % 1; // 1–2 passes
      final sway = math.sin(2 * math.pi * (t + slot * 0.37)) * _sway;
      final radius = 3 + (slot % 3) * 1.5;
      switch (season) {
        case SeasonalTheme.none:
          return;
        case SeasonalTheme.christmas:
          final y = phase * (size.height + 2 * radius) - radius;
          _paintSnowball(canvas, Offset(lane * size.width + sway, y), radius);
        case SeasonalTheme.halloween:
          final y = (1 - phase) * (size.height + 2 * radius) - radius;
          _paintEmber(canvas, Offset(lane * size.width + sway, y), radius * 0.7);
        case SeasonalTheme.newYear:
          // Golden-ratio spread keeps sparkles off a straight line.
          final y = (slot * 0.618 % 1) * size.height;
          final twinkle = 0.5 + 0.5 * math.sin(2 * math.pi * phase);
          _paintSparkle(canvas, Offset(lane * size.width, y), radius, twinkle);
      }
    }
  }

  /// A white ball with a grey-blue shadow down and to the right.
  void _paintSnowball(Canvas canvas, Offset center, double radius) {
    assert(radius > 0);
    canvas.drawCircle(center, radius, _shade);
    _fill.color = MapSeasonalLayer.snow;
    canvas.drawCircle(
      center - Offset(radius * 0.15, radius * 0.15),
      radius * 0.8,
      _fill,
    );
  }

  void _paintEmber(Canvas canvas, Offset center, double radius) {
    assert(radius > 0);
    canvas.drawCircle(center, radius * 2, _glow);
    _fill.color = _emberCore;
    canvas.drawCircle(center, radius, _fill);
  }

  /// A gold dot with four rays, faded by [twinkle] (0–1).
  void _paintSparkle(Canvas canvas, Offset c, double radius, double twinkle) {
    assert(twinkle >= 0 && twinkle <= 1);
    final color = SeasonalIconPainter._star.withValues(alpha: twinkle);
    _ray.color = color;
    final reach = radius * 1.6;
    canvas.drawLine(c.translate(-reach, 0), c.translate(reach, 0), _ray);
    canvas.drawLine(c.translate(0, -reach), c.translate(0, reach), _ray);
    _fill.color = color;
    canvas.drawCircle(c, radius * 0.5, _fill);
  }

  @override
  bool shouldRepaint(_MapDecorationPainter oldDelegate) =>
      oldDelegate.season != season || oldDelegate.progress != progress;
}
