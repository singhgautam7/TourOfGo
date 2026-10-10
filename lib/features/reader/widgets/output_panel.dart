import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tourgo/core/utils/locale_font.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/settings_provider.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Errors sit on errorContainer; output on the plain card.
    final fg = isError ? cs.onErrorContainer : cs.onSurface;
    final muted = isError ? cs.onErrorContainer : cs.onSurfaceVariant;
    final body = SelectableText(
      this.body,
      style: monoFont(
        fontSize: 13,
        color: fg,
        height: 1.6,
        fontFeatures: _noLigatures,
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      margin: const EdgeInsets.only(top: KuberSpace.md),
      decoration: BoxDecoration(
        color: isError ? cs.errorContainer : cs.surfaceContainer,
        borderRadius: KuberShape.largeR,
        border: Border.all(
            color: isError ? cs.errorContainer : cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpace.lg, KuberSpace.md, KuberSpace.lg, KuberSpace.sm),
            child: Row(
              children: [
                Icon(
                  isError
                      ? Icons.error_outline_rounded
                      : Icons.terminal_rounded,
                  size: 16,
                  color: isError ? cs.onErrorContainer : cs.primary,
                ),
                const SizedBox(width: KuberSpace.sm),
                Text(
                  label,
                  style: monoFont(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: muted,
                    letterSpacing: 0.8,
                  ),
                ),
                if (delayMs != null && delayMs! > 0) ...[
                  const Spacer(),
                  Text('$delayMs ms',
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: muted)),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpace.lg, 0, KuberSpace.lg, KuberSpace.lg),
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
