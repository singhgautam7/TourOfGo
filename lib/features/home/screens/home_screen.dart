import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/content_service.dart';
import '../../../providers/tour_content_provider.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../providers/progress_provider.dart';
import '../widgets/continue_card.dart';
import '../widgets/chapter_progress_row.dart';
import '../widgets/refresh_button.dart';
import '../../navigation/widgets/chapter_nav_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _service = ContentService();
  int? _lastFetchMs;

  @override
  void initState() {
    super.initState();
    _loadLastFetch();
  }

  Future<void> _loadLastFetch() async {
    final ms = await _service.getLastFetchTime();
    if (mounted) setState(() => _lastFetchMs = ms);
  }

  void _openChapterNav() {
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
        builder: (ctx, scrollController) =>
            ChapterNavSheetContent(scrollController: scrollController),
      ),
    );
  }

  void _showApiInfoSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (_) => _ApiInfoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final contentState = ref.watch(tourContentNotifierProvider);
    final position = ref.watch(lessonPositionNotifierProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.lg, KuberSpacing.md, KuberSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App bar row
                    Row(
                      children: [
                        _GoMarkWidget(cs: cs),
                        const SizedBox(width: 10),
                        Text(
                          'Tour of Go',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.push('/more'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainer,
                              borderRadius:
                                  BorderRadius.circular(KuberRadius.md),
                              border: Border.all(color: cs.outline),
                            ),
                            child: Icon(Icons.more_vert_rounded,
                                size: 18, color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.lg),

                    // Page header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greetingText(),
                                style: GoogleFonts.inter(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                  letterSpacing: -0.6,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pick up where you left off.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RefreshButton(
                          isRefreshing: contentState.isLoading,
                          onTap: () async {
                            await ref
                                .read(tourContentNotifierProvider.notifier)
                                .fetchFromApi();
                            _loadLastFetch();
                          },
                          onLongPress: _showApiInfoSheet,
                        ),
                      ],
                    ),

                    // Last updated row
                    if (_lastFetchMs != null) ...[
                      const SizedBox(height: KuberSpacing.sm),
                      Row(
                        children: [
                          Text(
                            'LAST UPDATED: ',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            formatLastUpdated(_lastFetchMs!),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: KuberSpacing.lg),

                    // Continue card
                    contentState.when(
                      loading: () =>
                          const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => _ErrorCard(error: e.toString(), cs: cs),
                      data: (content) => ContinueCard(
                        content: content,
                        position: position,
                        onContinue: () {
                          context.push('/reader', extra: position);
                        },
                      ),
                    ),

                    const SizedBox(height: KuberSpacing.md),

                    // Browse chapters button
                    GestureDetector(
                      onTap: _openChapterNav,
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                          border: Border.all(color: cs.outline),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_rounded,
                                size: 16, color: cs.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              'Browse chapters',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: KuberSpacing.lg),

                    // Your progress section
                    contentState.maybeWhen(
                      data: (content) => _ProgressSection(content: content),
                      orElse: () => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: KuberSpacing.xl),

                    // Attribution
                    Center(
                      child: Text(
                        'Content from go.dev · BSD License',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openChapterNav,
        icon: const Icon(Icons.menu_book_rounded),
        label: const Text('Browse'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _ProgressSection extends ConsumerWidget {
  final Map<String, ChapterData> content;
  const _ProgressSection({required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    ref.watch(progressNotifierProvider);
    final overall = ref.read(progressNotifierProvider.notifier)
        .overallProgress(content);
    final ordered = orderedChapters(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'YOUR PROGRESS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.3,
              ),
            ),
            Text(
              '${(overall * 100).round()}% complete',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Column(
            children: ordered.asMap().entries.map((e) {
              final idx = e.key;
              final entry = e.value;
              return ChapterProgressRow(
                chapterNum: idx + 1,
                chapterKey: entry.key,
                chapter: entry.value,
                showDivider: idx < ordered.length - 1,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  final ColorScheme cs;
  const _ErrorCard({required this.error, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: cs.error),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Text(
              'Could not load content. Check your connection.',
              style: TextStyle(color: cs.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoMarkWidget extends StatelessWidget {
  final ColorScheme cs;
  const _GoMarkWidget({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Icon(Icons.circle_outlined, color: cs.primary, size: 18),
      ),
    );
  }
}

class _ApiInfoSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KuberSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.xl),
              Text(
                'Content Source',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              Text(
                'All lesson content is fetched from the official Go website.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: KuberSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(KuberSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                child: Text(
                  'https://go.dev/tour/lesson/',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
