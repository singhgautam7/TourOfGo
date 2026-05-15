import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/progress_provider.dart';

class ChapterProgressRow extends ConsumerWidget {
  final int chapterNum;
  final String chapterKey;
  final ChapterData chapter;
  final bool showDivider;

  const ChapterProgressRow({
    super.key,
    required this.chapterNum,
    required this.chapterKey,
    required this.chapter,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final notifier = ref.read(progressNotifierProvider.notifier);
    ref.watch(progressNotifierProvider);
    final total = chapter.pages.length;
    final pct = notifier.chapterProgress(chapterKey, total);
    final done = pct >= 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md, vertical: KuberSpacing.md),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: cs.outline))
            : null,
      ),
      child: Row(
        children: [
          // Chapter number / checkmark badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: done ? cs.primary : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.sm + 2),
              border: Border.all(color: done ? cs.primary : cs.outline),
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                  : Text(
                      '$chapterNum',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kChapterDisplayNames[chapterKey] ?? chapter.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(KuberRadius.full),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 3,
                    backgroundColor: cs.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text.rich(
            TextSpan(
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: '${notifier.chapterProgress(chapterKey, total) == 1.0 ? total : (pct * total).round()}',
                  style: TextStyle(color: cs.onSurface),
                ),
                TextSpan(
                  text: '/$total',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
