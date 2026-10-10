import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../gobyexample/widgets/download_sheet.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: KuberScrollAwayHeader(
        header: const KuberAppBar(
          showBack: true,
          title: 'More',
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin,
              KuberSpace.sm, KuberSpace.screenMargin, KuberSpace.xxl),
          children: [
            const KuberSectionHeader(title: 'App'),
            KuberGroup(
              children: [
                _MenuRow(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  subtitle: 'Theme and font size',
                  onTap: () => context.push('/more/settings'),
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.sectionGap),
            const KuberSectionHeader(title: 'Content'),
            KuberGroup(
              children: [
                _MenuRow(
                  icon: Icons.download_for_offline_outlined,
                  label: 'Download All Examples',
                  subtitle: 'Save Go by Example content for offline use',
                  onTap: () => showGbeDownloadSheet(context),
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.sectionGap),
            const KuberSectionHeader(title: 'About'),
            KuberGroup(
              children: [
                _MenuRow(
                  icon: Icons.info_outline_rounded,
                  label: 'About this app',
                  subtitle: 'Information and licenses',
                  onTap: () => context.push('/more/about'),
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.sectionGap),
            const KuberSectionHeader(title: 'Help us'),
            Row(
              children: [
                Expanded(
                  child: _HelpTile(
                    icon: Icons.star_outline_rounded,
                    label: 'Rate',
                    onTap: () => launchUrl(
                      Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.grs.tourgo',
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ),
                const SizedBox(width: KuberSpace.cardGap),
                Expanded(
                  child: _HelpTile(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () => SharePlus.instance.share(
                      ShareParams(
                        text: 'Learn Go on the go! A Tour of Go is a '
                            'beautifully simple companion for the official '
                            'Go tour. Check it out: '
                            'https://play.google.com/store/apps/details?id=com.grs.tourgo',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: KuberSpace.cardGap),
                Expanded(
                  child: _HelpTile(
                    icon: Icons.feedback_outlined,
                    label: 'Feedback',
                    onTap: () => context.push('/more/feedback'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.sectionGap),
            const KuberSectionHeader(title: 'Danger zone'),
            KuberGroup(
              children: [
                _MenuRow(
                  icon: Icons.restart_alt_rounded,
                  label: 'Reset progress',
                  subtitle: 'Clear all completed lessons',
                  destructive: true,
                  onTap: () => _confirmResetProgress(context, ref),
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.xl),
            Center(
              child: Text('Content from go.dev · BSD License',
                  style: theme.textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmResetProgress(
      BuildContext context, WidgetRef ref) async {
    final cs = Theme.of(context).colorScheme;
    // Kuber's destructive confirm: themed AlertDialog, Cancel text button,
    // the confirm in the error colour.
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text('This will clear all completed lesson data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(progressNotifierProvider.notifier).resetAll();
      await ref.read(lessonPositionNotifierProvider.notifier).goTo(
            kChapterOrder.first,
            0,
          );
      if (context.mounted) {
        showKuberSnackBar(context, 'Progress cleared.');
      }
    }
  }
}

/// A More row: a 40 disc (surfaceContainerHigh, or errorContainer when
/// destructive), title, subtitle and a chevron.
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool destructive;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.destructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KuberListRow(
      leading: KuberIconTile(
        icon: icon,
        circle: true,
        tone: destructive ? KuberTone.error : KuberTone.neutral,
      ),
      title: label,
      subtitle: subtitle,
      destructive: destructive,
      trailing: const KuberChevron(),
      onTap: onTap,
    );
  }
}

/// One of the three Help us tiles: a card with a tonal disc and a label.
class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KuberCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
      child: Column(
        children: [
          KuberIconTile(icon: icon, circle: true),
          const SizedBox(height: KuberSpace.sm),
          Text(label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
