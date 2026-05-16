import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/tourgo_app_bar.dart';
import '../../../shared/widgets/settings_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: TourGoAppBar(showBack: true, title: ''),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App\nSettings',
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
                    'Customize your experience and preferences.',
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
            padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.xxl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── APPEARANCE ──────────────────────────────────────────
                const SettingsSectionLabel(label: 'APPEARANCE'),
                const SizedBox(height: KuberSpacing.sm),
                SettingsCard(
                  children: [
                    _TileBlock(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      child: SettingsCardSelector<ThemeMode>(
                        options: const [
                          SelectorOption(
                            value: ThemeMode.light,
                            label: 'LIGHT',
                            icon: Icons.light_mode_outlined,
                          ),
                          SelectorOption(
                            value: ThemeMode.dark,
                            label: 'DARK',
                            icon: Icons.dark_mode_outlined,
                          ),
                          SelectorOption(
                            value: ThemeMode.system,
                            label: 'SYSTEM',
                            icon: Icons.settings_brightness_outlined,
                          ),
                        ],
                        selectedValue: settings.themeMode,
                        onSelected: notifier.setThemeMode,
                      ),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _TileBlock(
                      icon: Icons.text_fields_rounded,
                      title: 'Font size',
                      child: SettingsCardSelector<FontSize>(
                        options: const [
                          SelectorOption(
                            value: FontSize.small,
                            label: 'SMALL',
                            icon: Icons.text_decrease_rounded,
                          ),
                          SelectorOption(
                            value: FontSize.medium,
                            label: 'MEDIUM',
                            icon: Icons.text_fields_rounded,
                          ),
                          SelectorOption(
                            value: FontSize.large,
                            label: 'LARGE',
                            icon: Icons.text_increase_rounded,
                          ),
                        ],
                        selectedValue: settings.fontSize,
                        onSelected: notifier.setFontSize,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // ── CODE ────────────────────────────────────────────────
                const SettingsSectionLabel(label: 'CODE'),
                const SizedBox(height: KuberSpacing.sm),
                SettingsCard(
                  children: [
                    _SwitchRow(
                      icon: Icons.wrap_text_rounded,
                      label: 'Wrap code lines',
                      subtitle:
                          'Wrap long lines in code viewers and the sandbox instead of horizontal scroll.',
                      value: settings.wrapLines,
                      onChanged: notifier.setWrapLines,
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // App identity card
                Container(
                  padding: const EdgeInsets.all(KuberSpacing.lg),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius:
                        BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              cs.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                              KuberRadius.md),
                          border: Border.all(
                              color: cs.primary
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Icon(Icons.circle_outlined,
                              color: cs.primary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'A Tour of Go',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              'v1.0.0 · go.dev content',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11.5,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TileBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _TileBlock({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
        vertical: KuberSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SquircleIcon(icon: icon, size: 18, padding: 8),
              const SizedBox(width: KuberSpacing.md),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        child: Row(
          children: [
            SquircleIcon(icon: icon, size: 18, padding: 8),
            const SizedBox(width: KuberSpacing.md),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
