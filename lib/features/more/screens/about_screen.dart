import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(showBack: true, showHome: true, title: ''),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About\nA Tour of Go',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A mobile-first companion for the official Go programming language tour.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _AboutCard(
                  title: 'What is this app?',
                  child: Text(
                    'A Tour of Go is a mobile reader for the official Go language tour. All lesson content is fetched live from go.dev/tour and cached for offline reading. Code samples can be executed against the official Go Playground.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: cs.onSurface,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.xl),
                _AboutCard(
                  title: 'Why?',
                  child: Column(
                    children: const [
                      _BulletPoint(
                        icon: Icons.menu_book_rounded,
                        title: 'Focused reading',
                        subtitle:
                            'A typography-first layout designed for phones.',
                      ),
                      SizedBox(height: KuberSpacing.lg),
                      _BulletPoint(
                        icon: Icons.play_arrow_rounded,
                        title: 'Run code anywhere',
                        subtitle:
                            'Execute every example without leaving the lesson.',
                      ),
                      SizedBox(height: KuberSpacing.lg),
                      _BulletPoint(
                        icon: Icons.cloud_off_rounded,
                        title: 'Works offline',
                        subtitle:
                            'Once fetched, lessons stay available without a connection.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.xl),
                _AboutCard(
                  title: 'Links',
                  child: Column(
                    children: const [
                      _LinkRow(
                        label: 'Official Go Tour',
                        url: 'https://go.dev/tour/',
                      ),
                      SizedBox(height: KuberSpacing.md),
                      _LinkRow(
                        label: 'Go Documentation',
                        url: 'https://go.dev/doc/',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.xl),
                _AboutCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'App Version',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Text(
                              'v1.0.0',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: KuberSpacing.lg),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow
                              .withValues(alpha: 0.5),
                          borderRadius:
                              BorderRadius.circular(KuberRadius.sm),
                          border: Border.all(
                              color: cs.outline.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 14, color: cs.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Content licensed under CC BY 3.0 by Google LLC',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.xxl),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: 'Made with '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.favorite_rounded,
                            color: Colors.redAccent,
                            size: 14,
                          ),
                        ),
                        const TextSpan(text: ' in India'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final Widget child;
  final String? title;
  const _AboutCard({required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
          ],
          child,
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BulletPoint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: KuberSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String label;
  final String url;
  const _LinkRow({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  url,
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 11, color: cs.primary),
                ),
              ],
            ),
          ),
          Icon(Icons.open_in_new_rounded,
              size: 16, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
