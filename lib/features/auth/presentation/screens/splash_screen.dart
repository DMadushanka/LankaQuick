import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lAnimation;
  late Animation<double> _qAnimation;
  late Animation<double> _shockwaveAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _ambientScaleAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Phase 1: Draw Logo L-stroke (0.0 to 0.40)
    _lAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeInOutCubic),
      ),
    );

    // Phase 2: Draw lightning Q-stroke (0.40 to 0.70)
    _qAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    // Phase 3: Speed shockwave burst (0.68 to 0.85)
    _shockwaveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.68, 0.85, curve: Curves.easeOutQuad),
      ),
    );

    // Phase 4: Glow container fade in (0.70 to 0.90)
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 0.90, curve: Curves.easeIn),
      ),
    );

    // Phase 5: Text Fade In (0.50 to 0.85)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.85, curve: Curves.easeOut),
      ),
    );

    // Phase 6: Text Slide Up slightly (0.50 to 0.85)
    _textSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.85, curve: Curves.easeOutBack),
      ),
    );

    // Ambient glow pulse animation (loops from 0.9 to 1.1 scale)
    _ambientScaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    // Logo scale transition (0.0 to 0.60)
    _logoScaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutBack),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Switch the splash complete state to trigger navigation reactively
        ref.read(splashCompletedProvider.notifier).complete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      body: Stack(
        children: [
          // Dynamic ambient top blur
          AnimatedBuilder(
            animation: _ambientScaleAnimation,
            builder: (context, child) {
              return Positioned(
                top: -100,
                left: -100,
                child: Transform.scale(
                  scale: _ambientScaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          // Dynamic ambient bottom blur
          AnimatedBuilder(
            animation: _ambientScaleAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: -100,
                right: -100,
                child: Transform.scale(
                  scale: _ambientScaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orangeAccent.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),

          // Main Animated Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom Graphical Logo Painter Container
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: SizedBox(
                        width: 200,
                        height: 140,
                        child: CustomPaint(
                          painter: LankaQuickLogoPainter(
                            drawLProgress: _lAnimation.value,
                            drawQProgress: _qAnimation.value,
                            shockwaveProgress: _shockwaveAnimation.value,
                            glowOpacity: _glowAnimation.value,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),

                // Animated branding text
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _textSlideAnimation.value),
                      child: Opacity(
                        opacity: _textFadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'LankaQuick',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          color: isDark ? Colors.white : Colors.black87,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'FASTEST LOCAL CONNECTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Canvas Painter drawing a premium lightning-speed "L" & "Q" monogram logo
class LankaQuickLogoPainter extends CustomPainter {
  final double drawLProgress; // 0.0 to 1.0
  final double drawQProgress; // 0.0 to 1.0
  final double shockwaveProgress; // 0.0 to 1.0
  final double glowOpacity; // 0.0 to 1.0

  LankaQuickLogoPainter({
    required this.drawLProgress,
    required this.drawQProgress,
    required this.shockwaveProgress,
    required this.glowOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Anchor points for L
    final lStart = Offset(w * 0.38, h * 0.22);
    final lCorner = Offset(w * 0.38, h * 0.78);
    final lEnd = Offset(w * 0.58, h * 0.78);

    final lPath = Path();
    lPath.moveTo(lStart.dx, lStart.dy);

    final stemLen = lCorner.dy - lStart.dy;
    final baseLen = lEnd.dx - lCorner.dx;
    final totalLen = stemLen + baseLen;

    if (drawLProgress > 0.0) {
      final currentLen = totalLen * drawLProgress;
      if (currentLen <= stemLen) {
        lPath.lineTo(lStart.dx, lStart.dy + currentLen);
      } else {
        lPath.lineTo(lCorner.dx, lCorner.dy);
        lPath.lineTo(lCorner.dx + (currentLen - stemLen), lCorner.dy);
      }
    }

    // Glow effect for L stroke
    final blueGlowPaint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.3 * drawLProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final blueLinePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.blueAccent, Colors.cyanAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTRB(w * 0.3, h * 0.2, w * 0.6, h * 0.8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    if (drawLProgress > 0.0) {
      canvas.drawPath(lPath, blueGlowPaint);
      canvas.drawPath(lPath, blueLinePaint);
    }

    // Anchor points for lightning slash (Q)
    final qStart = Offset(w * 0.66, h * 0.16);
    final qBend1 = Offset(w * 0.50, h * 0.52);
    final qBend2 = Offset(w * 0.62, h * 0.50);
    final qEnd = Offset(w * 0.46, h * 0.88);

    final qPath = Path();
    qPath.moveTo(qStart.dx, qStart.dy);

    final qSeg1 = qBend1 - qStart;
    final qSeg2 = qBend2 - qBend1;
    final qSeg3 = qEnd - qBend2;

    final qLen1 = qSeg1.distance;
    final qLen2 = qSeg2.distance;
    final qLen3 = qSeg3.distance;
    final qTotalLen = qLen1 + qLen2 + qLen3;

    if (drawQProgress > 0.0) {
      final currentQLen = qTotalLen * drawQProgress;
      if (currentQLen <= qLen1) {
        final ratio = currentQLen / qLen1;
        qPath.lineTo(qStart.dx + qSeg1.dx * ratio, qStart.dy + qSeg1.dy * ratio);
      } else if (currentQLen <= qLen1 + qLen2) {
        qPath.lineTo(qBend1.dx, qBend1.dy);
        final ratio = (currentQLen - qLen1) / qLen2;
        qPath.lineTo(qBend1.dx + qSeg2.dx * ratio, qBend1.dy + qSeg2.dy * ratio);
      } else {
        qPath.lineTo(qBend1.dx, qBend1.dy);
        qPath.lineTo(qBend2.dx, qBend2.dy);
        final ratio = (currentQLen - qLen1 - qLen2) / qLen3;
        qPath.lineTo(qBend2.dx + qSeg3.dx * ratio, qBend2.dy + qSeg3.dy * ratio);
      }
    }

    // Glow effect for lightning stroke
    final orangeGlowPaint = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: 0.35 * drawQProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final orangeLinePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.orangeAccent, Colors.amberAccent],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTRB(w * 0.4, h * 0.1, w * 0.7, h * 0.9))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    if (drawQProgress > 0.0) {
      canvas.drawPath(qPath, orangeGlowPaint);
      canvas.drawPath(qPath, orangeLinePaint);
    }

    // Premium background gradient pulse shape
    if (glowOpacity > 0.0) {
      final shieldPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.orangeAccent.withValues(alpha: 0.12 * glowOpacity),
            Colors.blueAccent.withValues(alpha: 0.02 * glowOpacity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.4))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.35, shieldPaint);
    }

    // Radiating shockwave lines at strike intersection point (approx (w * 0.53, h * 0.78))
    if (shockwaveProgress > 0.0 && shockwaveProgress < 1.0) {
      final strikeCenter = Offset(w * 0.53, h * 0.78);
      final numSpokes = 8;
      final wavePaint = Paint()
        ..color = Colors.amberAccent.withValues(alpha: 1.0 - shockwaveProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < numSpokes; i++) {
        final double angle = (i * 2 * pi) / numSpokes;
        final cosA = cos(angle);
        final sinA = sin(angle);

        final startDistance = 15 * shockwaveProgress;
        final endDistance = 45 * shockwaveProgress;

        final startPt = Offset(strikeCenter.dx + cosA * startDistance, strikeCenter.dy + sinA * startDistance);
        final endPt = Offset(strikeCenter.dx + cosA * endDistance, strikeCenter.dy + sinA * endDistance);

        canvas.drawLine(startPt, endPt, wavePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LankaQuickLogoPainter oldDelegate) {
    return oldDelegate.drawLProgress != drawLProgress ||
        oldDelegate.drawQProgress != drawQProgress ||
        oldDelegate.shockwaveProgress != shockwaveProgress ||
        oldDelegate.glowOpacity != glowOpacity;
  }
}
