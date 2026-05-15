import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_flow.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/reader/screens/lesson_reader_screen.dart';
import '../../features/more/screens/more_screen.dart';
import '../../features/more/screens/settings_screen.dart';
import '../../features/more/screens/about_screen.dart';
import '../../features/sandbox/screens/sandbox_screen.dart';
import '../utils/go_tour_prefs.dart';
import '../../providers/lesson_position_provider.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final onboarded = prefs.getBool(GoTourPrefs.onboarded) ?? false;
      if (state.matchedLocation == '/splash') return null;
      if (!onboarded && !state.matchedLocation.startsWith('/onboarding')) {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, s) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, s) => const OnboardingFlow(),
      ),
      GoRoute(
        path: '/',
        builder: (_, s) => const HomeScreen(),
      ),
      GoRoute(
        path: '/reader',
        builder: (_, state) => LessonReaderScreen(
          position: state.extra as LessonPosition,
        ),
      ),
      GoRoute(
        path: '/more',
        builder: (_, s) => const MoreScreen(),
      ),
      GoRoute(
        path: '/more/settings',
        builder: (_, s) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/more/about',
        builder: (_, s) => const AboutScreen(),
      ),
      GoRoute(
        path: '/sandbox',
        builder: (_, state) {
          final extra = state.extra;
          if (extra is Map<String, String?>) {
            return SandboxScreen(
              initialCode: extra['code'],
              title: extra['title'],
            );
          }
          return const SandboxScreen();
        },
      ),
    ],
  );
}
