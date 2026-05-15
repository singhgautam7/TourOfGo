import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 7),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(
                            color: cs.outline.withValues(alpha: 0.25)),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 18, color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.lg),

              Text(
                'More',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Settings and information.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),

              // Settings card
              _Section(
                title: 'PREFERENCES',
                items: [
                  _MenuItem(
                    icon: Icons.palette_outlined,
                    label: 'Appearance',
                    subtitle: 'Theme and font size',
                    onTap: () => context.push('/more/settings'),
                    cs: cs,
                  ),
                ],
                cs: cs,
              ),
              const SizedBox(height: KuberSpacing.md),

              _Section(
                title: 'DATA',
                items: [
                  _MenuItem(
                    icon: Icons.data_usage_rounded,
                    label: 'Data & Storage',
                    subtitle: 'Manage cache and progress',
                    onTap: () => context.push('/more/data'),
                    cs: cs,
                  ),
                ],
                cs: cs,
              ),
              const SizedBox(height: KuberSpacing.md),

              _Section(
                title: 'INFORMATION',
                items: [
                  _MenuItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About',
                    subtitle: 'App info and attributions',
                    onTap: () => context.push('/more/about'),
                    cs: cs,
                  ),
                ],
                cs: cs,
              ),

              const SizedBox(height: KuberSpacing.xxl),
              Center(
                child: Text(
                  'A Tour of Go · v1.0',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  final ColorScheme cs;

  const _Section({required this.title, required this.items, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final idx = e.key;
              return Column(
                children: [
                  e.value,
                  if (idx < items.length - 1) Divider(height: 1, color: cs.outline),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.md, vertical: KuberSpacing.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
              ),
              child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      letterSpacing: -0.1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
