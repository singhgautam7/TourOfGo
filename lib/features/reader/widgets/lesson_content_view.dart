import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/html_parser.dart';
import '../../../providers/settings_provider.dart';

const _noLigatures = <FontFeature>[
  FontFeature.disable('liga'),
  FontFeature.disable('calt'),
];

class LessonContentView extends ConsumerWidget {
  final List<ContentBlock> blocks;
  final double fontSize;

  const LessonContentView({
    super.key,
    required this.blocks,
    this.fontSize = 15.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final wrap = ref.watch(settingsNotifierProvider).wrapLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks
          .map((block) => _buildBlock(block, context, cs, wrap))
          .toList(),
    );
  }

  Widget _buildBlock(
      ContentBlock block, BuildContext context, ColorScheme cs, bool wrap) {
    if (block is ParagraphBlock) {
      return Padding(
        padding: const EdgeInsets.only(bottom: KuberSpacing.md),
        child: Text.rich(
          TextSpan(
            children: block.spans,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              color: cs.onSurface,
              height: 1.55,
            ),
          ),
        ),
      );
    }

    if (block is CodePreBlock) {
      final preText = SelectableText(
        block.code,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12.5,
          color: cs.onSurface,
          height: 1.55,
          fontFeatures: _noLigatures,
        ),
      );
      return Container(
        margin: const EdgeInsets.only(bottom: KuberSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        padding: const EdgeInsets.all(KuberSpacing.md),
        child: wrap
            ? preText
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: preText,
              ),
      );
    }

    if (block is BulletListBlock) {
      return Padding(
        padding: const EdgeInsets.only(bottom: KuberSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: block.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: item,
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          color: cs.onSurface,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
