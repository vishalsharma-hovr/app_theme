// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// Seasonal decorations for the map, stacked over a `GoogleMap` (style JSON
/// can only recolour the map, not draw on it): snowballs at Christmas,
/// glowing embers at Halloween, gold sparkles at New Year. At Halloween bats,
/// pumpkins, a ghost and a spider also visit ([castCycle]), keeping to the top
/// quarter and the bottom corners so the route, car and pickup pin stay clear.
/// Loops for as long as it is shown. Never takes taps, hidden from screen
/// readers, and shows nothing outside a season or when the OS "reduce motion"
/// setting is on. Size it to the visible map (not under a bottom sheet), and
/// show it only while browsing the map, not during a trip.
///
/// ```dart
/// Stack(children: [GoogleMap(...), MapSeasonalLayer(season: season)])
/// ```
class MapSeasonalLayer extends StatefulWidget {
  const MapSeasonalLayer({super.key, required this.season, this.calm = false});

  final SeasonalTheme season;

  /// For the in-trip map: half the ambient decorations, only in the top
  /// quarter ([calmBand]), fading in and out, and no Halloween characters, so
  /// the route, car, driver card and ETA stay clear. Defaults to false.
  final bool calm;

  /// Share of the map's height that calm decorations stay in.
  static const double calmBand = 0.25;

  /// One loop of the animation.
  static const Duration cycle = Duration(seconds: 12);

  /// On the decoration layer; lets tests find it.
  static const Key decorationKey = ValueKey('map-seasonal-decorations');

  /// One loop of the Halloween characters' visits.
  static const Duration castCycle = Duration(seconds: 60);

  /// Most Halloween characters on the map at once.
  static const int maxCharactersOnScreen = 3;

  /// On the Halloween characters layer; lets tests find it.
  static const Key castKey = ValueKey('map-halloween-cast');

  /// Centres of the ambient decorations for [season] on a map of [size] at
  /// [t] (0–1 through [cycle]). For tests; painting uses the same maths.
  @visibleForTesting
  static List<Offset> decorationsAt(SeasonalTheme season, double t, Size size, {bool calm = false}) => [
        if (season != SeasonalTheme.none)
          for (var slot = 0; slot < _MapDecorationPainter.countFor(calm: calm); slot++)
            _MapDecorationPainter.centre(season, slot, t, size, calm: calm),
      ];

  /// The Halloween characters on a map of [size] at [t] (0–1 through
  /// [castCycle]), with their bounds. For tests; painting uses the same maths.
  @visibleForTesting
  static List<(MapCharacterKind, Rect)> halloweenCastAt(double t, Size size) => [
        for (final visit in _halloweenVisits)
          if (_visitBounds(visit, t, size) case final bounds?) (visit.kind, bounds),
      ];

  /// Snowball body and its shaded edge.
  static const Color snow = Color(0xFFFFFFFF);
  static const Color snowShade = Color(0xFFCBD5E1);

  @override
  State<MapSeasonalLayer> createState() => _MapSeasonalLayerState();
}

