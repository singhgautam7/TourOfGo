import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/utils/go_syntax_highlighter.dart';
import '../../../providers/settings_provider.dart';
import 'code_card_chrome.dart';
import 'line_numbered_code.dart';

class CodeInlineCard extends ConsumerWidget {
  final CodeFile file;

  const CodeInlineCard({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return CodeCardChrome(
      filename: file.name,
      body: Padding(
        padding: const EdgeInsets.only(bottom: KuberSpacing.lg),
        child: LineNumberedCode(
          text: file.content,
          codeStyle: codeStyle,
          wrap: wrap,
          bodyBuilder: (context, maxWidth) {
            final body = SelectableText.rich(
              TextSpan(
                children: GoSyntaxHighlighter.highlight(
                  file.content,
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
    );
  }
}
