import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/tour_url.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/url_box.dart';

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
  showKuberBottomSheet<void>(
    context,
    builder: (_) => LinkBottomSheet(url: url),
  );
}

class LinkBottomSheet extends StatelessWidget {
  final String url;
  const LinkBottomSheet({super.key, required this.url});

  Future<void> _openInBrowser(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final inAppPos = tourUrlToPosition(url);

    // Kuber sheet actions: 56 high, full width, 12 apart; the in-app path is
    // primary when there is one.
    return KuberBottomSheet(
      title: 'External Link',
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (inAppPos != null) ...[
            AppButton(
              label: 'Open in app',
              icon: Icons.menu_book_outlined,
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                context.push('/reader', extra: inAppPos);
              },
            ),
            const SizedBox(height: KuberSpace.md),
          ],
          AppButton(
            label: 'Open in browser',
            icon: Icons.open_in_new_rounded,
            type: inAppPos != null
                ? AppButtonType.outline
                : AppButtonType.primary,
            fullWidth: true,
            onPressed: () => _openInBrowser(context),
          ),
        ],
      ),
      child: UrlBox(url),
    );
  }
}
