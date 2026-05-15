import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/search_result.dart';
import '../providers/recent_searches_provider.dart';
import '../providers/search_provider.dart';
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
            cs: cs,
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

class _SearchTopBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ColorScheme cs;
  final void Function(String) onSubmit;
  final VoidCallback onClear;
  final VoidCallback onTextChanged;

  const _SearchTopBar({
    required this.controller,
    required this.focusNode,
    required this.cs,
    required this.onSubmit,
    required this.onClear,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            KuberSpacing.sm, KuberSpacing.md, KuberSpacing.sm, KuberSpacing.md),
        child: Row(
          children: [
            _CircularIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => context.pop(),
              cs: cs,
            ),
            const SizedBox(width: KuberSpacing.sm),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: GoogleFonts.inter(fontSize: 15, color: cs.onSurface),
                onChanged: (_) => onTextChanged(),
                onSubmitted: onSubmit,
                decoration: InputDecoration(
                  hintText: 'Search chapters, lessons...',
                  hintStyle:
                      GoogleFonts.inter(color: cs.onSurfaceVariant, fontSize: 15),
                  filled: true,
                  fillColor: cs.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    borderSide: BorderSide(color: cs.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: KuberSpacing.lg, vertical: KuberSpacing.md),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: cs.onSurfaceVariant, size: 18),
                  suffixIcon: hasText
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: cs.onSurfaceVariant, size: 18),
                          onPressed: onClear,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            _SquircleAccentButton(
              icon: Icons.check_rounded,
              enabled: hasText,
              onTap: () => onSubmit(controller.text),
              cs: cs,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _CircularIconButton({
    required this.icon,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: cs.onSurfaceVariant, size: 18),
      ),
    );
  }
}

class _SquircleAccentButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _SquircleAccentButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.38,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
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
    final cs = Theme.of(context).colorScheme;
    final recent = ref.watch(recentSearchesNotifierProvider);

    if (recent.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded,
                size: 48,
                color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: KuberSpacing.md),
            Text(
              'Search anything Go',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              KuberSpacing.lg, KuberSpacing.sm, KuberSpacing.xs, 0),
          child: Row(
            children: [
              Text(
                'RECENT SEARCHES',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.3,
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: KuberSpacing.sm, vertical: 0),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => ref
                    .read(recentSearchesNotifierProvider.notifier)
                    .clearAll(),
                child: Text(
                  'Clear all',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding:
                const EdgeInsets.fromLTRB(0, 4, 0, KuberSpacing.md),
            itemCount: recent.length,
            separatorBuilder: (_, _) => const SizedBox.shrink(),
            itemBuilder: (_, i) {
              final term = recent[i];
              return _RecentSearchRow(
                term: term,
                onTap: () => onPickRecent(term),
                onRemove: () => ref
                    .read(recentSearchesNotifierProvider.notifier)
                    .removeSearch(term),
                cs: cs,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentSearchRow extends StatelessWidget {
  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final ColorScheme cs;

  const _RecentSearchRow({
    required this.term,
    required this.onTap,
    required this.onRemove,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.history_rounded,
                color: cs.onSurfaceVariant, size: 18),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Text(
                term,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: cs.onSurface,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded,
                  color: cs.onSurfaceVariant, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                  width: 32, height: 32),
              onPressed: onRemove,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final SearchState state;

  const _SearchResultsList({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: results.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                  KuberSpacing.lg,
                  KuberSpacing.md,
                  KuberSpacing.lg,
                  KuberSpacing.sm),
              child: Text(
                headerText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
            );
          }
          final result = results[i - 1];
          return switch (result) {
            ChapterSearchResult r =>
              ChapterResultCard(result: r, query: state.query),
            LessonSearchResult r =>
              LessonResultCard(result: r, query: state.query),
          };
        },
      ),
    );
  }
}
