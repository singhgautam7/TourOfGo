import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

/// Resolves a relative href to an absolute URL.
String resolveHref(String href) {
  if (href.startsWith('javascript:')) return '';
  if (href.startsWith('http')) return href;
  if (href.startsWith('/pkg/')) return 'https://pkg.go.dev/${href.substring(5)}';
  if (href.startsWith('/blog/')) return 'https://go.dev$href';
  if (href.startsWith('/doc/')) return 'https://go.dev$href';
  if (href.startsWith('/tour/')) return 'https://go.dev$href';
  return 'https://go.dev$href';
}

void onLinkTap(BuildContext context, String href) {
  final url = resolveHref(href);
  if (url.isEmpty) return;
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    builder: (_) => LinkBottomSheet(url: url),
  );
}

class LinkBottomSheet extends StatelessWidget {
  final String url;
  const LinkBottomSheet({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),
            Text(
              'External Link',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: KuberSpacing.md),
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
            const SizedBox(height: KuberSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final uri = Uri.tryParse(url);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Open in Browser'),
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
