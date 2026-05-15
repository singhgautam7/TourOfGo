import 'package:flutter/material.dart';
import '../../../core/utils/go_syntax_highlighter.dart';

/// A `TextEditingController` whose `buildTextSpan` runs the Go syntax
/// highlighter so editable code views look the same as read-only ones.
class GoCodeController extends TextEditingController {
  final bool isDark;

  GoCodeController({super.text, required this.isDark});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans =
        GoSyntaxHighlighter.highlight(text, isDark: isDark);
    return TextSpan(style: style, children: spans);
  }
}
