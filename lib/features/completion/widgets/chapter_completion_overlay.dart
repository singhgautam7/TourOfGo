import 'package:flutter/material.dart';
import 'package:tourgo/core/utils/locale_font.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_list.dart';

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
        curve: const Interval(0.0, 0.33, curve: Curves.easeOutBack),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                                style: theme.textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: KuberSpace.sm),
                              Text(
                                'Chapter: ${widget.chapterName}',
                                style: theme.textTheme.bodyMedium!
                                    .copyWith(color: cs.onSurfaceVariant),
                              ),
                              const SizedBox(height: KuberSpace.xl),
                              // Stat card (Kuber stat-cards.md): caps label,
                              // value, caption, in two columns.
                              KuberCard(
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _Stat(
                                          label: 'Lessons',
                                          value: '${widget.lessonsCompleted}',
                                          sub: 'completed',
                                        ),
                                      ),
                                      VerticalDivider(
                                          width: KuberSpace.xl,
                                          color: cs.outlineVariant),
                                      Expanded(
                                        child: _Stat(
                                          label: 'Tour',
                                          value:
                                              '${(widget.overallProgress * 100).round()}%',
                                          sub: 'of total',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: KuberSpace.xl),
                              AppButton(
                                label: 'Next chapter',
                                icon: Icons.arrow_forward_rounded,
                                iconAfterLabel: true,
                                type: AppButtonType.primary,
                                fullWidth: true,
                                onPressed: widget.onNextChapter,
                              ),
                              const SizedBox(height: KuberSpace.md),
                              AppButton(
                                label: 'Browse chapters',
                                type: AppButtonType.outline,
                                fullWidth: true,
                                onPressed: widget.onBrowse,
                              ),
                              const SizedBox(height: KuberSpace.sm),
                              TextButton(
                                onPressed: widget.onDismiss,
                                child: const Text('Stay here'),
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
          ring: cs.primaryContainer,
          check: cs.onPrimary,
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double circleProgress;
  final double checkProgress;
  final Color color;
  final Color ring;
  final Color check;

  const _CheckmarkPainter({
    required this.circleProgress,
    required this.checkProgress,
    required this.color,
    required this.ring,
    required this.check,
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
        ..color = ring
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
          ..color = check
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

  const _Stat({required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: sectionHeaderStyle(context)),
        const SizedBox(height: KuberSpace.xs),
        Text(value,
            style: theme.textTheme.headlineSmall!
                .copyWith(color: theme.colorScheme.primary)),
        Text(sub, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
