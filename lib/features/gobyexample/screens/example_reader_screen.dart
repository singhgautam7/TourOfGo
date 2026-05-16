import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../reader/widgets/lesson_nav_bar.dart';
import '../models/go_example.dart';
import '../providers/go_by_example_index_provider.dart';
import '../providers/go_by_example_progress_provider.dart';
import '../providers/go_example_content_provider.dart';
import '../widgets/example_content_view.dart';
import '../widgets/example_info_sheet.dart';
import '../widgets/example_top_bar.dart';

import '../widgets/example_nav_sheet.dart';

class ExampleReaderScreen extends ConsumerStatefulWidget {
  final GoExampleIndex index;

  const ExampleReaderScreen({super.key, required this.index});

  @override
  ConsumerState<ExampleReaderScreen> createState() =>
      _ExampleReaderScreenState();
}

class _ExampleReaderScreenState extends ConsumerState<ExampleReaderScreen> {
  late final PageController _pageController;
  final Map<int, ScrollController> _scrollControllers = {};
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index.order;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _scrollControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  ScrollController _controllerFor(int idx) =>
      _scrollControllers.putIfAbsent(idx, () => ScrollController());

  void _onPageChanged(int idx, List<GoExampleIndex> all) {
    final previous = _currentIndex;
    setState(() => _currentIndex = idx);
    if (idx > previous && previous >= 0 && previous < all.length) {
      ref
          .read(goByExampleProgressNotifierProvider.notifier)
          .markComplete(all[previous].slug);
    }
  }

  void _handleNext(List<GoExampleIndex> all) {
    if (_currentIndex >= all.length - 1) {
      ref
          .read(goByExampleProgressNotifierProvider.notifier)
          .markComplete(all[_currentIndex].slug);
      context.pop();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final indexState = ref.watch(goByExampleIndexNotifierProvider);
    final allExamples = indexState.valueOrNull ?? [];
    final totalExamples = allExamples.isEmpty ? 1 : allExamples.length;

    if (allExamples.isEmpty) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    final safeIndex = _currentIndex.clamp(0, totalExamples - 1);
    final currentExampleIndex = allExamples[safeIndex];

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          ExampleTopBar(
            exampleTitle: currentExampleIndex.title,
            currentIndex: safeIndex,
            totalExamples: totalExamples,
            onBack: () => context.pop(),
            onInfo: () => showExampleInfoSheet(context, currentExampleIndex),
            onTitleTap: () => showExampleNavSheet(context, initialSlug: currentExampleIndex.slug),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalExamples,
              onPageChanged: (idx) => _onPageChanged(idx, allExamples),
              itemBuilder: (ctx, idx) {
                return _ExamplePage(
                  index: allExamples[idx],
                  scrollController: _controllerFor(idx),
                );
              },
            ),
          ),
          LessonNavBar(
            onPrev: _handlePrev,
            onNext: () => _handleNext(allExamples),
            currentIndex: safeIndex,
            totalLessons: totalExamples,
          ),
        ],
      ),
    );
  }
}

class _ExamplePage extends ConsumerStatefulWidget {
  final GoExampleIndex index;
  final ScrollController scrollController;

  const _ExamplePage({required this.index, required this.scrollController});

  @override
  ConsumerState<_ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends ConsumerState<_ExamplePage> {
  bool _autoFetchTriggered = false;

  void _maybeAutoFetch() {
    if (_autoFetchTriggered) return;
    _autoFetchTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(goExampleContentNotifierProvider(widget.index.slug).notifier)
          .fetchContent(widget.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentState =
        ref.watch(goExampleContentNotifierProvider(widget.index.slug));

    return contentState.when(
      loading: () => const _LoadingView(),
      error: (e, _) => _ErrorView(
        error: e.toString(),
        onRetry: () => ref
            .read(goExampleContentNotifierProvider(widget.index.slug).notifier)
            .fetchContent(widget.index),
      ),
      data: (example) {
        if (example == null) {
          _maybeAutoFetch();
          return const _LoadingView();
        }
        return ExampleContentView(
          example: example,
          scrollController: widget.scrollController,
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: KuberSpacing.lg),
          Text(
            'Fetching example...',
            style: GoogleFonts.inter(
                fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 40, color: cs.error.withValues(alpha: 0.8)),
            const SizedBox(height: KuberSpacing.md),
            Text(
              'Could not fetch example',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: KuberSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

