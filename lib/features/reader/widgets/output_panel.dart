import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/settings_provider.dart';

const _stdoutGreen = Color(0xFF22C55E);

const _noLigatures = <FontFeature>[
  FontFeature.disable('liga'),
  FontFeature.disable('calt'),
];

class OutputPanel extends ConsumerStatefulWidget {
  final CompileResponse response;

  const OutputPanel({super.key, required this.response});

  @override
  ConsumerState<OutputPanel> createState() => _OutputPanelState();
}

class _OutputPanelState extends ConsumerState<OutputPanel> {
  String _stdout = '';
  String _stderr = '';
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
      setState(() {
        _stdout = '';
        _stderr = '';
        _totalDelayMs = 0;
      });
      _replayEvents();
    }
  }

  Future<void> _replayEvents() async {
    for (final event in widget.response.events) {
      if (!mounted) return;
      // API returns Delay in nanoseconds.
      final delayNs = event.delay > 0 ? event.delay : 0;
      if (delayNs > 0) {
        await Future.delayed(Duration(microseconds: delayNs ~/ 1000));
      }
      if (!mounted) return;
      setState(() {
        if (event.kind == 'stderr') {
          _stderr += event.message;
        } else {
          _stdout += event.message;
        }
        _totalDelayMs += delayNs ~/ 1000000;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wrap = ref.watch(settingsNotifierProvider).wrapLines;
    final compileError = widget.response.errors;
    final hasCompileError = compileError.isNotEmpty;
    final hasStdout = _stdout.isNotEmpty;
    final hasStderr = _stderr.isNotEmpty;

    return Column(
      children: [
        if (hasCompileError)
          _Panel(
            label: 'STDERR',
            body: compileError,
            isError: true,
            wrap: wrap,
          )
        else ...[
          if (hasStdout || !hasStderr)
            _Panel(
              label: 'STDOUT',
              body: _stdout,
              isError: false,
              wrap: wrap,
              delayMs: _totalDelayMs,
            ),
          if (hasStderr)
            _Panel(
              label: 'STDERR',
              body: _stderr,
              isError: true,
              wrap: wrap,
            ),
        ],
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final String label;
  final String body;
  final bool isError;
  final bool wrap;
  final int? delayMs;

  const _Panel({
    required this.label,
    required this.body,
    required this.isError,
    required this.wrap,
    this.delayMs,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dotColor = isError ? cs.error : _stdoutGreen;
    final body = SelectableText(
      this.body,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 13,
        color: isError ? cs.error : cs.onSurface,
        height: 1.6,
        fontFeatures: _noLigatures,
      ),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg, KuberSpacing.md, KuberSpacing.lg, 0),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isError ? cs.error : cs.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                if (delayMs != null && delayMs! > 0) ...[
                  const Spacer(),
                  Text(
                    '$delayMs ms',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10.5,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 12, color: cs.outline),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.lg),
            child: wrap
                ? body
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: body,
                  ),
          ),
        ],
      ),
    );
  }
}
