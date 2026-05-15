import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

const _noLigatures = <FontFeature>[
  FontFeature.disable('liga'),
  FontFeature.disable('calt'),
];

/// Lays out a left-side line-number gutter alongside a code body, sizing each
/// gutter cell to match the wrapped height of its logical line so numbers stay
/// aligned even when `wrap` is on.
///
/// The body is positioned via `bodyBuilder(maxWidth)` so the caller can use
/// the available width for a horizontally-scrollable SelectableText or a
/// regular TextField.
class LineNumberedCode extends StatelessWidget {
  final String text;
  final TextStyle codeStyle;
  final bool wrap;
  final Widget Function(BuildContext context, double maxWidth) bodyBuilder;

  const LineNumberedCode({
    super.key,
    required this.text,
    required this.codeStyle,
    required this.wrap,
    required this.bodyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lines = text.isEmpty ? [''] : text.split('\n');
    final lineCount = lines.length;
    final gutterWidth = (lineCount.toString().length * 9.0) + 16.0;

    final gutterStyle = GoogleFonts.jetBrainsMono(
      fontSize: codeStyle.fontSize,
      height: codeStyle.height,
      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
      fontFeatures: _noLigatures,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const dividerInset = KuberSpacing.md;
        final bodyMaxWidth =
            (constraints.maxWidth - gutterWidth - dividerInset)
                .clamp(0.0, double.infinity);

        // Measure the wrapped height of each logical line so the matching
        // gutter cell can be sized to fit.
        final heights = <double>[];
        final painter = TextPainter(textDirection: TextDirection.ltr);
        for (final line in lines) {
          painter.text = TextSpan(
            text: line.isEmpty ? ' ' : line,
            style: codeStyle,
          );
          if (wrap) {
            painter.layout(maxWidth: bodyMaxWidth);
          } else {
            painter.layout();
          }
          heights.add(painter.height);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: gutterWidth,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: cs.outline)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < lineCount; i++)
                    SizedBox(
                      height: heights[i],
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Text('${i + 1}', style: gutterStyle),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: dividerInset),
            Expanded(child: bodyBuilder(context, bodyMaxWidth)),
          ],
        );
      },
    );
  }
}
