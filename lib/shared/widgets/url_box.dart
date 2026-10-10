import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/locale_font.dart';

/// A URL shown in a sheet: tonal surfaceContainerHigh box, radius 12, mono in
/// the primary colour, selectable.
class UrlBox extends StatelessWidget {
  final String url;
  const UrlBox(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.mediumR,
      ),
      child: SelectableText(url,
          style: monoFont(fontSize: 12, color: cs.primary)),
    );
  }
}
