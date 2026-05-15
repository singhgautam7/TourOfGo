import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
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
              Text(
                'Appearance',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Theme and reading preferences.',
                style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: KuberSpacing.xl),

              // Theme selector
              _SettingsLabel(label: 'THEME', cs: cs),
              _SettingsCard(
                cs: cs,
                child: Column(
                  children: ThemeMode.values.map((mode) {
                    final selected = settings.themeMode == mode;
                    return _SelectorRow(
                      label: switch (mode) {
                        ThemeMode.system => 'System',
                        ThemeMode.light => 'Light',
                        ThemeMode.dark => 'Dark',
                      },
                      icon: switch (mode) {
                        ThemeMode.system => Icons.brightness_auto_rounded,
                        ThemeMode.light => Icons.light_mode_outlined,
                        ThemeMode.dark => Icons.dark_mode_outlined,
                      },
                      selected: selected,
                      onTap: () => notifier.setThemeMode(mode),
                      cs: cs,
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: KuberSpacing.lg),

              // Font size selector
              _SettingsLabel(label: 'FONT SIZE', cs: cs),
              _SettingsCard(
                cs: cs,
                child: Column(
                  children: FontSize.values.map((size) {
                    final selected = settings.fontSize == size;
                    return _SelectorRow(
                      label: switch (size) {
                        FontSize.small => 'Small',
                        FontSize.medium => 'Medium',
                        FontSize.large => 'Large',
                      },
                      icon: Icons.text_fields_rounded,
                      selected: selected,
                      onTap: () => notifier.setFontSize(size),
                      cs: cs,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SettingsLabel({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final ColorScheme cs;
  const _SettingsCard({required this.child, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: child,
    );
  }
}

class _SelectorRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _SelectorRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.md, vertical: KuberSpacing.md),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? cs.primary : cs.onSurface,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 16, color: cs.primary),
          ],
        ),
      ),
    );
  }
}
