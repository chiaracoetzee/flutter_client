import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/scheduler.dart';
import 'package:fluxer_app/core/theme/color_utils.dart';
import 'package:fluxer_app/features/ui/background/starfield_background.dart';
import 'package:fluxer_app/features/ui/icons/instance_branding_image.dart';
import 'package:fluxer_app/material_ui.dart';

class SplashRevealOverlay {
  SplashRevealOverlay._();

  static const double logoSize = 85;
  static const double pulseScale = 0.8;
  static const double fadeEndScale = 0.45;
  static const double expandScale = 500;
  static const double pulseEndFraction = 0.08;
  static const double shellStartScale = 1.1;
  static const double symbolViewBox = 512;
  static const Duration totalDuration = Duration(milliseconds: 800);
  static const Duration fadeOnlyDuration = Duration(milliseconds: 350);
  static const Duration reducedMotionDuration = Duration(milliseconds: 300);
  static const int maxTickMicros = 32000;

  static final Color silhouetteSymbolColor = ColorUtils.dim(
    StarfieldBackground.cutoutSymbolColor,
    0.3,
  );

  static void show({
    required BuildContext context,
    required Color coverColor,
    required Color logoBrandColor,
    required Color logoBrandSymbolColor,
    required Offset logoCenterGlobal,
    required bool useLogoZoomTransition,
    VoidCallback? onComplete,
    bool? animationsEnabled,
  }) {
    final bool enabled =
        animationsEnabled ?? !MediaQuery.disableAnimationsOf(context);

    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    var finished = false;
    Timer? failsafe;
    void finish() {
      if (finished) {
        return;
      }
      finished = true;
      failsafe?.cancel();
      failsafe = null;
      if (entry.mounted) {
        entry.remove();
      }
      onComplete?.call();
    }

    final Duration revealDuration = !enabled
        ? SplashRevealOverlay.reducedMotionDuration
        : useLogoZoomTransition
        ? SplashRevealOverlay.totalDuration
        : SplashRevealOverlay.fadeOnlyDuration;
    entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return _SplashRevealOverlayWidget(
          coverColor: coverColor,
          logoBrandColor: logoBrandColor,
          logoBrandSymbolColor: logoBrandSymbolColor,
          logoCenterGlobal: logoCenterGlobal,
          useLogoZoomTransition: useLogoZoomTransition,
          reducedMotion: !enabled,
          onComplete: finish,
          onDispose: () {
            failsafe?.cancel();
            failsafe = null;
          },
        );
      },
    );
    overlay.insert(entry);
    failsafe = Timer(
      revealDuration + const Duration(milliseconds: 400),
      finish,
    );
  }
}

class _SplashRevealOverlayWidget extends StatefulWidget {
  const _SplashRevealOverlayWidget({
    required this.coverColor,
    required this.logoBrandColor,
    required this.logoBrandSymbolColor,
    required this.logoCenterGlobal,
    required this.useLogoZoomTransition,
    required this.reducedMotion,
    required this.onComplete,
    this.onDispose,
  });

  final Color coverColor;
  final Color logoBrandColor;
  final Color logoBrandSymbolColor;
  final Offset logoCenterGlobal;
  final bool useLogoZoomTransition;
  final bool reducedMotion;
  final VoidCallback onComplete;
  final VoidCallback? onDispose;

  @override
  State<_SplashRevealOverlayWidget> createState() =>
      _SplashRevealOverlayWidgetState();
}

