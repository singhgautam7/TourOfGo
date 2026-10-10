import 'package:flutter/material.dart';

import '../../../shared/widgets/app_button.dart';

class RunButton extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const RunButton({
    super.key,
    required this.isRunning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: isRunning ? 'Running…' : 'Run',
      icon: Icons.play_arrow_rounded,
      type: AppButtonType.primary,
      fullWidth: true,
      isLoading: isRunning,
      onPressed: isRunning ? null : onTap,
    );
  }
}
