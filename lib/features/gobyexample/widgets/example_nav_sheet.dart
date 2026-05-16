import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/go_example.dart';
import '../providers/go_by_example_index_provider.dart';
import '../providers/go_by_example_progress_provider.dart';
import '../providers/go_by_example_download_provider.dart';

Future<void> showExampleNavSheet(
  BuildContext context, {
  String? initialSlug,
}) {
  return showModalBottomSheet(
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
      builder: (ctx, scrollController) => _ExampleNavSheetContent(
        scrollController: scrollController,
        initialSlug: initialSlug,
      ),
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
    final cs = Theme.of(context).colorScheme;
    final indexState = ref.watch(goByExampleIndexNotifierProvider);
    final downloadState = ref.watch(goByExampleDownloadNotifierProvider);
    final completed = ref.watch(goByExampleProgressNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KuberRadius.lg),
        ),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 14),
            child: Row(
              children: [
                Text(
                  'Go by Example',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                indexState.maybeWhen(
                  data: (index) {
                    return Text(
                      '${index.length} examples',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 16, color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Search examples…',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: cs.onSurfaceVariant),
                prefixIcon: Icon(Icons.search_rounded,
                    color: cs.onSurfaceVariant, size: 18),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: indexState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (index) {
                final filter = _search.toLowerCase();
                final filtered = index.where((e) {
                  if (filter.isEmpty) return true;
                  return e.title.toLowerCase().contains(filter);
                }).toList();

                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(KuberSpacing.lg),
                    child: Text(
                      'No matching examples.',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final e = filtered[i];
                    return _GbeNavRow(
                      entry: e,
                      isComplete: completed.contains(e.slug),
                      isDownloaded: downloadState.alreadyDownloadedSlugs
                          .contains(e.slug),
                      isCurrent: widget.initialSlug == e.slug,
                    );
                  },
                );
              },
            ),
          ),
        ],
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
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
        context.pushReplacement('/example/${entry.slug}', extra: entry);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCurrent
              ? cs.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        padding: const EdgeInsets.fromLTRB(
            12, KuberSpacing.md, 12, KuberSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${entry.order + 1}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: isCurrent ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Text(
                entry.title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isCurrent ? cs.primary : cs.onSurface,
                ),
              ),
            ),
            if (isComplete)
              Icon(Icons.check_circle_rounded,
                  size: 14, color: cs.primary)
            else if (!isDownloaded)
              Icon(
                Icons.download_outlined,
                size: 14,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
