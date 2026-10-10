import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/url_box.dart';
import '../models/go_example.dart';

class ExampleInfoSheet extends StatelessWidget {
  final GoExampleIndex example;

  const ExampleInfoSheet({super.key, required this.example});

  @override
  Widget build(BuildContext context) {
    final url = 'https://gobyexample.com/${example.slug}';

    return KuberBottomSheet(
      title: example.title,
      subtitle: 'Go by Example',
      actions: AppButton(
        label: 'Open in Browser',
        icon: Icons.open_in_new_rounded,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () async {
          final uri = Uri.parse(url);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {
            await launchUrl(uri);
          }
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KuberSectionHeader(title: 'Source'),
          UrlBox(url),
        ],
      ),
    );
  }
}

void showExampleInfoSheet(BuildContext context, GoExampleIndex example) {
  showKuberBottomSheet<void>(
    context,
    builder: (_) => ExampleInfoSheet(example: example),
  );
}
