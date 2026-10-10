import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';

const _feedbackTypes = ['Bug', 'New Feature Request', 'General Feedback'];

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _selectedType = _feedbackTypes.first;
  final _feedbackCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final feedbackText = _feedbackCtrl.text.trim();
    if (feedbackText.isEmpty) {
      showKuberSnackBar(context, 'Please enter your feedback before submitting.',
          isError: true);
      return;
    }

    // Capture context-dependent values before async gaps
    final size = MediaQuery.of(context).size;
    final screenSize = '${size.width.toInt()} x ${size.height.toInt()}';

    setState(() => _isSubmitting = true);

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();

      String deviceModel = 'Unknown';
      String osVersion = 'Unknown';

      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceModel = '${android.manufacturer} ${android.model}';
        osVersion = 'Android ${android.version.release} (SDK ${android.version.sdkInt})';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceModel = ios.model;
        osVersion = 'iOS ${ios.systemVersion}';
      }

      final subject = '[Tour of Go Feedback] $_selectedType';
      final body = '''
Type: $_selectedType

Feedback:
$feedbackText

---
Device Info
-----------
App Version : ${packageInfo.version} (${packageInfo.buildNumber})
Device      : $deviceModel
OS          : $osVersion
Screen Size : $screenSize
''';

      final uri = Uri.parse(
        'mailto:singhgautam7@gmail.com'
        '?subject=${Uri.encodeComponent(subject)}'
        '&body=${Uri.encodeComponent(body)}',
      );

      if (!await launchUrl(uri)) {
        if (mounted) {
          showKuberSnackBar(
              context, 'Could not open mail app. Please try again.',
              isError: true);
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: KuberScrollAwayHeader(
        header: const KuberAppBar(
          showBack: true,
          title: 'Feedback',
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin,
              KuberSpace.sm, KuberSpace.screenMargin, KuberSpace.xl),
          children: [
            const KuberSectionHeader(title: 'Type'),
            // M3 choice chips (Kuber controls.md): r8, selected
            // secondaryContainer with a check.
            Wrap(
              spacing: KuberSpace.sm,
              runSpacing: KuberSpace.sm,
              children: [
                for (final t in _feedbackTypes)
                  ChoiceChip(
                    label: Text(t),
                    selected: t == _selectedType,
                    onSelected: (_) => setState(() => _selectedType = t),
                  ),
              ],
            ),
            const SizedBox(height: KuberSpace.sectionGap),
            const KuberSectionHeader(title: 'Your feedback'),
            TextField(
              controller: _feedbackCtrl,
              minLines: 4,
              maxLines: 8,
              style: tt.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Describe your feedback here...',
              ),
            ),
            const SizedBox(height: KuberSpace.xl),
            // A quiet note: tonal box, no border.
            Container(
              padding: const EdgeInsets.all(KuberSpace.lg),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: KuberShape.mediumR,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 20, color: cs.onSurfaceVariant),
                  const SizedBox(width: KuberSpace.md),
                  Expanded(
                    child: Text(
                      'When you submit, a few basic device details (like model, OS version, and app version) will be included to help us better understand and resolve your feedback.',
                      style: tt.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KuberSpace.xl),
            AppButton(
              label: 'Submit',
              icon: Icons.send_outlined,
              type: AppButtonType.primary,
              fullWidth: true,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
