import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'shared/widgets/kuber_extended_fab.dart';

class GoTourApp extends ConsumerWidget {
  const GoTourApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'A Tour of Go',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: router,
      // Drives the extended FAB's hide-on-scroll for every screen. No
      // MediaQuery read here: this builder must not rebuild per keyboard frame.
      builder: (context, child) => KuberFabScrollWatcher(child: child!),
    );
  }
}
