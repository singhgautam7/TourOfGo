import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../reader/widgets/lesson_nav_bar.dart';
import '../models/go_example.dart';
import '../providers/go_by_example_index_provider.dart';
import '../providers/go_by_example_progress_provider.dart';
import '../providers/go_example_content_provider.dart';
import '../widgets/example_content_view.dart';
import '../widgets/example_info_sheet.dart';
import '../widgets/example_top_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';

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
    // order is 0 when coming from a slug-only fallback; we'll correct it
    // once the index list loads (see _resolveCurrentIndex).
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If we were given a stub (title empty = slug-only navigation), resolve
    // the correct page index by matching the slug once the list is available.
    if (widget.index.title.isEmpty) {
      final matched = allExamples
          .indexWhere((e) => e.slug == widget.index.slug);
      if (matched >= 0 && matched != _currentIndex) {
        // Schedule correction after the frame to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _currentIndex = matched);
          _pageController.jumpToPage(matched);
        });
      }
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
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: KuberSpace.lg),
          Text('Fetching example...', style: theme.textTheme.bodyMedium!
              .copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
    return KuberEmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'Could not fetch example',
      description: error,
      actionLabel: 'Retry',
      actionIcon: Icons.refresh_rounded,
      onAction: onRetry,
    );
  }
}
