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
import '../widgets/example_top_bar.dart';

class ExampleReaderScreen extends ConsumerStatefulWidget {
  final GoExampleIndex index;

  const ExampleReaderScreen({super.key, required this.index});

  @override
  ConsumerState<ExampleReaderScreen> createState() =>
      _ExampleReaderScreenState();
}

class _ExampleReaderScreenState extends ConsumerState<ExampleReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _autoFetchTriggered = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Kick off a download if there's no cached content yet. Idempotent across
  /// rebuilds — fires at most once per screen instance.
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

  void _navigateTo(List<GoExampleIndex> all, int targetOrder) {
    if (targetOrder < 0 || targetOrder >= all.length) return;
    final target = all[targetOrder];
    context.pushReplacement('/example/${target.slug}', extra: target);
  }

  void _handleNext(List<GoExampleIndex> all) {
    // Mark current complete on tap Next (matches lesson reader behaviour).
    ref
        .read(goByExampleProgressNotifierProvider.notifier)
        .markComplete(widget.index.slug);
    if (widget.index.order >= all.length - 1) {
      context.pop();
      return;
    }
    _navigateTo(all, widget.index.order + 1);
  }

  void _handlePrev(List<GoExampleIndex> all) {
    if (widget.index.order <= 0) return;
    _navigateTo(all, widget.index.order - 1);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final indexState = ref.watch(goByExampleIndexNotifierProvider);
    final contentState =
        ref.watch(goExampleContentNotifierProvider(widget.index.slug));

    final allExamples = indexState.valueOrNull ?? [];
    final totalExamples =
        allExamples.isEmpty ? 1 : allExamples.length;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          ExampleTopBar(
            exampleTitle: widget.index.title,
            currentIndex: widget.index.order,
            totalExamples: totalExamples,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (allExamples.isEmpty) return;
                if (v < -300) {
                  _handleNext(allExamples);
                } else if (v > 300) {
                  _handlePrev(allExamples);
                }
              },
              child: contentState.when(
                loading: () => const _LoadingView(),
                error: (e, _) => _ErrorView(
                  error: e.toString(),
                  onRetry: () => ref
                      .read(goExampleContentNotifierProvider(
                              widget.index.slug)
                          .notifier)
                      .fetchContent(widget.index),
                ),
                data: (example) {
                  if (example == null) {
                    // No cache yet — auto-fetch and show the loader.
                    _maybeAutoFetch();
                    return const _LoadingView();
                  }
                  return ExampleContentView(
                    example: example,
                    scrollController: _scrollController,
                  );
                },
              ),
            ),
          ),
          LessonNavBar(
            onPrev: () => _handlePrev(allExamples),
            onNext: () => _handleNext(allExamples),
            currentIndex: widget.index.order,
            totalLessons: totalExamples,
          ),
        ],
      ),
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

