import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'core/utils/go_tour_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool(GoTourPrefs.onboarded) ?? false;
  runApp(ProviderScope(
    overrides: [
      initialLocationProvider
          .overrideWithValue(onboarded ? '/' : '/onboarding'),
    ],
    child: const GoTourApp(),
  ));
}
