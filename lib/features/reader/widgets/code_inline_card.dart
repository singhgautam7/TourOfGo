import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/utils/go_syntax_highlighter.dart';
import '../../../providers/settings_provider.dart';
import 'code_card_chrome.dart';

class CodeInlineCard extends ConsumerWidget {
  final CodeFile file;

  const CodeInlineCard({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wrap = ref.watch(settingsNotifierProvider).wrapLines;

    final lineCount = '\n'.allMatches(file.content).length + 1;
    final gutterWidth = (lineCount.toString().length * 9.0) + 16.0;

    final highlightedText = SelectableText.rich(
      TextSpan(
        children: GoSyntaxHighlighter.highlight(
          file.content,
          isDark: isDark,
        ),
      ),
      style: GoogleFonts.jetBrainsMono(
        fontSize: 13,
        height: 1.6,
        fontFeatures: const [
          FontFeature.disable('liga'),
          FontFeature.disable('calt'),
        ],
      ),
    );

    return CodeCardChrome(
      filename: file.name,
      body: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: gutterWidth,
              padding:
                  const EdgeInsets.fromLTRB(8, 0, 8, KuberSpacing.lg),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: cs.outline)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  lineCount,
                  (i) => Text(
                    '${i + 1}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      height: 1.6,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      fontFeatures: const [
                        FontFeature.disable('liga'),
                        FontFeature.disable('calt'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.md, 0, KuberSpacing.lg, KuberSpacing.lg),
                child: wrap
                    ? highlightedText
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: highlightedText,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
