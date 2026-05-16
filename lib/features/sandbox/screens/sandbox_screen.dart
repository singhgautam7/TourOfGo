import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/compile_service.dart';
import '../../../shared/widgets/tourgo_app_bar.dart';
import '../../reader/widgets/code_card_chrome.dart';
import '../../reader/widgets/go_code_controller.dart';
import '../../reader/widgets/line_numbered_code.dart';
import '../../reader/widgets/output_panel.dart';
import '../../reader/widgets/run_button.dart';

const _defaultSandboxCode = '''package main

import "fmt"

func main() {
\tfmt.Println("Hello, playground")
}
''';

class SandboxScreen extends ConsumerStatefulWidget {
  final String? initialCode;
  final String? title;

  const SandboxScreen({super.key, this.initialCode, this.title});

  @override
  ConsumerState<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends ConsumerState<SandboxScreen> {
  late GoCodeController _controller;
  final _service = CompileService();
  bool _running = false;
  CompileResponse? _response;
  bool _initialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ensureController(bool isDark) {
    if (_initialized) return;
    _controller = GoCodeController(
      text: widget.initialCode ?? _defaultSandboxCode,
      isDark: isDark,
    );
    _initialized = true;
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _response = null;
    });
    try {
      final result = await _service.compile(_controller.text);
      if (mounted) {
        setState(() {
          _response = result;
          _running = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _response = CompileResponse(
            errors: 'Network error: $e',
            events: const [],
            vetErrors: '',
          );
          _running = false;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _controller.text = widget.initialCode ?? _defaultSandboxCode;
      _response = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _ensureController(isDark);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TourGoAppBar(
                showBack: true,
                title: widget.title ?? 'Sandbox',
                actions: [
                  GestureDetector(
                    onTap: _reset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 7),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius:
                            BorderRadius.circular(KuberRadius.md),
                        border: Border.all(
                            color: cs.outline.withValues(alpha: 0.25)),
                      ),
                      child: Icon(Icons.refresh_rounded,
                          size: 18, color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.lg,
                    KuberSpacing.md,
                    KuberSpacing.lg,
                    KuberSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EditorCard(controller: _controller),
                    const SizedBox(height: KuberSpacing.md),
                    RunButton(isRunning: _running, onTap: _run),
                    if (_response != null) OutputPanel(response: _response!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorCard extends StatelessWidget {
  final GoCodeController controller;

  const _EditorCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final codeStyle = GoogleFonts.jetBrainsMono(
      fontSize: 13,
      height: 1.6,
      color: cs.onSurface,
      fontFeatures: const [
        FontFeature.disable('liga'),
        FontFeature.disable('calt'),
      ],
    );

    return CodeCardChrome(
      filename: 'main.go',
      trailing: const _EditableBadge(),
      body: Padding(
        padding: const EdgeInsets.only(bottom: KuberSpacing.md),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            return LineNumberedCode(
              text: value.text,
              codeStyle: codeStyle,
              wrap: true,
              bodyBuilder: (context, _) => TextField(
                controller: controller,
                maxLines: null,
                minLines: 12,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                autocorrect: false,
                enableSuggestions: false,
                smartDashesType: SmartDashesType.disabled,
                smartQuotesType: SmartQuotesType.disabled,
                cursorColor: cs.primary,
                style: codeStyle,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditableBadge extends StatelessWidget {
  const _EditableBadge();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      'EDITABLE',
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: cs.primary,
        letterSpacing: 1.2,
      ),
    );
  }
}
