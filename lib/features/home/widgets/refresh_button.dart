import 'package:flutter/material.dart';

/// Animated circular refresh button — adapted from Kuber's KuberPageHeader.
class RefreshButton extends StatefulWidget {
  final bool isRefreshing;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const RefreshButton({
    super.key,
    required this.isRefreshing,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isRefreshing) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(RefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.isRefreshing) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.isRefreshing ? null : widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: widget.isRefreshing
              ? cs.onSurface.withValues(alpha: 0.2)
              : cs.primary,
          shape: BoxShape.circle,
          boxShadow: widget.isRefreshing
              ? null
              : [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform.rotate(
            angle: _ctrl.value * 2 * 3.14159,
            child: child,
          ),
          child: Icon(
            Icons.sync_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
