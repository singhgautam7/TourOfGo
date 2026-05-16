import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/tour_url.dart';
import '../../../shared/widgets/tourgo_bottom_sheet.dart';

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
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => LinkBottomSheet(url: url),
  );
}

class LinkBottomSheet extends StatelessWidget {
  final String url;
  const LinkBottomSheet({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inAppPos = tourUrlToPosition(url);

    return TourGoBottomSheet(
      title: 'External Link',
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (inAppPos != null) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  context.push('/reader', extra: inAppPos);
                },
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: const Text('Open in app'),
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.tryParse(url);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open in browser'),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final uri = Uri.tryParse(url);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open in browser'),
              ),
            ),
        ],
      ),
      child: Container(
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
    );
  }
}
