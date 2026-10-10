import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tourgo/core/utils/locale_font.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/app_version_provider.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../widgets/about_sections.dart';

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
            child: KuberAppBar(showBack: true, showBrand: false),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _DeveloperLetter(),
                const SizedBox(height: KuberSpace.xxl),

                // Why Tour of Go — visual feature grid
                const _WhyTourOfGoSection(),
                const SizedBox(height: KuberSpace.xl),

                // What is Tour of Go
                const AboutWhatIsTourOfGoSection(),
                const SizedBox(height: KuberSpace.xl),

                // Go Philosophy
                const AboutGoPhilosophySection(),
                const SizedBox(height: KuberSpace.xl),

                // App Info Section
                _AboutCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "App Version",
                            style: localeFont(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface,
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, _) {
                              final version =
                                  ref.watch(appVersionProvider).valueOrNull ??
                                      '1.0.0';
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHigh,
                                  borderRadius: KuberShape.smallR,
                                ),
                                child: Text(
                                  "v$version",
                                  style: monoFont(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: KuberSpace.lg),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: KuberShape.mediumR,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Content licensed under CC BY 3.0 by Google LLC",
                                style: localeFont(
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
                const SizedBox(height: KuberSpace.lg),

                // Links / Feedback
                const _LinksCard(),
                const SizedBox(height: KuberSpace.xxl),

                // Footer
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: localeFont(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: "Made with "),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.favorite_rounded,
                            color: cs.error,
                            size: 14,
                          ),
                        ),
                        const TextSpan(text: " in India"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpace.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AboutCard — shared card shell (matches Kuber pattern exactly)
// ─────────────────────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  final Widget child;
  const _AboutCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [child],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WhyTourOfGoSection — visual feature grid (6 tiles for symmetry)
// ─────────────────────────────────────────────────────────────────────────────

class _WhyTourOfGoSection extends StatelessWidget {
  const _WhyTourOfGoSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
          child: Text(
            'WHY TOUR OF GO?',
            style: localeFont(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: cs.primary,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.95,
          children: const [
            _WhyFeatureTile(
              icon: Icons.menu_book_rounded,
              title: "Clean lesson reader",
              subtitle: "Typography-first layout built for phones.",
            ),
            _WhyFeatureTile(
              icon: Icons.play_arrow_rounded,
              title: "Run code in-app",
              subtitle: "Execute every example via the Go Playground.",
            ),
            _WhyFeatureTile(
              icon: Icons.cloud_off_rounded,
              title: "Works offline",
              subtitle: "Lessons cached for reading anywhere.",
            ),
            _WhyFeatureTile(
              icon: Icons.bar_chart_rounded,
              title: "Track progress",
              subtitle: "See which chapters you have completed.",
            ),
            _WhyFeatureTile(
              icon: Icons.auto_awesome_mosaic_rounded,
              title: "Go by Example",
              subtitle: "Practical code examples, all in one place.",
            ),
            _WhyFeatureTile(
              icon: Icons.bolt_rounded,
              title: "Fast and focused",
              subtitle: "Open, learn, close. No distractions.",
            ),
          ],
        ),
      ],
    );
  }
}

