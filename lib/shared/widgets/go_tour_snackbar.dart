import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Adapted from Kuber's showKuberSnackBar — OverlayEntry-based snackbar.

const Duration _kSnackDuration = Duration(seconds: 5);
const Duration _kAnimDuration = Duration(milliseconds: 220);

OverlayEntry? _currentEntry;
_Controller? _currentController;
Timer? _currentTimer;

void _dismiss() {
  _currentTimer?.cancel();
  _currentTimer = null;
  final ctrl = _currentController;
  final entry = _currentEntry;
  _currentController = null;
  _currentEntry = null;
  ctrl?.animateOut().then((_) {
    if (entry?.mounted ?? false) entry!.remove();
  });
}

void showGoTourSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  _dismiss();
  final overlay = Overlay.of(context, rootOverlay: true);
  final ctrl = _Controller();
  final entry = OverlayEntry(
    builder: (_) => _SnackWidget(
      controller: ctrl,
      message: message,
      isError: isError,
      onClose: _dismiss,
    ),
  );
  _currentController = ctrl;
  _currentEntry = entry;
  overlay.insert(entry);
  _currentTimer = Timer(_kSnackDuration, _dismiss);
}

class _Controller {
  _SnackWidgetState? _state;
  void _attach(_SnackWidgetState s) => _state = s;
  Future<void> animateOut() async => await _state?._animateOut();
}

class _SnackWidget extends StatefulWidget {
  final _Controller controller;
  final String message;
  final bool isError;
  final VoidCallback onClose;
  const _SnackWidget({
    required this.controller,
    required this.message,
    required this.isError,
    required this.onClose,
  });
  @override
  State<_SnackWidget> createState() => _SnackWidgetState();
}

class _SnackWidgetState extends State<_SnackWidget>
    with TickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl =
        AnimationController(vsync: this, duration: _kAnimDuration);
    _slideAnim =
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic);
    widget.controller._attach(this);
    _slideCtrl.forward();
  }

  Future<void> _animateOut() async {
    if (!mounted) return;
    await _slideCtrl.reverse();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;
    final barColor = widget.isError ? cs.error : cs.primary;

    return Positioned(
      top: top + 8,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _slideAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, (1 - _slideAnim.value) * -80),
          child: Opacity(opacity: _slideAnim.value, child: child),
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(
                  color: widget.isError ? cs.error : cs.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  widget.isError
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: barColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      widget.message,
                      style: TextStyle(color: cs.onSurface, fontSize: 14),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: cs.onSurfaceVariant,
                  onPressed: widget.onClose,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
