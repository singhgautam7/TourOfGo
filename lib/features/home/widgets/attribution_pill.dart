import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/tour_content_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';

/// A small pill at the bottom of the home screen showing sync status
/// and go.dev attribution. Tapping opens a detail bottom sheet.
class AttributionPill extends ConsumerStatefulWidget {
  final int? lastFetchMs;
  final bool isSyncing;

  const AttributionPill({
    super.key,
    this.lastFetchMs,
    this.isSyncing = false,
  });

  @override
  ConsumerState<AttributionPill> createState() => _AttributionPillState();
}

class _AttributionPillState extends ConsumerState<AttributionPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isSyncing) _spinCtrl.repeat();
  }

  @override
  void didUpdateWidget(AttributionPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing && !_spinCtrl.isAnimating) {
      _spinCtrl.repeat();
    } else if (!widget.isSyncing && _spinCtrl.isAnimating) {
      _spinCtrl.stop();
      _spinCtrl.reset();
    }
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  String get _syncText {
    if (widget.isSyncing) return 'go.dev/tour · syncing…';
    if (widget.lastFetchMs != null) {
      return 'go.dev/tour · synced ${relativeTime(widget.lastFetchMs!)}';
    }
    return 'go.dev/tour';
  }

  void _showSyncSheet() {
    showKuberBottomSheet<void>(
      context,
      builder: (_) => _SyncInfoSheet(
        lastFetchMs: widget.lastFetchMs,
        onRefresh: () async {
          await ref
              .read(tourContentNotifierProvider.notifier)
              .fetchFromApi();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // A tonal stadium chip: surfaceContainerHigh, bodySmall, 48 tap height.
    return Center(
      child: Material(
        color: cs.surfaceContainerHigh,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _showSyncSheet,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: KuberSpace.md, vertical: KuberSpace.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _spinCtrl,
                  builder: (_, child) => Transform.rotate(
                    angle: _spinCtrl.value * 2 * 3.14159,
                    child: child,
                  ),
                  child: Icon(Icons.sync_rounded,
                      size: 16, color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: KuberSpace.sm),
                Text(_syncText, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet showing sync details and manual refresh action.
class _SyncInfoSheet extends StatefulWidget {
  final int? lastFetchMs;
  final Future<void> Function() onRefresh;

  const _SyncInfoSheet({
    required this.lastFetchMs,
    required this.onRefresh,
  });

  @override
  State<_SyncInfoSheet> createState() => _SyncInfoSheetState();
}

class _SyncInfoSheetState extends State<_SyncInfoSheet> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _openSourceUrl() async {
    final uri = Uri.parse('https://go.dev/tour/lesson/');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final value =
        theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant);

    return KuberBottomSheet(
      title: 'Content source',
      subtitle: 'go.dev/tour',
      actions: AppButton(
        label: _isRefreshing ? 'Refreshing…' : 'Refresh content',
        icon: Icons.sync_rounded,
        type: AppButtonType.primary,
        fullWidth: true,
        isLoading: _isRefreshing,
        onPressed: _isRefreshing ? null : _handleRefresh,
      ),
      child: KuberGroup(
        children: [
          KuberListRow(
            title: 'Source',
            onTap: _openSourceUrl,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('go.dev/tour/lesson',
                    style: value.copyWith(color: cs.primary)),
                const SizedBox(width: KuberSpace.xs),
                Icon(Icons.arrow_outward_rounded,
                    size: 16, color: cs.primary),
              ],
            ),
          ),
          KuberListRow(
            title: 'License',
            trailing: Text('BSD License · CC BY 3.0', style: value),
          ),
          KuberListRow(
            title: 'Last synced',
            trailing: Text(
              widget.lastFetchMs != null
                  ? formatLastUpdated(widget.lastFetchMs!)
                  : 'Never',
              style: value,
            ),
          ),
        ],
      ),
    );
  }
}
