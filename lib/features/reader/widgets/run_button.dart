import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: isRunning ? null : onTap,
        icon: isRunning
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow_rounded, size: 18),
        label: Text(
          isRunning ? 'Running…' : 'Run',
          style: GoogleFonts.inter(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
