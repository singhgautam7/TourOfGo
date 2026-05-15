import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/utils/go_syntax_highlighter.dart';

class CodeInlineCard extends StatelessWidget {
  final CodeFile file;

  const CodeInlineCard({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File name header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg, KuberSpacing.md, KuberSpacing.lg, 0),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  file.name,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 12, color: cs.outline),
          // Horizontally scrollable code
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              KuberSpacing.lg,
              0,
              KuberSpacing.lg,
              KuberSpacing.lg,
            ),
            child: SelectableText.rich(
              TextSpan(
                children: GoSyntaxHighlighter.highlight(
                  file.content,
                  isDark: isDark,
                ),
              ),
              style: GoogleFonts.jetBrainsMono(fontSize: 13, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
