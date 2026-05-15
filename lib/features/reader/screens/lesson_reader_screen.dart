import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/utils/html_parser.dart';
import '../../../providers/tour_content_provider.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/compile_provider.dart';
import '../widgets/lesson_content_view.dart';
import '../widgets/code_inline_card.dart';
import '../widgets/run_button.dart';
import '../widgets/output_panel.dart';
import '../widgets/lesson_nav_bar.dart';
import '../widgets/lesson_info_sheet.dart';
import '../widgets/link_bottom_sheet.dart';
import '../../completion/widgets/chapter_completion_overlay.dart';
import '../../navigation/widgets/chapter_nav_sheet.dart';

class LessonReaderScreen extends ConsumerStatefulWidget {
  final LessonPosition position;

  const LessonReaderScreen({super.key, required this.position});

  @override
  ConsumerState<LessonReaderScreen> createState() =>
      _LessonReaderScreenState();
}

class _LessonReaderScreenState extends ConsumerState<LessonReaderScreen> {
  final _scrollController = ScrollController();
  OverlayEntry? _completionOverlay;

  String get _chapterKey => widget.position.chapterKey;
  int get _lessonIndex => widget.position.lessonIndex;


  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _scrollController.dispose();
    _completionOverlay?.remove();
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
      _scrollController.animateTo(
        (_scrollController.offset + 180).clamp(
            0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
      _scrollController.animateTo(
        (_scrollController.offset - 180).clamp(
            0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      return true;
    }
    return false;
  }

  void _handleNext(Map<String, ChapterData> content) async {
    final isLast = ref
        .read(lessonPositionNotifierProvider.notifier)
        .isLastLessonInChapter(content);

    if (isLast) {
      ref
          .read(progressNotifierProvider.notifier)
          .markComplete(_chapterKey, _lessonIndex);
      _showCompletionOverlay(content);
    } else {
      final advanced = await ref
          .read(lessonPositionNotifierProvider.notifier)
          .nextLesson(content);
      if (!advanced && mounted) {
        final newPos = ref.read(lessonPositionNotifierProvider);
        context.pushReplacement('/reader', extra: newPos);
      }
    }
  }

  void _handlePrev(Map<String, ChapterData> content) async {
    if (_lessonIndex <= 0) return;
    await ref.read(lessonPositionNotifierProvider.notifier).prevLesson();
    if (mounted) {
      final newPos = ref.read(lessonPositionNotifierProvider);
      context.pushReplacement('/reader', extra: newPos);
    }
  }

  void _showCompletionOverlay(Map<String, ChapterData> content) {
    final ordered = orderedChapters(content);
    final chapterIdx =
        ordered.indexWhere((e) => e.key == _chapterKey);
    final hasNext = chapterIdx >= 0 && chapterIdx < ordered.length - 1;
    final chapterName =
        kChapterDisplayNames[_chapterKey] ?? content[_chapterKey]?.title ?? '';
    final totalLessons = content[_chapterKey]?.pages.length ?? 0;
    final overall = ref
        .read(progressNotifierProvider.notifier)
        .overallProgress(content);

    _completionOverlay = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: ChapterCompletionOverlay(
          chapterName: chapterName,
          lessonsCompleted: totalLessons,
          totalLessons: totalLessons,
          overallProgress: overall,
          onNextChapter: () {
            _completionOverlay?.remove();
            _completionOverlay = null;
            if (hasNext) {
              final nextChapter = ordered[chapterIdx + 1];
              ref
                  .read(lessonPositionNotifierProvider.notifier)
                  .goTo(nextChapter.key, 0);
              final newPos = ref.read(lessonPositionNotifierProvider);
              context.pushReplacement('/reader', extra: newPos);
            } else {
              context.go('/');
            }
          },
          onBrowse: () {
            _completionOverlay?.remove();
            _completionOverlay = null;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              useRootNavigator: true,
              builder: (_) => DraggableScrollableSheet(
                initialChildSize: 0.55,
                minChildSize: 0.15,
                maxChildSize: 0.95,
                snap: true,
                snapSizes: const [0.15, 0.55, 0.95],
                builder: (ctx, scrollController) => ChapterNavSheetContent(
                    scrollController: scrollController),
              ),
            );
          },
          onDismiss: () {
            _completionOverlay?.remove();
            _completionOverlay = null;
          },
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_completionOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final contentState = ref.watch(tourContentNotifierProvider);

    return contentState.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (content) {
        final chapter = content[_chapterKey];
        if (chapter == null) {
          return Scaffold(
            body: Center(child: Text('Chapter not found: $_chapterKey')),
          );
        }
        final totalLessons = chapter.pages.length;
        final lesson = chapter.pages.length > _lessonIndex
            ? chapter.pages[_lessonIndex]
            : null;
        if (lesson == null) {
          return const Scaffold(body: Center(child: Text('Lesson not found')));
        }

        final compileState = ref.watch(compileNotifierProvider(
          _chapterKey,
          _lessonIndex,
        ));

        final parsedBlocks = GoHtmlParser.parse(
          lesson.content,
          context,
          onLinkTap: onLinkTap,
        );

        final chapterName =
            kChapterDisplayNames[_chapterKey] ?? chapter.title;

        return Scaffold(
          backgroundColor: cs.surface,
          body: Column(
            children: [
              // Top bar
              _ReaderTopBar(
                chapterName: chapterName,
                lessonIndex: _lessonIndex,
                totalLessons: totalLessons,
                lesson: lesson,
                onBack: () => context.pop(),
                onHome: () => context.go('/'),
                cs: cs,
              ),

              // Scrollable content
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0) < -300) {
                      _handleNext(content);
                    } else if ((details.primaryVelocity ?? 0) > 300) {
                      _handlePrev(content);
                    }
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(KuberSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lesson title
                          Text(
                            lesson.title,
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.6,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: KuberSpacing.lg),

                          // Parsed content
                          LessonContentView(blocks: parsedBlocks),

                          // Code + Run + Output
                          if (lesson.files.isNotEmpty) ...[
                            const SizedBox(height: KuberSpacing.xl),
                            CodeInlineCard(file: lesson.files.first),
                            const SizedBox(height: KuberSpacing.md),
                            RunButton(
                              isRunning: compileState.isLoading,
                              onTap: () {
                                ref
                                    .read(compileNotifierProvider(
                                      _chapterKey,
                                      _lessonIndex,
                                    ).notifier)
                                    .runCode(lesson.files.first.content);
                              },
                            ),
                            if (compileState.hasValue &&
                                compileState.value != null)
                              OutputPanel(
                                  response: compileState.value!),
                          ],

                          const SizedBox(height: KuberSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Nav bar
              LessonNavBar(
                onPrev: () => _handlePrev(content),
                onNext: () => _handleNext(content),
                currentIndex: _lessonIndex,
                totalLessons: totalLessons,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReaderTopBar extends StatelessWidget {
  final String chapterName;
  final int lessonIndex;
  final int totalLessons;
  final LessonData lesson;
  final VoidCallback onBack;
  final VoidCallback onHome;
  final ColorScheme cs;

  const _ReaderTopBar({
    required this.chapterName,
    required this.lessonIndex,
    required this.totalLessons,
    required this.lesson,
    required this.onBack,
    required this.onHome,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(bottom: BorderSide(color: cs.outline)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  KuberSpacing.md, KuberSpacing.sm, KuberSpacing.md, KuberSpacing.sm),
              child: Row(
                children: [
                  _ChipButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: onBack,
                    cs: cs,
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  _ChipButton(
                    icon: Icons.home_outlined,
                    onTap: onHome,
                    cs: cs,
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          chapterName,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Lesson ${lessonIndex + 1} of $totalLessons',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  // Info button
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        builder: (_) => LessonInfoSheet(
                          lesson: lesson,
                          chapterName: chapterName,
                          lessonNum: lessonIndex + 1,
                          totalLessons: totalLessons,
                        ),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.outline),
                        borderRadius:
                            BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            LinearProgressIndicator(
              value: (lessonIndex + 1) / totalLessons,
              minHeight: 2,
              backgroundColor: cs.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _ChipButton({required this.icon, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface),
      ),
    );
  }
}