class _WhyFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _WhyFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Disc
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: KuberShape.mediumR,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 20, color: cs.onSecondaryContainer),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    height: 1.25,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    subtitle,
                    style: localeFont(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DeveloperLetter — personal note from the maker
// ─────────────────────────────────────────────────────────────────────────────

class _DeveloperLetter extends StatelessWidget {
  const _DeveloperLetter();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final textStyleRegular = localeFont(
      fontSize: 15,
      height: 1.75,
      color: cs.onSurface,
      letterSpacing: -0.1,
    );
    final textStyleSemiBold = textStyleRegular.copyWith(
      fontWeight: FontWeight.w600,
    );

    // Kuber board 3.13: surfaceContainer + 1dp outlineVariant, no gradient
    // and no watermark.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eyebrow
                Text(
                  "A NOTE FROM THE MAKER",
                  style: localeFont(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                RichText(
                  text: TextSpan(
                    style: localeFont(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: -0.7,
                      height: 1.1,
                    ),
                    children: [
                      const TextSpan(text: "Why I built\n"),
                      TextSpan(
                        text: "this app",
                        style: serifFont(
                          fontSize: 38,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Body text
                Text.rich(
                  TextSpan(
                    style: textStyleRegular,
                    children: [
                      TextSpan(
                        text: "Hey there,\n\n",
                        style: textStyleSemiBold,
                      ),
                      const TextSpan(
                        text:
                            "When I first started learning Go, I spent most of my time "
                            "switching between two amazing resources: the official "
                            "Go Tour on go.dev and Go by Example.\n\n"
                            "Both are incredibly well written. But here is the thing: "
                            "they are built for the desktop browser. On a phone, the "
                            "experience always felt a bit off. Pinch-zooming into code "
                            "blocks, losing your place when you switch tabs, no way to "
                            "track which lessons you have already finished.\n\n",
                      ),
                      TextSpan(
                        text: "I kept wishing for a proper mobile version.\n\n",
                        style: textStyleSemiBold,
                      ),
                      const TextSpan(
                        text:
                            "So I decided to build one myself. An app with a clean "
                            "reader, syntax highlighted code, the ability to run "
                            "examples directly, and a simple progress tracker to keep "
                            "me accountable.\n\n"
                            "This is not meant to replace the original websites. "
                            "Think of it as a companion. Something you can open on "
                            "your commute, during a break, or right before bed to "
                            "sneak in a quick lesson.\n\n"
                            "If this app helps even one person stick with learning "
                            "Go a little longer, then it was worth building.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                // Signature Card
                Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: KuberShape.cardR,
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        final uri = Uri.parse("https://singhgautam.com");
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                // Avatar Disc
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cs.primary,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "GS",
                                    style: localeFont(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Signature Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "SIGNED",
                                        style: localeFont(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurfaceVariant,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "Gautam",
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  serifFont(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                                color: cs.onSurface,
                                                letterSpacing: -0.3,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: cs.primary
                                                    .withValues(alpha: 0.44),
                                                decorationStyle:
                                                    TextDecorationStyle.solid,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Separator Border
                          Container(height: 1, color: cs.outlineVariant),
                          // URL Footer Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            color: cs.surfaceContainerHigh,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "singhgautam.com",
                                  style: monoFont(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurfaceVariant,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "VISIT",
                                      style: localeFont(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: cs.primary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_outward_rounded,
                                      size: 12,
                                      color: cs.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LinksCard — external links with chevrons (matches Kuber _FeedbackCard)
// ─────────────────────────────────────────────────────────────────────────────

class _LinksCard extends StatelessWidget {
  const _LinksCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _LinkTile(
            icon: Icons.language_rounded,
            label: "Official Go Tour",
            subtitle: "go.dev/tour",
            onTap: () => _openUrl('https://go.dev/tour/'),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant,
            indent: 16,
            endIndent: 16,
          ),
          _LinkTile(
            icon: Icons.code_rounded,
            label: "Go by Example",
            subtitle: "gobyexample.com",
            onTap: () => _openUrl('https://gobyexample.com/'),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant,
            indent: 16,
            endIndent: 16,
          ),
          _LinkTile(
            icon: Icons.library_books_rounded,
            label: "Go Documentation",
            subtitle: "go.dev/doc",
            onTap: () => _openUrl('https://go.dev/doc/'),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant,
            indent: 16,
            endIndent: 16,
          ),
          _LinkTile(
            icon: Icons.star_outline_rounded,
            label: "Rate this app",
            subtitle: "Help others discover it on the Play Store",
            onTap: () => _openUrl(
              'https://play.google.com/store/apps/details?id=com.grs.tourgo',
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant,
            indent: 16,
            endIndent: 16,
          ),
          // Same entry as Kuber's and Mull's About: the developer's Play page.
          _LinkTile(
            icon: Icons.apps_rounded,
            label: "More apps from the developer",
            subtitle: "Everything else on Google Play",
            onTap: () => _openUrl(
              'https://play.google.com/store/apps/developer?id=Gautam+Rajeev+Singh',
            ),
          ),
        ],
      ),
    );
  }

  static void _openUrl(String url) {
    try {
      launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launchUrl(Uri.parse(url));
    }
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            // Squircle Icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: KuberShape.mediumR,
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Icon(icon, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 12),
            // Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: localeFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: localeFont(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Chevron
            Opacity(
              opacity: 0.6,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
