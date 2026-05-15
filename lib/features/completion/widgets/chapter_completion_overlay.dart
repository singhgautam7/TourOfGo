import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/go_tour_button.dart';

class ChapterCompletionOverlay extends StatefulWidget {
  final String chapterName;
  final int lessonsCompleted;
  final int totalLessons;
  final double overallProgress;
  final VoidCallback onNextChapter;
  final VoidCallback onBrowse;
  final VoidCallback onDismiss;

  const ChapterCompletionOverlay({
    super.key,
    required this.chapterName,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.overallProgress,
    required this.onNextChapter,
    required this.onBrowse,
    required this.onDismiss,
  });

  @override
  State<ChapterCompletionOverlay> createState() =>
      _ChapterCompletionOverlayState();
}

class _ChapterCompletionOverlayState extends State<ChapterCompletionOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _dimAnim;
  late final Animation<double> _circleAnim;
  late final Animation<double> _checkAnim;
  late final Animation<double> _contentAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _dimAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.33, curve: Curves.easeOut),
      ),
    );
    _circleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.33, curve: Curves.elasticOut),
      ),
    );
    _checkAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.33, 0.66, curve: Curves.easeOut),
      ),
    );
    _contentAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.66, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Dim overlay
              Opacity(
                opacity: _dimAnim.value * 0.88,
                child: Container(color: cs.surface),
              ),

              // Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success checkmark
                      _SuccessMark(
                        circleProgress: _circleAnim.value,
                        checkProgress: _checkAnim.value,
                        cs: cs,
                      ),

                      // Text content — slides + fades in
                      Transform.translate(
                        offset: Offset(0, (1 - _contentAnim.value) * 16),
                        child: Opacity(
                          opacity: _contentAnim.value,
                          child: Column(
                            children: [
                              const SizedBox(height: 28),
                              Text(
                                'Chapter complete!',
                                style: GoogleFonts.inter(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                  letterSpacing: -0.7,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Chapter: ${widget.chapterName}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: cs.onSurfaceVariant,
                                  letterSpacing: -0.2,
                                ),
                              ),

                              // Stats card
                              const SizedBox(height: 22),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainer,
                                  borderRadius: BorderRadius.circular(KuberRadius.md),
                                  border: Border.all(color: cs.outline),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _Stat(
                                      label: 'LESSONS',
                                      value: '${widget.lessonsCompleted}',
                                      sub: 'completed',
                                      cs: cs,
                                    ),
                                    const SizedBox(width: 18),
                                    Container(
                                        width: 1,
                                        height: 36,
                                        color: cs.outline),
                                    const SizedBox(width: 18),
                                    _Stat(
                                      label: 'TOUR',
                                      value:
                                          '${(widget.overallProgress * 100).round()}%',
                                      sub: 'of total',
                                      cs: cs,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),
                              GoTourButton(
                                label: 'Next chapter',
                                icon: Icons.arrow_forward_rounded,
                                iconAfterLabel: true,
                                type: GoTourButtonType.primary,
                                fullWidth: true,
                                onPressed: widget.onNextChapter,
                              ),
                              const SizedBox(height: 10),
                              GoTourButton(
                                label: 'Browse chapters',
                                type: GoTourButtonType.outline,
                                fullWidth: true,
                                onPressed: widget.onBrowse,
                              ),
                              const SizedBox(height: 14),
                              TextButton(
                                onPressed: widget.onDismiss,
                                child: Text(
                                  'Stay here',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuccessMark extends StatelessWidget {
  final double circleProgress;
  final double checkProgress;
  final ColorScheme cs;

  const _SuccessMark({
    required this.circleProgress,
    required this.checkProgress,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: CustomPaint(
        painter: _CheckmarkPainter(
          circleProgress: circleProgress,
          checkProgress: checkProgress,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double circleProgress;
  final double checkProgress;
  final Color color;

  const _CheckmarkPainter({
    required this.circleProgress,
    required this.checkProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Glow ring
    canvas.drawCircle(
      center,
      radius * circleProgress * 1.2,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    // Filled circle
    canvas.drawCircle(
      center,
      radius * circleProgress,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Checkmark path
    if (checkProgress > 0) {
      final path = Path()
        ..moveTo(size.width * 0.2, size.height * 0.5)
        ..lineTo(size.width * 0.42, size.height * 0.72)
        ..lineTo(size.width * 0.8, size.height * 0.28);

      final metric = path.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * checkProgress),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter old) =>
      old.circleProgress != circleProgress || old.checkProgress != checkProgress;
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final ColorScheme cs;

  const _Stat({
    required this.label,
    required this.value,
    required this.sub,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: cs.primary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        Text(
          sub,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
