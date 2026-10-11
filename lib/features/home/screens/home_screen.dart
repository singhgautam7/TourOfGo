import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/content_service.dart';
import '../../../providers/tour_content_provider.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_skeleton.dart';
import '../widgets/continue_card.dart';
import '../widgets/attribution_pill.dart';
import '../../navigation/widgets/chapter_browser_list.dart';
import '../../gobyexample/models/go_example.dart';
import '../../gobyexample/providers/go_by_example_index_provider.dart';
import '../../gobyexample/providers/go_by_example_progress_provider.dart';
import '../../gobyexample/providers/go_by_example_download_provider.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final contentState = ref.watch(tourContentNotifierProvider);
    final position = ref.watch(lessonPositionNotifierProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: cs.primary,
        backgroundColor: cs.surfaceContainerHigh,
        child: CustomScrollView(
          slivers: [
            // The header is item 0 and scrolls away (Kuber: no sticky
            // headers on content pages).
            SliverToBoxAdapter(
              child: KuberAppBar(
                actions: [
                  AppIconButton(
                    icon: Icons.tune_rounded,
                    semanticLabel: 'More',
                    onPressed: () => context.push('/more'),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin,
                KuberSpace.sm,
                KuberSpace.screenMargin,
                KuberExtendedFab.clearance,
              ),
              sliver: SliverList.list(
                children: [
                  Text(greetingText(), style: theme.textTheme.headlineMedium),
                  const SizedBox(height: KuberSpace.xl),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    child: contentState.when(
                      loading: () => const KuberSkeleton(
                        key: ValueKey('loading'),
                        height: 160,
                        borderRadius: KuberShape.largeIncreased,
                      ),
                      error: (e, _) => const _ErrorCard(key: ValueKey('error')),
                      data: (content) => ContinueCard(
                        key: const ValueKey('data'),
                        content: content,
                        position: position,
                        onContinue: () {
                          context.push('/reader', extra: position);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpace.lg),
                  const _SearchEntry(),
                  const SizedBox(height: KuberSpace.sectionGap),
                  contentState.maybeWhen(
                    data: (content) => _TourProgressSection(content: content),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: KuberSpace.sectionGap),
                  const _GbeProgressSection(),
                  const SizedBox(height: KuberSpace.sectionGap),
                  AttributionPill(
                    lastFetchMs: _lastFetchMs,
                    isSyncing: _isSyncing || contentState.isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: KuberExtendedFab(
        icon: Icons.code_rounded,
        label: 'Sandbox',
        onPressed: () => context.push('/sandbox'),
      ),
      floatingActionButtonLocation: kuberFabLocation,
    );
  }
}

/// The way into search: a stadium pill, 56 high, like Kuber's header search.
class _SearchEntry extends StatelessWidget {
  const _SearchEntry();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/search'),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: KuberSpace.lg),
              Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 24),
              const SizedBox(width: KuberSpace.md),
              Expanded(
                child: Text(
                  'Search chapters and lessons...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge!
                      .copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourProgressSection extends ConsumerWidget {
  final Map<String, ChapterData> content;
  const _TourProgressSection({required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    ref.watch(progressNotifierProvider);
    final overall = ref.read(progressNotifierProvider.notifier)
        .overallProgress(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberSectionHeader(
          title: 'A tour of Go',
          trailing: Text(
            overall == 0
                ? 'No progress yet'
                : '${(overall * 100).round()}% complete',
            style: theme.textTheme.labelLarge!.copyWith(
              color: overall == 0 ? cs.onSurfaceVariant : cs.primary,
            ),
          ),
        ),
        KuberGroup(
          children: [
            ChapterBrowserList(
              content: content,
              useListView: false,
              autoExpandCurrent: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _GbeProgressSection extends ConsumerWidget {
  const _GbeProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final indexState = ref.watch(goByExampleIndexNotifierProvider);
    final completed = ref.watch(goByExampleProgressNotifierProvider);
    final downloadState = ref.watch(goByExampleDownloadNotifierProvider);
    final label = theme.textTheme.labelLarge!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberSectionHeader(
          title: 'Go by Example',
          trailing: indexState.when(
            loading: () => Text('Loading…',
                style: label.copyWith(color: cs.onSurfaceVariant)),
            error: (_, _) =>
                Text('Offline', style: label.copyWith(color: cs.error)),
            data: (index) => Text(
              '${completed.length} / ${index.length}',
              style: label.copyWith(
                color: completed.isEmpty ? cs.onSurfaceVariant : cs.primary,
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          child: indexState.when(
            loading: () => const _GbeLoadingCard(key: ValueKey('loading')),
            error: (e, _) => const _GbeErrorCard(key: ValueKey('error')),
            data: (index) => KuberGroup(
              key: const ValueKey('data'),
              children: [
                for (final entry in index)
                  _GbeExampleRow(
                    entry: entry,
                    isComplete: completed.contains(entry.slug),
                    isDownloaded: downloadState.alreadyDownloadedSlugs
                        .contains(entry.slug),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Skeleton rows while the index loads (Kuber: skeleton over spinner for
/// lists).
class _GbeLoadingCard extends StatelessWidget {
  const _GbeLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return KuberGroup(
      children: [
        for (var i = 0; i < 3; i++)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: KuberSpace.listRowPadH,
              vertical: KuberSpace.md,
            ),
            child: Row(
              children: [
                KuberSkeleton(width: 40, height: 40),
                SizedBox(width: KuberSpace.lg),
                Expanded(child: KuberSkeleton(height: 16)),
              ],
            ),
          ),
      ],
    );
  }
}

class _GbeErrorCard extends StatelessWidget {
  const _GbeErrorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const KuberGroup(
      children: [
        KuberListRow(
          leading: KuberIconTile(
              icon: Icons.wifi_off_rounded, tone: KuberTone.neutral),
          title: 'Could not load examples. Pull to refresh.',
        ),
      ],
    );
  }
}

class _GbeExampleRow extends StatelessWidget {
  final GoExampleIndex entry;
  final bool isComplete;
  final bool isDownloaded;

  const _GbeExampleRow({
    required this.entry,
    required this.isComplete,
    required this.isDownloaded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return KuberListRow(
      onTap: () => context.push('/example/${entry.slug}', extra: entry),
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isComplete ? cs.primary : cs.secondaryContainer,
          borderRadius: KuberShape.mediumR,
        ),
        child: isComplete
            ? Icon(Icons.check_rounded, size: 20, color: cs.onPrimary)
            : Text(
                '${entry.order + 1}',
                style: theme.textTheme.labelLarge!
                    .copyWith(color: cs.onSecondaryContainer),
              ),
      ),
      title: entry.title,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDownloaded && !isComplete)
            Padding(
              padding: const EdgeInsets.only(right: KuberSpace.xs),
              child: Icon(Icons.download_outlined,
                  size: 20, color: cs.onSurfaceVariant),
            ),
          const KuberChevron(),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return KuberCard(
      color: cs.errorContainer,
      borderColor: cs.errorContainer,
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: cs.onErrorContainer),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: Text(
              'Could not load content. Check your connection.',
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: cs.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
