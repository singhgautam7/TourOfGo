import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/tourgo_bottom_sheet.dart';
import '../models/go_example.dart';

class ExampleInfoSheet extends StatelessWidget {
  final GoExampleIndex example;

  const ExampleInfoSheet({super.key, required this.example});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = 'https://gobyexample.com/${example.slug}';

    return TourGoBottomSheet(
      title: example.title,
      subtitle: 'Go by Example',
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final uri = Uri.parse(url);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {
                  await launchUrl(uri);
                }
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open in Browser'),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOURCE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KuberSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Text(
              url,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showExampleInfoSheet(BuildContext context, GoExampleIndex example) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => ExampleInfoSheet(example: example),
  );
}
