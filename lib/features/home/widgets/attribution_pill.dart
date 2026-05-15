import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/tour_content_provider.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/go_tour_button.dart';

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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
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
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: GestureDetector(
        onTap: _showSyncSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.full),
            border: Border.all(color: cs.outline, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _spinCtrl,
                builder: (_, child) => Transform.rotate(
                  angle: _spinCtrl.value * 2 * 3.14159,
                  child: child,
                ),
                child: Icon(
                  Icons.sync_rounded,
                  size: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _syncText,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return KuberBottomSheet(
      title: 'Content Source',
      subtitle: 'go.dev/tour',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: 'Source',
            value: 'go.dev/tour/lesson',
            cs: cs,
          ),
          const SizedBox(height: KuberSpacing.md),
          _InfoRow(
            label: 'License',
            value: 'BSD License · CC BY 3.0',
            cs: cs,
          ),
          const SizedBox(height: KuberSpacing.md),
          _InfoRow(
            label: 'Last synced',
            value: widget.lastFetchMs != null
                ? formatLastUpdated(widget.lastFetchMs!)
                : 'Never',
            cs: cs,
          ),
          const SizedBox(height: KuberSpacing.xl),
          GoTourButton(
            label: _isRefreshing ? 'Refreshing…' : 'Refresh content',
            icon: Icons.sync_rounded,
            type: GoTourButtonType.primary,
            fullWidth: true,
            isLoading: _isRefreshing,
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
