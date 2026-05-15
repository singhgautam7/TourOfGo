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
  late final PageController _pageController;
  final Map<int, ScrollController> _scrollControllers = {};
  late int _currentIndex;
  OverlayEntry? _completionOverlay;

  String get _chapterKey => widget.position.chapterKey;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.position.lessonIndex;
    _pageController = PageController(initialPage: _currentIndex);
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _pageController.dispose();
    for (final c in _scrollControllers.values) {
      c.dispose();
    }
    _completionOverlay?.remove();
    super.dispose();
  }

  ScrollController _controllerFor(int idx) =>
      _scrollControllers.putIfAbsent(idx, () => ScrollController());

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final controller = _scrollControllers[_currentIndex];
    if (controller == null || !controller.hasClients) return false;
    final max = controller.position.maxScrollExtent;
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
      controller.animateTo(
        (controller.offset + 180).clamp(0.0, max),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
      controller.animateTo(
        (controller.offset - 180).clamp(0.0, max),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      return true;
    }
    return false;
  }

  void _onPageChanged(int idx) {
    final previous = _currentIndex;
    setState(() => _currentIndex = idx);
    ref
        .read(lessonPositionNotifierProvider.notifier)
        .goTo(_chapterKey, idx);
    if (idx > previous) {
      // Moving forward — mark the lesson we left as complete.
      ref
          .read(progressNotifierProvider.notifier)
          .markComplete(_chapterKey, previous);
    }
  }

  void _handleNext(Map<String, ChapterData> content, int totalLessons) {
    ref
        .read(progressNotifierProvider.notifier)
        .markComplete(_chapterKey, _currentIndex);
    if (_currentIndex >= totalLessons - 1) {
      _showCompletionOverlay(content, totalLessons);
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  void _handlePrev() {
    if (_currentIndex <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  void _showCompletionOverlay(
      Map<String, ChapterData> content, int totalLessons) {
    final ordered = orderedChapters(content);
    final chapterIdx = ordered.indexWhere((e) => e.key == _chapterKey);
    final hasNext = chapterIdx >= 0 && chapterIdx < ordered.length - 1;
    final chapterName =
        kChapterDisplayNames[_chapterKey] ?? content[_chapterKey]?.title ?? '';
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
        if (totalLessons == 0) {
          return const Scaffold(
              body: Center(child: Text('No lessons in chapter')));
        }
        final safeIndex = _currentIndex.clamp(0, totalLessons - 1);
        final currentLesson = chapter.pages[safeIndex];
        final chapterName =
            kChapterDisplayNames[_chapterKey] ?? chapter.title;

        return Scaffold(
          backgroundColor: cs.surface,
          body: Column(
            children: [
              _ReaderTopBar(
                chapterKey: _chapterKey,
                chapterName: chapterName,
                lessonIndex: safeIndex,
                totalLessons: totalLessons,
                lesson: currentLesson,
                onBack: () => context.pop(),
                cs: cs,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: totalLessons,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (ctx, idx) {
                    return _LessonPage(
                      lesson: chapter.pages[idx],
                      chapterKey: _chapterKey,
                      lessonIndex: idx,
                      scrollController: _controllerFor(idx),
                    );
                  },
                ),
              ),
              LessonNavBar(
                onPrev: _handlePrev,
                onNext: () => _handleNext(content, totalLessons),
                currentIndex: safeIndex,
                totalLessons: totalLessons,
              ),
            ],
          ),
        );
      },
    );
  }
}

bool _isPlayground(String chapterKey, LessonData lesson) {
  return chapterKey == 'welcome' &&
      lesson.title.toLowerCase().contains('playground');
}

class _EditInSandboxButton extends StatelessWidget {
  final String code;
  final String title;
  const _EditInSandboxButton({required this.code, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          context.push(
            '/sandbox',
            extra: <String, String?>{'code': code, 'title': title},
          );
        },
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: const Text('Edit in Sandbox'),
      ),
    );
  }
}

class _LessonPage extends ConsumerWidget {
  final LessonData lesson;
  final String chapterKey;
  final int lessonIndex;
  final ScrollController scrollController;

  const _LessonPage({
    required this.lesson,
    required this.chapterKey,
    required this.lessonIndex,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final compileState =
        ref.watch(compileNotifierProvider(chapterKey, lessonIndex));
    final parsedBlocks = GoHtmlParser.parse(
      lesson.content,
      context,
      onLinkTap: onLinkTap,
    );

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            LessonContentView(blocks: parsedBlocks),
            if (lesson.files.isNotEmpty) ...[
              const SizedBox(height: KuberSpacing.xl),
              CodeInlineCard(file: lesson.files.first),
              const SizedBox(height: KuberSpacing.md),
              if (_isPlayground(chapterKey, lesson)) ...[
                _EditInSandboxButton(
                  code: lesson.files.first.content,
                  title: lesson.title,
                ),
                const SizedBox(height: KuberSpacing.sm),
              ],
              RunButton(
                isRunning: compileState.isLoading,
                onTap: () {
                  ref
                      .read(compileNotifierProvider(
                              chapterKey, lessonIndex)
                          .notifier)
                      .runCode(lesson.files.first.content);
                },
              ),
              if (compileState.hasValue && compileState.value != null)
                OutputPanel(response: compileState.value!),
            ],
            const SizedBox(height: KuberSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ReaderTopBar extends StatelessWidget {
  final String chapterKey;
  final String chapterName;
  final int lessonIndex;
  final int totalLessons;
  final LessonData lesson;
  final VoidCallback onBack;
  final ColorScheme cs;

  const _ReaderTopBar({
    required this.chapterKey,
    required this.chapterName,
    required this.lessonIndex,
    required this.totalLessons,
    required this.lesson,
    required this.onBack,
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
                  GestureDetector(
                    onTap: () {
                      showLessonInfoSheet(
                        context,
                        lesson: lesson,
                        chapterKey: chapterKey,
                        chapterName: chapterName,
                        lessonNum: lessonIndex + 1,
                        totalLessons: totalLessons,
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
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: (lessonIndex + 1) / totalLessons,
              ),
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              builder: (_, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 2,
                backgroundColor: cs.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
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
