import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_segmented_control.dart';
import '../../../shared/widgets/settings_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    const controlPadding = EdgeInsets.fromLTRB(
        KuberSpace.lg, 0, KuberSpace.lg, KuberSpace.lg);

    return Scaffold(
      backgroundColor: cs.surface,
      body: KuberScrollAwayHeader(
        header: const KuberAppBar(
          showBack: true,
          title: 'App settings',
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin,
              KuberSpace.sm, KuberSpace.screenMargin, KuberSpace.xxl),
          children: [
            const SettingsSectionLabel(label: 'Appearance'),
            SettingsCard(
              children: [
                const SettingsTile(icon: Icons.palette_outlined, label: 'Theme'),
                Padding(
                  padding: controlPadding,
                  child: KuberSegmentedControl<ThemeMode>(
                    values: const [
                      ThemeMode.light,
                      ThemeMode.dark,
                      ThemeMode.system,
                    ],
                    labels: const ['Light', 'Dark', 'System'],
                    selected: settings.themeMode,
                    onSelected: notifier.setThemeMode,
                  ),
                ),
                Divider(height: 1, color: cs.outlineVariant),
                const SettingsTile(
                    icon: Icons.text_fields_rounded, label: 'Font size'),
                Padding(
                  padding: controlPadding,
                  child: KuberSegmentedControl<FontSize>(
                    values: const [
                      FontSize.small,
                      FontSize.medium,
                      FontSize.large,
                    ],
                    labels: const ['Small', 'Medium', 'Large'],
                    selected: settings.fontSize,
                    onSelected: notifier.setFontSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.sectionGap),
            const SettingsSectionLabel(label: 'Code'),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.wrap_text_rounded,
                  label: 'Wrap code lines',
                  subtitle:
                      'Wrap long lines in code viewers and the sandbox instead of horizontal scroll.',
                  onTap: () => notifier.setWrapLines(!settings.wrapLines),
                  trailing: Switch(
                    value: settings.wrapLines,
                    onChanged: notifier.setWrapLines,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
