import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tourgo/core/utils/locale_font.dart';
import '../../../core/theme/app_theme.dart';
import '../models/search_result.dart';
import '../providers/recent_searches_provider.dart';
import '../providers/search_provider.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../widgets/search_result_cards.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Explicit submit (Enter key or tick button). Runs search AND records it
  /// in recent searches.
  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    FocusScope.of(context).unfocus();
    ref.read(searchNotifierProvider.notifier).runSearch(trimmed);
    ref.read(recentSearchesNotifierProvider.notifier).addSearch(trimmed);
  }

  /// Called on every keystroke. Runs an ephemeral search once the user has
  /// typed at least 3 characters, but does NOT save the query to recents.
  void _onQueryChanged() {
    setState(() {});
    final trimmed = _controller.text.trim();
    if (trimmed.length >= 3) {
      ref.read(searchNotifierProvider.notifier).runSearch(trimmed);
    } else {
      ref.read(searchNotifierProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _SearchTopBar(
            controller: _controller,
            focusNode: _focusNode,
            onSubmit: _submitSearch,
            onClear: () {
              _controller.clear();
              ref.read(searchNotifierProvider.notifier).clear();
              setState(() {});
            },
            onTextChanged: _onQueryChanged,
          ),
          Expanded(
            child: searchState.hasSearched
                ? _SearchResultsList(state: searchState)
                : _RecentSearchesList(
                    onPickRecent: (term) {
                      _controller.text = term;
                      _submitSearch(term);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Kuber's header geometry (L16 T14 R16 B12) with the search pill as the
/// title: surfaceContainer stadium, 2dp primary edge, clear inside, and the
/// submit as a filled icon button.
class _SearchTopBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onSubmit;
  final VoidCallback onClear;
  final VoidCallback onTextChanged;

  const _SearchTopBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onClear,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasText = controller.text.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpace.lg,
          14,
          KuberSpace.lg,
          KuberSpace.md,
        ),
        child: Row(
          children: [
            AppIconButton(
              icon: Icons.arrow_back_rounded,
              semanticLabel: 'Back',
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: KuberShape.fullR,
                  border: Border.all(color: cs.primary, width: 2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: KuberSpace.md),
                    Icon(
                      Icons.search_rounded,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: KuberSpace.sm),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: true,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.search,
                        style: theme.textTheme.bodyLarge,
                        onChanged: (_) => onTextChanged(),
                        onSubmitted: onSubmit,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          // The theme's 16dp contentPadding still applies to a
                          // collapsed field; zero it so the text centres.
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Search chapters, lessons...',
                          hintStyle: theme.textTheme.bodyLarge!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (c, a) =>
                          ScaleTransition(scale: a, child: c),
                      child: hasText
                          ? AppIconButton(
                              key: const ValueKey('clear'),
                              icon: Icons.close_rounded,
                              kind: AppIconButtonKind.plain,
                              semanticLabel: 'Clear',
                              onPressed: onClear,
                            )
                          : const SizedBox(
                              width: KuberSpace.sm,
                              key: ValueKey('none'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: KuberSpace.sm),
            AppIconButton(
              icon: Icons.check_rounded,
              kind: AppIconButtonKind.filled,
              semanticLabel: 'Search',
              onPressed: hasText ? () => onSubmit(controller.text) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearchesList extends ConsumerWidget {
  final void Function(String) onPickRecent;

  const _RecentSearchesList({required this.onPickRecent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentSearchesNotifierProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      child: recent.isEmpty
          ? const KuberEmptyState(
              key: ValueKey('empty'),
              icon: Icons.search_rounded,
              title: 'Search anything Go',
              description: '',
            )
          : ListView(
              key: const ValueKey('list'),
              padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin,
                KuberSpace.sm,
                KuberSpace.screenMargin,
                KuberSpace.xl,
              ),
              children: [
                KuberSectionHeader(
                  title: 'Recent searches',
                  trailing: KuberSectionAction(
                    label: 'Clear all',
                    onTap: () => ref
                        .read(recentSearchesNotifierProvider.notifier)
                        .clearAll(),
                  ),
                ),
                KuberGroup(
                  children: [
                    for (final term in recent)
                      KuberListRow(
                        leading: const Icon(Icons.history_rounded),
                        title: term,
                        minHeight: KuberSpace.listItem1,
                        onTap: () => onPickRecent(term),
                        trailing: AppIconButton(
                          icon: Icons.close_rounded,
                          kind: AppIconButtonKind.plain,
                          semanticLabel: 'Remove',
                          onPressed: () => ref
                              .read(recentSearchesNotifierProvider.notifier)
                              .removeSearch(term),
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final SearchState state;

  const _SearchResultsList({required this.state});

  @override
  Widget build(BuildContext context) {
    final results = state.results;
    final headerText = results.isEmpty
        ? 'No results for "${state.query}"'
        : '${results.length} result${results.length == 1 ? '' : 's'} for "${state.query}"';

    return NotificationListener<ScrollStartNotification>(
      onNotification: (_) {
        FocusScope.of(context).unfocus();
        return false;
      },
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: results.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin,
                KuberSpace.sm,
                KuberSpace.screenMargin,
                KuberSpace.md,
              ),
              child: Text(
                headerText.toUpperCase(),
                style: sectionHeaderStyle(context),
              ),
            );
          }
          final result = results[i - 1];
          return switch (result) {
            ChapterSearchResult r => ChapterResultCard(
              result: r,
              query: state.query,
            ),
            LessonSearchResult r => LessonResultCard(
              result: r,
              query: state.query,
            ),
            ExampleSearchResult r => ExampleResultCard(
              result: r,
              query: state.query,
            ),
          };
        },
      ),
    );
  }
}
