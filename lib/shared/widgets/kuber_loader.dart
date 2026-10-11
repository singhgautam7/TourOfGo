import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class KuberLoader extends StatelessWidget {
  final String label;

  const KuberLoader({super.key, this.label = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(KuberSpace.xl),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: cs.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: KuberSpace.lg),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the loader over the route until [future] completes, then closes it
  /// and returns (or rethrows) its result.
  static Future<T?> show<T>(
    BuildContext context, {
    String label = 'Loading...',
    required Future<T> future,
  }) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KuberLoader(label: label),
    );
    try {
      final result = await future;
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      return result;
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      rethrow;
    }
  }
}
