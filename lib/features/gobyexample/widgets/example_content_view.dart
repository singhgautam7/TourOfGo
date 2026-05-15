import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/go_syntax_highlighter.dart';
import '../../../providers/settings_provider.dart';
import '../../reader/widgets/code_card_chrome.dart';
import '../../reader/widgets/line_numbered_code.dart';
import '../models/go_example.dart';

/// Renders a fully-downloaded [GoExample]: title, annotation+code segments,
/// then the shell output card (if any).
class ExampleContentView extends StatelessWidget {
  final GoExample example;
  final ScrollController scrollController;

  const ExampleContentView({
    super.key,
    required this.example,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return NotificationListener<ScrollStartNotification>(
      onNotification: (_) {
        FocusScope.of(context).unfocus();
        return false;
      },
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(KuberSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              example.title,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
            _CombinedExampleView(
              code: example.segments
                  .map((s) => s.code)
                  .where((c) => c.isNotEmpty)
                  .join('\n\n'),
              output: example.shellOutput,
              text: example.segments
                  .map((s) => s.annotation)
                  .where((a) => a.isNotEmpty)
                  .join('\n\n'),
              filename: '${example.slug}.go',
            ),
            const SizedBox(height: KuberSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _CombinedExampleView extends ConsumerWidget {
  final String code;
  final String output;
  final String text;
  final String filename;

  const _CombinedExampleView({
    required this.code,
    required this.output,
    required this.text,
    required this.filename,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wrap = ref.watch(settingsNotifierProvider).wrapLines;

    final codeStyle = GoogleFonts.jetBrainsMono(
      fontSize: 13,
      height: 1.6,
      fontFeatures: const [
        FontFeature.disable('liga'),
        FontFeature.disable('calt'),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (code.isNotEmpty) ...[
          CodeCardChrome(
            filename: filename,
            body: Padding(
              padding: const EdgeInsets.only(bottom: KuberSpacing.lg),
              child: LineNumberedCode(
                text: code,
                codeStyle: codeStyle,
                wrap: wrap,
                bodyBuilder: (context, maxWidth) {
                  final body = SelectableText.rich(
                    TextSpan(
                      children: GoSyntaxHighlighter.highlight(
                        code,
                        isDark: isDark,
                      ),
                    ),
                    style: codeStyle,
                  );
                  if (wrap) return body;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: body,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
        ],
        if (output.isNotEmpty) ...[
          _ShellOutputCard(output: output),
          const SizedBox(height: KuberSpacing.lg),
        ],
        if (text.isNotEmpty)
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              color: cs.onSurface,
              height: 1.6,
            ),
          ),
      ],
    );
  }
}

class _ShellOutputCard extends StatelessWidget {
  final String output;
  const _ShellOutputCard({required this.output});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: cs.primary, shape: BoxShape.circle),
            ),
            const SizedBox(width: KuberSpacing.sm),
            Text(
              'OUTPUT',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: KuberSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(KuberSpacing.lg),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              output,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: cs.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
