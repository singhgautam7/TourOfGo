import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Animated Go mark + open book illustration for the onboarding screen.
/// Adapted from the design spec's GoMarkBookIllustration SVG.
class GoIllustrationAnimation extends StatefulWidget {
  const GoIllustrationAnimation({super.key});

  @override
  State<GoIllustrationAnimation> createState() =>
      _GoIllustrationAnimationState();
}

class _GoIllustrationAnimationState extends State<GoIllustrationAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> pulse;
  late final Animation<double> fan;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    pulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    fan = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 240,
      height: 200,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => CustomPaint(
          painter: _GoIllustrationPainter(
            pulseValue: pulse.value,
            fanValue: fan.value,
            accentColor: cs.primary,
            surfaceCard: isDark
                ? GoTourColors.surfaceCard
                : GoTourLightColors.surfaceCard,
            surfaceMuted: isDark
                ? GoTourColors.surfaceMuted
                : GoTourLightColors.surfaceMuted,
            borderColor: isDark ? GoTourColors.border : GoTourLightColors.border,
            bg: cs.surface,
          ),
        ),
      ),
    );
  }
}

class _GoIllustrationPainter extends CustomPainter {
  final double pulseValue;
  final double fanValue;
  final Color accentColor;
  final Color surfaceCard;
  final Color surfaceMuted;
  final Color borderColor;
  final Color bg;

  const _GoIllustrationPainter({
    required this.pulseValue,
    required this.fanValue,
    required this.accentColor,
    required this.surfaceCard,
    required this.surfaceMuted,
    required this.borderColor,
    required this.bg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // ── Open book (bottom) ───────────────────────────────────────────────────
    final bookCy = size.height * 0.78;
    final fanAngle = fanValue * (8 * math.pi / 180); // up to 8°

    final bookFill = Paint()
      ..color = surfaceMuted
      ..style = PaintingStyle.fill;
    final bookStroke = Paint()
      ..color = accentColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;
    final linesPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final spinePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Left page rotates left
    canvas.save();
    canvas.translate(cx, bookCy);
    canvas.rotate(-fanAngle);
    canvas.translate(-cx, -bookCy);
    final leftPage = Path()
      ..moveTo(cx - 94, bookCy - 22)
      ..lineTo(cx - 2, bookCy - 22)
      ..lineTo(cx - 2, bookCy + 28)
      ..lineTo(cx - 106, bookCy + 28)
      ..close();
    canvas.drawPath(leftPage, bookFill);
    canvas.drawPath(leftPage, bookStroke);
    // Lines on left page
    for (final dy in [-10.0, 0.0, 10.0]) {
      canvas.drawLine(
        Offset(cx - 86, bookCy + dy),
        Offset(cx - 14, bookCy + dy),
        linesPaint,
      );
    }
    canvas.restore();

    // Right page rotates right
    canvas.save();
    canvas.translate(cx, bookCy);
    canvas.rotate(fanAngle);
    canvas.translate(-cx, -bookCy);
    final rightPage = Path()
      ..moveTo(cx + 2, bookCy - 22)
      ..lineTo(cx + 94, bookCy - 22)
      ..lineTo(cx + 106, bookCy + 28)
      ..lineTo(cx + 2, bookCy + 28)
      ..close();
    canvas.drawPath(rightPage, bookFill);
    canvas.drawPath(rightPage, bookStroke);
    for (final dy in [-10.0, 0.0, 10.0]) {
      canvas.drawLine(
        Offset(cx + 14, bookCy + dy),
        Offset(cx + 86, bookCy + dy),
        linesPaint,
      );
    }
    canvas.restore();

    // Spine
    canvas.drawLine(
      Offset(cx, bookCy - 22),
      Offset(cx, bookCy + 28),
      spinePaint,
    );

    // ── Go mark (top, scaled by pulse) ───────────────────────────────────────
    final markCy = size.height * 0.33;
    canvas.save();
    canvas.translate(cx, markCy);
    canvas.scale(pulseValue);
    canvas.translate(-cx, -markCy);

    // Soft glow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, markCy),
        width: 156,
        height: 72,
      ),
      Paint()
        ..color = accentColor.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill,
    );

    // Pill bg for legibility
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, markCy), width: 120, height: 80),
        const Radius.circular(KuberRadius.xl),
      ),
      Paint()
        ..color = bg.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );

    // Left circle
    canvas.drawCircle(
      Offset(cx - 22, markCy),
      34,
      Paint()
        ..color = surfaceCard
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx - 22, markCy),
      34,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Right circle
    canvas.drawCircle(
      Offset(cx + 22, markCy),
      34,
      Paint()
        ..color = surfaceCard
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx + 22, markCy),
      34,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Eyes / dots
    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 22, markCy - 2), 5, dotPaint);
    canvas.drawCircle(Offset(cx + 22, markCy - 2), 5, dotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoIllustrationPainter old) =>
      old.pulseValue != pulseValue || old.fanValue != fanValue;
}
