import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/utils/tour_url.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/url_box.dart';
import '../../../shared/widgets/kuber_list.dart';

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
    final url = tourUrlFor(chapterKey, lessonNum - 1);

    return KuberBottomSheet(
      title: lesson.title,
      subtitle: '$chapterName · Lesson $lessonNum of $totalLessons',
      actions: AppButton(
        label: 'Open in Browser',
        icon: Icons.open_in_new_rounded,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () async {
          final uri = Uri.parse(url);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {
            // fallback: try the default mode
            await launchUrl(uri);
          }
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KuberSectionHeader(title: 'Source'),
          UrlBox(url),
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
  showKuberBottomSheet<void>(
    context,
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
