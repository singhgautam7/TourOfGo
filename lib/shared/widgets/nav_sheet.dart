import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_icon_button.dart';

/// Opens a long, draggable navigation sheet (chapters, examples).
Future<void> showNavSheet(
  BuildContext context, {
  required Widget Function(ScrollController) builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.15,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.15, 0.55, 0.95],
      builder: (ctx, scrollController) => builder(scrollController),
    ),
  );
}

/// [KuberBottomSheet]'s chrome for a draggable list sheet: surfaceContainerLow,
/// top radius 28, a 32x4 handle in a 24 band, titleLarge [title] with a
/// bodyMedium [subtitle] and a close button, then a stadium search field and
/// the [child] filling the rest.
class NavSheetFrame extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// The search field shows only when both are set.
  final String? searchHint;
  final ValueChanged<String>? onSearch;

  /// Optional 40 tile before the title.
  final Widget? leading;
  final Widget child;

  const NavSheetFrame({
    super.key,
    required this.title,
    this.subtitle,
    this.searchHint,
    this.onSearch,
    this.leading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const stadium = OutlineInputBorder(
      borderRadius: KuberShape.fullR,
      borderSide: BorderSide.none,
    );
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: KuberShape.sheetR,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 24,
            child: Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: KuberShape.fullR,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: KuberSpace.lg),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleLarge),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: Icons.close_rounded,
                  semanticLabel: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          if (searchHint != null && onSearch != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                onChanged: onSearch,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  isDense: true,
                  border: stadium,
                  enabledBorder: stadium,
                  focusedBorder: stadium.copyWith(
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