class _MapSeasonalLayerState extends State<MapSeasonalLayer>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MapSeasonalLayer.cycle,
  );
  late final AnimationController _castController = AnimationController(
    vsync: this,
    duration: MapSeasonalLayer.castCycle,
  );
  late _MapDecorationPainter _painter =
      _MapDecorationPainter(widget.season, _controller, calm: widget.calm);
  late final _HalloweenCastPainter _castPainter = _HalloweenCastPainter(_castController);
  bool _visible = false;

  bool get _showCast => _visible && !widget.calm && widget.season == SeasonalTheme.halloween;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(MapSeasonalLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.season != widget.season || oldWidget.calm != widget.calm) {
      _painter = _MapDecorationPainter(widget.season, _controller, calm: widget.calm);
    }
    _syncAnimation();
  }

  /// Runs the controller only while something is drawn, so a hidden layer
  /// costs no frames.
  void _syncAnimation() {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _visible = widget.season != SeasonalTheme.none && !reduceMotion;
    _run(_controller, _visible);
    _run(_castController, _showCast);
  }

  void _run(AnimationController controller, bool on) {
    if (!on) {
      controller.stop();
    } else if (!controller.isAnimating) {
      // Repeats until hidden or disposed on purpose: decorations last all season.
      controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _castController.dispose();
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  key: MapSeasonalLayer.decorationKey,
                  painter: _painter,
                ),
                if (_showCast)
                  CustomPaint(
                    key: MapSeasonalLayer.castKey,
                    painter: _castPainter,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints [countFor] decorations for [season] at [progress] through a
/// [MapSeasonalLayer.cycle]. Positions are fixed per slot (no randomness) so
/// frames are stable; paints are created once and only recoloured per frame.
class _MapDecorationPainter extends CustomPainter {
  _MapDecorationPainter(this.season, this.progress, {required this.calm}) : super(repaint: progress);

  final SeasonalTheme season;
  final Animation<double> progress;

  /// See [MapSeasonalLayer.calm].
  final bool calm;

  static const int _count = 12;
  static const double _sway = 8;

  /// Decorations drawn at once: half in calm mode.
  static int countFor({required bool calm}) => calm ? _count ~/ 2 : _count;

  static double _radius(int slot) => 3 + (slot % 3) * 1.5;

  /// 0–1 progress of [slot] through its own pass at [t] (1–2 passes a cycle).
  static double _phase(int slot, double t) => (t * (1 + slot % 2) + slot * 0.37) % 1;

  /// Where decoration [slot] for [season] is at [t]. Snow falls and embers
  /// rise through the whole map, or only the top [MapSeasonalLayer.calmBand]
  /// when [calm]; sparkles twinkle in place.
  static Offset centre(SeasonalTheme season, int slot, double t, Size size, {required bool calm}) {
    assert(season != SeasonalTheme.none, 'no decorations out of season');
    final count = countFor(calm: calm);
    final lane = (slot + 0.5) / count;
    final phase = _phase(slot, t);
    final sway = math.sin(2 * math.pi * (t + slot * 0.37)) * _sway;
    final radius = _radius(slot);
    final x = lane * size.width;
    switch (season) {
      case SeasonalTheme.none:
      case SeasonalTheme.christmas:
        final y = calm
            ? phase * size.height * MapSeasonalLayer.calmBand - radius
            : phase * (size.height + 2 * radius) - radius;
        return Offset(x + sway, y);
      case SeasonalTheme.halloween:
        final y = calm
            ? (1 - phase) * size.height * MapSeasonalLayer.calmBand - radius
            : (1 - phase) * (size.height + 2 * radius) - radius;
        return Offset(x + sway, y);
      case SeasonalTheme.newYear:
        // Golden-ratio spread keeps sparkles off a straight line.
        final band = calm ? MapSeasonalLayer.calmBand : 1.0;
        return Offset(x, (slot * 0.618 % 1) * size.height * band);
    }
  }
  static const Color _emberCore = Color(0xFFFDBA74);

  final Paint _fill = Paint();
  final Paint _shade = Paint();
  final Paint _glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Paint _ray = Paint()
    ..strokeWidth = 1.2
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    assert(size.isFinite, 'MapSeasonalLayer needs a bounded size');
    if (size.isEmpty) return;
    if (season == SeasonalTheme.none) return;
    final t = progress.value;
    for (var slot = 0; slot < countFor(calm: calm); slot++) {
      final phase = _phase(slot, t);
      final radius = _radius(slot);
      final at = centre(season, slot, t, size, calm: calm);
      // Calm decorations fade in and out instead of leaving mid-map.
      final fade = calm ? math.sin(math.pi * phase) : 1.0;
      switch (season) {
        case SeasonalTheme.none:
          return;
        case SeasonalTheme.christmas:
          _paintSnowball(canvas, at, radius, fade);
        case SeasonalTheme.halloween:
          _paintEmber(canvas, at, radius * 0.7, fade);
        case SeasonalTheme.newYear:
          final twinkle = 0.5 + 0.5 * math.sin(2 * math.pi * phase);
          _paintSparkle(canvas, at, radius, twinkle * fade);
      }
    }
  }

  /// A white ball with a grey-blue shadow down and to the right, at [opacity].
  void _paintSnowball(Canvas canvas, Offset center, double radius, double opacity) {
    assert(radius > 0);
    _shade.color = MapSeasonalLayer.snowShade.withValues(alpha: opacity);
    canvas.drawCircle(center, radius, _shade);
    _fill.color = MapSeasonalLayer.snow.withValues(alpha: opacity);
    canvas.drawCircle(
      center - Offset(radius * 0.15, radius * 0.15),
      radius * 0.8,
      _fill,
    );
  }

  /// A glowing ember at [opacity].
  void _paintEmber(Canvas canvas, Offset center, double radius, double opacity) {
    assert(radius > 0);
    _glow.color = SeasonalIconPainter._pumpkin.withValues(alpha: 0.35 * opacity);
    canvas.drawCircle(center, radius * 2, _glow);
    _fill.color = _emberCore.withValues(alpha: opacity);
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
      oldDelegate.season != season || oldDelegate.progress != progress || oldDelegate.calm != calm;
}
