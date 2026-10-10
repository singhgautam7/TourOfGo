import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/nav_sheet.dart';
import '../models/go_example.dart';
import '../providers/go_by_example_index_provider.dart';
import '../providers/go_by_example_progress_provider.dart';
import '../providers/go_by_example_download_provider.dart';

Future<void> showExampleNavSheet(
  BuildContext context, {
  String? initialSlug,
}) {
  return showNavSheet(
    context,
    builder: (scrollController) => _ExampleNavSheetContent(
      scrollController: scrollController,
      initialSlug: initialSlug,
    ),
  );
}

class _ExampleNavSheetContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final String? initialSlug;

  const _ExampleNavSheetContent({
    required this.scrollController,
    this.initialSlug,
  });

  @override
  ConsumerState<_ExampleNavSheetContent> createState() =>
      _ExampleNavSheetContentState();
}

class _ExampleNavSheetContentState
    extends ConsumerState<_ExampleNavSheetContent> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indexState = ref.watch(goByExampleIndexNotifierProvider);
    final downloadState = ref.watch(goByExampleDownloadNotifierProvider);
    final completed = ref.watch(goByExampleProgressNotifierProvider);

    return NavSheetFrame(
      title: 'Go by Example',
      subtitle: indexState.maybeWhen(
        data: (index) => '${index.length} examples',
        orElse: () => null,
      ),
      searchHint: 'Search examples…',
      onSearch: (v) => setState(() => _search = v),
      child: indexState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => KuberEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Error',
          description: '$e',
        ),
        data: (index) {
          final filter = _search.toLowerCase();
          final filtered = index.where((e) {
            if (filter.isEmpty) return true;
            return e.title.toLowerCase().contains(filter);
          }).toList();

          if (filtered.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(KuberSpace.lg),
              child: Text(
                'No matching examples.',
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            );
          }

          // One grouped card (83 cheap rows, the same as Home builds).
          return SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin, 0, KuberSpace.screenMargin, 32),
            child: KuberGroup(
              children: [
                for (final e in filtered)
                  _GbeNavRow(
                    entry: e,
                    isComplete: completed.contains(e.slug),
                    isDownloaded:
                        downloadState.alreadyDownloadedSlugs.contains(e.slug),
                    isCurrent: widget.initialSlug == e.slug,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GbeNavRow extends StatelessWidget {
  final GoExampleIndex entry;
  final bool isComplete;
  final bool isDownloaded;
  final bool isCurrent;

  const _GbeNavRow({
    required this.entry,
    required this.isComplete,
    required this.isDownloaded,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return KuberListRow(
      dense: true,
      selected: isCurrent,
      minHeight: KuberSpace.tapTarget,
      onTap: () {
        Navigator.pop(context);
        context.pushReplacement('/example/${entry.slug}', extra: entry);
      },
      leading: SizedBox(
        width: 24,
        child: Text(
          '${entry.order + 1}',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium!.copyWith(
            color: isCurrent ? cs.onSecondaryContainer : cs.onSurfaceVariant,
          ),
        ),
      ),
      title: entry.title,
      trailing: isComplete
          ? Icon(Icons.check_circle_outline_rounded,
              size: 20, color: cs.primary)
          : !isDownloaded
              ? Icon(Icons.download_outlined,
                  size: 20, color: cs.onSurfaceVariant)
              : null,
    );
  }
}
