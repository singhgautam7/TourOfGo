import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/go_tour_prefs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool(GoTourPrefs.onboarded) ?? false;
    if (!mounted) return;
    if (onboarded) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App icon — Go mark
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(KuberRadius.xl),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: _GoMarkSvg(size: 44, color: cs.primary),
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
              Text(
                'A Tour of Go',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              Text(
                'go.dev',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoMarkSvg extends StatelessWidget {
  final double size;
  final Color color;
  const _GoMarkSvg({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoMarkPainter(color: color),
    );
  }
}

class _GoMarkPainter extends CustomPainter {
  final Color color;
  const _GoMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw a stylized "Go" word — G letter arc + horizontal bar
    final gPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.1
      ..strokeCap = StrokeCap.round;

    // G arc
    final gRect = Rect.fromCenter(
      center: Offset(w * 0.32, h * 0.5),
      width: w * 0.45,
      height: h * 0.55,
    );
    canvas.drawArc(
        gRect, 0.3, 5.3, false, gPaint); // ~300° arc starting from top-right
    // horizontal bar at 3 o'clock of G
    canvas.drawLine(
      Offset(w * 0.32 + w * 0.225, h * 0.5),
      Offset(w * 0.32 + w * 0.225, h * 0.38),
      gPaint,
    );
    canvas.drawLine(
      Offset(w * 0.32 + w * 0.225 - w * 0.12, h * 0.38),
      Offset(w * 0.32 + w * 0.225, h * 0.38),
      gPaint,
    );

    // O donut
    final oPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.1
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(w * 0.78, h * 0.5), w * 0.14, oPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