class _SplashRevealOverlayWidgetState extends State<_SplashRevealOverlayWidget>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  double _progress = 0;

  Duration get _duration {
    if (widget.reducedMotion) {
      return SplashRevealOverlay.reducedMotionDuration;
    }
    if (!widget.useLogoZoomTransition) {
      return SplashRevealOverlay.fadeOnlyDuration;
    }
    return SplashRevealOverlay.totalDuration;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _ticker != null) {
        return;
      }
      _ticker = createTicker(_onTick);
      _ticker!.start();
    });
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    _ticker?.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) {
      return;
    }
    final int dt = (elapsed - _lastElapsed).inMicroseconds.clamp(
      0,
      SplashRevealOverlay.maxTickMicros,
    );
    _lastElapsed = elapsed;

    final double next = (_progress + dt / _duration.inMicroseconds).clamp(
      0.0,
      1.0,
    );

    setState(() => _progress = next);
    if (next >= 1) {
      _ticker?.stop();
      widget.onComplete();
    }
  }

  bool _isExpandPhase() {
    if (widget.reducedMotion || !widget.useLogoZoomTransition) {
      return false;
    }
    return _progress > SplashRevealOverlay.pulseEndFraction;
  }

  Offset _localCenter() {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return widget.logoCenterGlobal;
    }
    return renderObject.globalToLocal(widget.logoCenterGlobal);
  }

  ({Color fill, Color symbol}) _logoColors(double t) {
    final Color fill = Color.lerp(widget.logoBrandColor, widget.coverColor, t)!;
    final Color symbol = Color.lerp(
      widget.logoBrandSymbolColor,
      SplashRevealOverlay.silhouetteSymbolColor,
      t,
    )!;
    return (fill: fill, symbol: symbol);
  }

  @override
  Widget build(BuildContext context) {
    final Offset center = _localCenter();
    final bool expandPhase = _isExpandPhase();
    final double scale = splashRevealLogoScale(
      _progress,
      reducedMotion: widget.reducedMotion,
      useLogoZoomTransition: widget.useLogoZoomTransition,
    );
    final double coverOpacity = splashRevealLayerOpacity(
      _progress,
      reducedMotion: widget.reducedMotion,
    );

    if (coverOpacity <= 0) {
      return const ExcludeSemantics(child: IgnorePointer());
    }

    if (expandPhase) {
      return ExcludeSemantics(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _SplashRevealPainter(
              coverColor: widget.coverColor,
              symbolColor: SplashRevealOverlay.silhouetteSymbolColor,
              center: center,
              scale: scale,
              opacity: coverOpacity,
              symbolOpacity: splashRevealSymbolOpacity(_progress),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      );
    }

    const double logoHalf = SplashRevealOverlay.logoSize / 2;
    late final Color logoFill;
    late final Color logoSymbol;
    if (widget.reducedMotion) {
      final (:Color fill, :Color symbol) = _logoColors(
        Curves.easeOut.transform(_progress),
      );
      logoFill = fill;
      logoSymbol = symbol;
    } else {
      final (:Color fill, :Color symbol) = _logoColors(
        Curves.easeInCubic.transform(
          (_progress / SplashRevealOverlay.pulseEndFraction).clamp(0.0, 1.0),
        ),
      );
      logoFill = fill;
      logoSymbol = symbol;
    }

    return ExcludeSemantics(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(opacity: coverOpacity, child: const StarfieldBackground()),
            Positioned(
              left: center.dx - logoHalf,
              top: center.dy - logoHalf,
              width: SplashRevealOverlay.logoSize,
              height: SplashRevealOverlay.logoSize,
              child: Opacity(
                opacity: coverOpacity,
                child: Transform.scale(
                  scale: scale,
                  child: InstanceBrandMark(
                    size: SplashRevealOverlay.logoSize,
                    backgroundColor: logoFill,
                    symbolColor: logoSymbol,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashRevealPainter extends CustomPainter {
  _SplashRevealPainter({
    required this.coverColor,
    required this.symbolColor,
    required this.center,
    required this.scale,
    required this.opacity,
    required this.symbolOpacity,
  });

  final Color coverColor;
  final Color symbolColor;
  final Offset center;
  final double scale;
  final double opacity;
  final double symbolOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 && symbolOpacity <= 0) {
      return;
    }

    const double symbolScale =
        SplashRevealOverlay.logoSize / SplashRevealOverlay.symbolViewBox;
    canvas
      ..clipRect(Offset.zero & size)
      ..drawRect(
        Offset.zero & size,
        Paint()
          ..color = coverColor.withValues(alpha: opacity)
          ..isAntiAlias = true,
      )
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(scale)
      ..translate(
        -SplashRevealOverlay.logoSize / 2,
        -SplashRevealOverlay.logoSize / 2,
      )
      ..scale(symbolScale)
      ..drawPath(
        splashRevealSymbolPath(),
        Paint()
          ..color = symbolColor.withValues(alpha: symbolOpacity)
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _SplashRevealPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.opacity != opacity ||
        oldDelegate.symbolOpacity != symbolOpacity ||
        oldDelegate.center != center ||
        oldDelegate.coverColor != coverColor ||
        oldDelegate.symbolColor != symbolColor;
  }
}

const String _kFluxerSymbolPathData =
    'M276.38 88.14C314.25 92.3 347.19 108.35 375.22 136.27C388.26 139.81 405.38 140.72 426.02 138.4C413.66 147.18 402.39 153.07 393.61 157.58C414.51 186.06 424.96 218.86 424.96 256C424.96 258.37 424.92 260.71 424.83 263.05C431.05 275.05 441.93 288.27 457.56 301.9C442.79 298.73 430.86 294.42 421.62 291C415.27 322.9 399.89 351.06 375.48 375.48C373.8 377.15 372.11 378.78 370.4 380.36C366.31 393.24 364.66 410.29 366.07 430.99C357.86 418.29 352.48 406.81 348.36 397.85C321.32 415.92 290.53 424.96 256 424.96C253.63 424.96 251.29 424.92 248.95 424.83C236.95 431.05 223.73 441.93 210.1 457.56C213.27 442.79 217.58 430.86 221 421.62C189.1 415.27 160.94 399.89 136.52 375.48C134.85 373.8 133.22 372.11 131.64 370.4C118.76 366.31 101.71 364.66 81.01 366.07C93.71 357.86 105.19 352.48 114.15 348.36C96.08 321.32 87.04 290.53 87.04 256C87.04 253.63 87.08 251.29 87.17 248.95C80.95 236.95 70.07 223.73 54.44 210.1C69.21 213.27 81.14 217.58 90.38 221C96.73 189.1 112.11 160.94 136.52 136.52C138.2 134.85 139.89 133.22 141.6 131.64C145.69 118.76 147.34 101.71 145.93 81.01C154.14 93.71 159.52 105.19 163.64 114.15C188.66 97.43 216.88 88.44 248.31 87.19C259.72 79.95 271.94 67.96 284.16 51.2C282.28 66.29 279 78.61 276.38 88.14ZM404.48 256C404.48 215 389.98 180 360.99 151.01C332 122.02 297 107.52 256 107.52C215 107.52 180 122.02 151.01 151.01C122.02 180 107.52 215 107.52 256C107.52 297 122.02 332 151.01 360.99C177.8 387.79 209.73 402.2 246.78 404.23C246.78 385.29 246.78 366.35 246.78 347.41C224.37 357.47 200.33 356.38 180.74 344.14C189.9 344.14 199.07 341.21 208.65 337.01C219.82 342.42 232.53 345.59 246.78 346.53C246.78 343.83 246.78 341.13 246.78 338.43C203.88 335.24 177.87 309.79 175.36 279.63C204.93 298.44 231.81 303.82 256 303.82C280.19 303.82 307.07 298.44 336.64 279.63C334.13 309.78 308.12 335.24 265.22 338.43C265.22 341.13 265.22 343.83 265.22 346.53C279.47 345.59 292.18 342.42 303.35 337.01C312.93 341.21 322.1 344.14 331.26 344.14C311.67 356.38 287.63 357.47 265.22 347.41C265.22 366.35 265.22 385.29 265.22 404.23C302.27 402.2 334.2 387.79 360.99 360.99C389.98 332 404.48 297 404.48 256ZM167.57 196.75C174.18 166.89 197.67 148.53 223.74 155.98C234.5 126.41 277.5 126.41 288.26 155.98C314.33 148.53 337.82 166.89 344.43 196.75C340.72 191.29 336.26 186.38 331.05 182.04C330.23 181.36 329.31 180.85 328.28 180.54C327.26 180.22 326.22 180.11 325.16 180.2C324.09 180.3 323.09 180.6 322.14 181.09C321.19 181.59 320.38 182.25 319.69 183.08C319.48 183.33 319.28 183.6 319.1 183.88C318.92 184.16 318.76 184.46 318.61 184.76C318.47 185.06 318.34 185.37 318.24 185.69C318.13 186 318.05 186.33 317.98 186.65C316.54 193.86 314.36 200.6 311.42 206.89C310.79 195.69 307.16 186.08 300.52 178.05C291.2 166.8 277.5 160.34 259.42 158.7C240.74 157 225.79 161.96 214.58 173.56C205.98 182.48 201.37 193.81 200.78 207.54C197.89 201.15 195.62 194.15 194 186.55C193.93 186.23 193.84 185.92 193.74 185.61C193.63 185.3 193.51 185 193.36 184.71C193.22 184.42 193.06 184.13 192.89 183.86C192.71 183.59 192.52 183.33 192.31 183.08C191.62 182.25 190.81 181.59 189.86 181.09C188.91 180.6 187.91 180.3 186.84 180.2C185.78 180.11 184.73 180.22 183.71 180.54C182.69 180.85 181.77 181.36 180.95 182.04C175.74 186.38 171.28 191.29 167.57 196.75ZM299.13 225.87C270.13 225.87 241.14 225.87 212.15 225.87C211.34 224.89 210.56 223.89 209.79 222.87C203.5 181.99 229.82 164.11 258.69 166.73C287.15 169.32 308.14 186.85 302.48 221.73C301.41 223.14 300.29 224.52 299.13 225.87ZM224.85 204.9C223.21 191.76 230.92 183.24 247.99 179.34C263.93 175.69 276.58 178.54 285.92 187.88C291.7 193.67 292.33 199.95 287.8 206.75C283.47 213.25 277.07 215.65 268.6 213.96C268.32 213.9 268.05 213.82 267.79 213.71C267.53 213.6 267.28 213.47 267.05 213.31C266.81 213.16 266.59 212.98 266.39 212.78C266.2 212.58 266.02 212.36 265.86 212.13C265.7 211.89 265.57 211.64 265.47 211.38C265.36 211.12 265.28 210.85 265.22 210.58C265.17 210.3 265.14 210.02 265.14 209.74C265.14 209.45 265.17 209.17 265.22 208.9C265.33 208.34 265.55 207.82 265.87 207.35C266.18 206.88 266.58 206.48 267.05 206.16C267.53 205.84 268.05 205.63 268.61 205.52C269.17 205.41 269.73 205.41 270.28 205.52C274.99 206.46 278.44 205.28 280.65 201.98C282.57 199.1 282.3 196.43 279.84 193.97C272.74 186.87 262.76 184.79 249.9 187.72C237.89 190.47 232.39 195.84 233.39 203.83C233.42 204.11 233.43 204.39 233.41 204.67C233.39 204.96 233.34 205.23 233.27 205.51C233.19 205.78 233.09 206.04 232.97 206.29C232.84 206.54 232.69 206.78 232.51 207.01C232.34 207.23 232.15 207.43 231.94 207.62C231.72 207.8 231.49 207.96 231.24 208.1C231 208.24 230.74 208.36 230.48 208.45C230.21 208.53 229.93 208.6 229.65 208.63C229.37 208.67 229.09 208.68 228.81 208.66C228.53 208.63 228.25 208.59 227.98 208.51C227.71 208.44 227.45 208.34 227.19 208.21C226.94 208.08 226.7 207.93 226.48 207.76C226.26 207.59 226.05 207.39 225.87 207.18C225.68 206.97 225.52 206.74 225.38 206.49C225.24 206.24 225.13 205.99 225.04 205.72C224.95 205.45 224.89 205.18 224.85 204.9ZM246.92 258.27C213.2 246.11 192.93 220.05 186.11 188.24C169.98 201.68 161.92 220.49 161.92 247.37C161.92 258.08 163.9 268.26 167.55 277.62C167.76 276.81 168.09 276.05 168.53 275.34C168.98 274.63 169.52 274.01 170.16 273.46C170.8 272.93 171.51 272.5 172.28 272.18C173.05 271.86 173.86 271.66 174.69 271.59C175.13 271.56 175.56 271.56 176 271.59C176.44 271.62 176.87 271.69 177.29 271.8C177.72 271.91 178.13 272.04 178.53 272.22C178.93 272.39 179.32 272.59 179.69 272.82C195.74 283.04 212.43 289.84 229.75 293.23C227.08 287.08 224.4 280.93 221.73 274.78C221.68 274.66 221.63 274.55 221.58 274.43C221.54 274.32 221.5 274.2 221.46 274.08C221.42 273.96 221.38 273.84 221.35 273.72C221.31 273.6 221.28 273.47 221.26 273.35C221.02 272.31 220.99 271.26 221.17 270.21C221.35 269.15 221.73 268.17 222.3 267.27C222.87 266.36 223.59 265.6 224.46 264.99C225.33 264.37 226.29 263.94 227.33 263.7C234.25 262.13 240.78 260.32 246.92 258.27ZM239.2 294.74C235.84 287.01 232.48 279.29 229.12 271.56C288.26 258.12 317.82 228.56 325.89 188.24C342.02 201.68 350.08 220.49 350.08 247.37C350.08 258.08 348.1 268.26 344.45 277.62C344.4 277.41 344.34 277.21 344.27 277.01C344.2 276.81 344.12 276.61 344.04 276.42C343.95 276.22 343.86 276.03 343.76 275.85C343.66 275.66 343.56 275.48 343.44 275.3C342.87 274.4 342.15 273.64 341.27 273.02C340.39 272.41 339.43 271.99 338.39 271.76C337.35 271.53 336.3 271.5 335.24 271.69C334.19 271.87 333.21 272.25 332.31 272.82C308.29 288.11 282.85 295.76 256 295.76C250.33 295.76 244.73 295.42 239.2 294.74ZM291.18 233.93C282.48 241.72 271.8 248.29 259.16 253.66C243.34 249.72 230.27 243.15 219.94 233.93C243.69 233.93 267.44 233.93 291.18 233.93Z';

Path? _symbolPath;

Path splashRevealSymbolPath() {
  // Fork: the outline is Tyne's glyph, written by tyne-tools scripts/install_icon_kit.py. Its
  // cut-outs are shapes drawn inside shapes, which only the even-odd rule leaves open.
  return _symbolPath ??= _parseSplashRevealSvgPath(_kFluxerSymbolPathData)
    ..fillType = PathFillType.evenOdd;
}

Path _parseSplashRevealSvgPath(String source) {
  final Path path = Path();
  final List<double> args = <double>[];
  String command = 'M';
  double cx = 0;
  double cy = 0;
  double startX = 0;
  double startY = 0;

  void apply() {
    switch (command) {
      case 'M':
      case 'm':
        final bool relative = command == 'm';
        for (int i = 0; i + 1 < args.length; i += 2) {
          if (relative) {
            cx += args[i];
            cy += args[i + 1];
          } else {
            cx = args[i];
            cy = args[i + 1];
          }
          if (i == 0) {
            path.moveTo(cx, cy);
            startX = cx;
            startY = cy;
          } else {
            path.lineTo(cx, cy);
          }
        }
      case 'C':
      case 'c':
        final bool relative = command == 'c';
        for (int i = 0; i + 5 < args.length; i += 6) {
          final double x1 = relative ? cx + args[i] : args[i];
          final double y1 = relative ? cy + args[i + 1] : args[i + 1];
          final double x2 = relative ? cx + args[i + 2] : args[i + 2];
          final double y2 = relative ? cy + args[i + 3] : args[i + 3];
          final double x = relative ? cx + args[i + 4] : args[i + 4];
          final double y = relative ? cy + args[i + 5] : args[i + 5];
          path.cubicTo(x1, y1, x2, y2, x, y);
          cx = x;
          cy = y;
        }
      case 'Z':
      case 'z':
        path.close();
        cx = startX;
        cy = startY;
    }
    args.clear();
  }

  final Iterable<RegExpMatch> tokens = RegExp(
    r'([MmZzCc])|([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)',
  ).allMatches(source);
  for (final RegExpMatch token in tokens) {
    final String? nextCommand = token.group(1);
    if (nextCommand != null) {
      apply();
      command = nextCommand;
      continue;
    }
    args.add(double.parse(token.group(2)!));
  }
  apply();
  return path;
}

double splashRevealFadePhaseProgress(double progress) {
  if (progress <= SplashRevealOverlay.pulseEndFraction) {
    return 0;
  }
  return ((progress - SplashRevealOverlay.pulseEndFraction) /
          (1 - SplashRevealOverlay.pulseEndFraction))
      .clamp(0.0, 1.0);
}

double splashRevealLogoScale(
  double progress, {
  required bool reducedMotion,
  required bool useLogoZoomTransition,
}) {
  if (reducedMotion) {
    return 1;
  }
  if (progress <= SplashRevealOverlay.pulseEndFraction) {
    final double t = Curves.easeInCubic.transform(
      progress / SplashRevealOverlay.pulseEndFraction,
    );
    return lerpDouble(1, SplashRevealOverlay.pulseScale, t)!;
  }
  if (!useLogoZoomTransition) {
    final double fadeT = splashRevealFadePhaseProgress(progress);
    return lerpDouble(
      SplashRevealOverlay.pulseScale,
      SplashRevealOverlay.fadeEndScale,
      Curves.easeOut.transform(fadeT),
    )!;
  }
  final double expandT = splashRevealFadePhaseProgress(progress);
  return lerpDouble(
    SplashRevealOverlay.pulseScale,
    SplashRevealOverlay.expandScale,
    Curves.easeInCubic.transform(expandT),
  )!;
}

double splashRevealLayerOpacity(
  double progress, {
  required bool reducedMotion,
}) {
  final double p = progress.clamp(0.0, 1.0);
  if (reducedMotion) {
    return 1 - Curves.easeOut.transform(p);
  }
  if (p <= SplashRevealOverlay.pulseEndFraction) {
    return 1;
  }
  final double fadeT = splashRevealFadePhaseProgress(p);
  return 1 - Curves.easeOut.transform(fadeT);
}

double splashRevealSymbolOpacity(double progress) {
  const double fadeWindow = 0.5;
  final double windowT = (splashRevealFadePhaseProgress(progress) / fadeWindow)
      .clamp(0.0, 1.0);
  return 1 - Curves.easeInOut.transform(windowT);
}

double splashRevealShellScale(
  double progress, {
  required bool reducedMotion,
  required bool useLogoZoomTransition,
}) {
  if (reducedMotion || !useLogoZoomTransition) {
    return 1;
  }
  final double t = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
  return lerpDouble(SplashRevealOverlay.shellStartScale, 1, t)!;
}
