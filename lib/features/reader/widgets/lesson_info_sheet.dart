import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/tour_url.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';

class LessonInfoSheet extends StatelessWidget {
  final LessonData lesson;
  final String chapterKey;
  final String chapterName;
  final int lessonNum;
  final int totalLessons;

  const LessonInfoSheet({
    super.key,
    required this.lesson,
    required this.chapterKey,
    required this.chapterName,
    required this.lessonNum,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = tourUrlFor(chapterKey, lessonNum - 1);

    return KuberBottomSheet(
      title: lesson.title,
      subtitle: '$chapterName · Lesson $lessonNum of $totalLessons',
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open in Browser'),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOURCE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KuberSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Text(
              url,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper to show the lesson info sheet using the shared bottom-sheet shell.
void showLessonInfoSheet(
  BuildContext context, {
  required LessonData lesson,
  required String chapterKey,
  required String chapterName,
  required int lessonNum,
  required int totalLessons,
}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => LessonInfoSheet(
      lesson: lesson,
      chapterKey: chapterKey,
      chapterName: chapterName,
      lessonNum: lessonNum,
      totalLessons: totalLessons,
    ),
  );
}

// Convenience for routing to the in-app reader from a parsed tour URL.
void openLessonInApp(BuildContext context, LessonPosition pos) {
  context.push('/reader', extra: pos);
}
