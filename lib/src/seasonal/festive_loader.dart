// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// The app's loading spinner, swapped in a festive [season] for that season's
/// own items hopping with a bouncy squash-and-stretch, taking turns each hop.
/// Out of season it shows [fallback]. Fits a [size] square, so layouts keep
/// the spinner's footprint; with the OS "reduce motion" setting the item rests.
class FestiveLoader extends StatefulWidget {
  const FestiveLoader({
    super.key,
    required this.season,
    required this.fallback,
    this.semanticsLabel = 'Loading',
    this.size = 48,
  });

  final SeasonalTheme season;
  final Widget fallback;
  final String semanticsLabel;
  final double size;

  /// One hop, from take-off to landing.
  static const Duration hop = Duration(milliseconds: 900);

  /// On the hopping item; lets tests find it.
  static const Key itemKey = ValueKey('festive-loader-item');

  @override
  State<FestiveLoader> createState() => _FestiveLoaderState();
}

class _FestiveLoaderState extends State<FestiveLoader>
    with SingleTickerProviderStateMixin {
  /// Share of a hop spent rising; the rest is the bouncing fall.
  static const double _riseShare = 0.4;

  // Two hops per cycle, so the season's items take turns.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: FestiveLoader.hop * 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(FestiveLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.season != widget.season) _updateMotion();
  }

  /// Animates only in season and when the OS allows motion.
  void _updateMotion() {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final animate = widget.season != SeasonalTheme.none && !reduceMotion;
    if (animate && !_controller.isAnimating) {
      // Runs until the loader leaves the screen (disposed below).
      _controller.repeat();
    } else if (!animate) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Height above the ground, 0–1, at [phase] (0–1) of one hop.
  static double _lift(double phase) {
    if (phase < _riseShare) {
      return Curves.easeOutCubic.transform(phase / _riseShare);
    }
    final fall = (phase - _riseShare) / (1 - _riseShare);
    return 1 - Curves.bounceOut.transform(fall);
  }

  @override
  Widget build(BuildContext context) {
    final icons = widget.season.icons;
    if (icons.isEmpty) return widget.fallback;

    final size = widget.size;
    final itemSize = size * 0.62;
    final bounceHeight = size * 0.24;
    return Semantics(
      label: widget.semanticsLabel,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final cycle = _controller.value * 2;
              final kind = icons[cycle.floor() % icons.length];
              final lift = _lift(cycle % 1);
              // Squash on the ground, stretch in the air.
              final squash = (1 - lift) * 0.14;
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  _Shadow(width: itemSize * (0.8 - 0.35 * lift), lift: lift),
                  Positioned(
                    bottom: size * 0.06 + lift * bounceHeight,
                    child: Transform.scale(
                      scaleX: 1 + squash,
                      scaleY: 1 - squash + lift * 0.06,
                      alignment: Alignment.bottomCenter,
                      child: SeasonalIcon(
                        key: FestiveLoader.itemKey,
                        kind: kind,
                        size: itemSize,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Soft ground shadow that shrinks and fades as the item rises.
class _Shadow extends StatelessWidget {
  const _Shadow({required this.width, required this.lift});

  final double width;
  final double lift;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.18,
      decoration: BoxDecoration(
        color: context.colors.black900.withValues(alpha: 0.18 - 0.1 * lift),
        borderRadius: BorderRadius.all(Radius.elliptical(width, width * 0.18)),
      ),
    );
  }
}
