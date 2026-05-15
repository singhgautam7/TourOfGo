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
import '../widgets/attribution_pill.dart';
import '../../navigation/widgets/chapter_browser_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _service = ContentService();
  int? _lastFetchMs;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadLastFetch();
  }

  Future<void> _loadLastFetch() async {
    final ms = await _service.getLastFetchTime();
    if (mounted) setState(() => _lastFetchMs = ms);
  }

  Future<void> _handleRefresh() async {
    setState(() => _isSyncing = true);
    try {
      await ref
          .read(tourContentNotifierProvider.notifier)
          .fetchFromApi();
      await _loadLastFetch();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final contentState = ref.watch(tourContentNotifierProvider);
    final position = ref.watch(lessonPositionNotifierProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: cs.primary,
          backgroundColor: cs.surfaceContainer,
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
                              child: Icon(Icons.tune_rounded,
                                  size: 18, color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: KuberSpacing.lg),

                      // Page header — clean greeting, no refresh button
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

                      const SizedBox(height: KuberSpacing.lg),

                      // Your progress section
                      contentState.maybeWhen(
                        data: (content) => _ProgressSection(content: content),
                        orElse: () => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: KuberSpacing.xl),

                      // Attribution pill
                      AttributionPill(
                        lastFetchMs: _lastFetchMs,
                        isSyncing: _isSyncing || contentState.isLoading,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sandbox'),
        icon: const Icon(Icons.code_rounded),
        label: const Text('Sandbox'),
        backgroundColor: cs.primary,
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
              overall == 0
                  ? 'No progress yet'
                  : '${(overall * 100).round()}% complete',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: overall == 0 ? cs.onSurfaceVariant : cs.primary,
              ),
            ),
          ],
        ),
        // if (overall == 0) ...[
        //   const SizedBox(height: 4),
        //   Text(
        //     'Start learning to track your progress.',
        //     style: GoogleFonts.inter(
        //       fontSize: 12.5,
        //       color: cs.onSurfaceVariant,
        //     ),
        //   ),
        // ],
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChapterBrowserList(
            content: content,
            useListView: false,
            autoExpandCurrent: false,
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
