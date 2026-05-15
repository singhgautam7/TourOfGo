import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';

class OutputPanel extends StatefulWidget {
  final CompileResponse response;

  const OutputPanel({super.key, required this.response});

  @override
  State<OutputPanel> createState() => _OutputPanelState();
}

class _OutputPanelState extends State<OutputPanel> {
  String _displayed = '';
  int _totalDelayMs = 0;

  @override
  void initState() {
    super.initState();
    _replayEvents();
  }

  @override
  void didUpdateWidget(OutputPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.response != widget.response) {
      setState(() => _displayed = '');
      _replayEvents();
    }
  }

  Future<void> _replayEvents() async {
    for (final event in widget.response.events) {
      if (!mounted) return;
      final delay = event.delay > 0 ? event.delay : 0;
      if (delay > 0) {
        await Future.delayed(Duration(milliseconds: delay));
      }
      if (!mounted) return;
      setState(() {
        _displayed += event.message;
        _totalDelayMs += delay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasErrors = widget.response.errors.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: KuberSpacing.md),
      decoration: BoxDecoration(
        color: hasErrors
            ? cs.error.withValues(alpha: 0.08)
            : cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(
          color: hasErrors
              ? cs.error.withValues(alpha: 0.3)
              : cs.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpacing.md, KuberSpacing.md, KuberSpacing.md, 0),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: hasErrors ? cs.error : cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  hasErrors ? 'ERROR' : 'STDOUT',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: hasErrors ? cs.error : cs.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                if (!hasErrors && _totalDelayMs > 0) ...[
                  const Spacer(),
                  Text(
                    '$_totalDelayMs ms',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10.5,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(KuberSpacing.md),
            child: SelectableText(
              hasErrors ? widget.response.errors : _displayed,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: hasErrors ? cs.error : cs.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
