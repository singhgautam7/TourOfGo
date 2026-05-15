import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
                  ),
                  child: Icon(Icons.arrow_back_rounded, size: 18, color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
              Text('About', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.6)),
              const SizedBox(height: 4),
              Text('App info and attributions.', style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
              const SizedBox(height: KuberSpacing.xl),
              Container(
                padding: const EdgeInsets.all(KuberSpacing.lg),
                decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(KuberRadius.md), border: Border.all(color: cs.primary.withValues(alpha: 0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(KuberRadius.xl), border: Border.all(color: cs.primary.withValues(alpha: 0.3))),
                      child: Icon(Icons.circle_outlined, color: cs.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('A Tour of Go', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.4)),
                      Text('Version 1.0.0', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: cs.onSurfaceVariant)),
                    ]),
                  ]),
                  const SizedBox(height: KuberSpacing.lg),
                  Text('A mobile-first companion for learning the Go programming language. All content is fetched directly from the official Go tour at go.dev.',
                      style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant, height: 1.55)),
                ]),
              ),
              const SizedBox(height: KuberSpacing.lg),
              _InfoLabel('LINKS', cs: cs),
              _LinkCard(label: 'Official Go Tour', url: 'https://go.dev/tour/', cs: cs),
              const SizedBox(height: 8),
              _LinkCard(label: 'Go Documentation', url: 'https://go.dev/doc/', cs: cs),
              const SizedBox(height: KuberSpacing.lg),
              _InfoLabel('LICENSE', cs: cs),
              Container(
                padding: const EdgeInsets.all(KuberSpacing.md),
                decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(KuberRadius.md), border: Border.all(color: cs.outline)),
                child: Text('Content from the Go tour is licensed under the Creative Commons Attribution 3.0 License. Go and the Go gopher are trademarks of Google LLC.',
                    style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant, height: 1.6)),
              ),
              const SizedBox(height: KuberSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _InfoLabel(this.label, {required this.cs});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant, letterSpacing: 1.3)),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String label;
  final String url;
  final ColorScheme cs;
  const _LinkCard({required this.label, required this.url, required this.cs});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(KuberRadius.md), border: Border.all(color: cs.outline)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
            Text(url, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: cs.primary)),
          ])),
          Icon(Icons.open_in_new_rounded, size: 16, color: cs.onSurfaceVariant),
        ]),
      ),
    );
  }
}
