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
import '../../features/more/screens/feedback_screen.dart';
import '../../features/sandbox/screens/sandbox_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/gobyexample/screens/example_reader_screen.dart';
import '../../features/gobyexample/models/go_example.dart';
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
        path: '/more/feedback',
        builder: (_, s) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: '/example/:slug',
        builder: (_, state) {
          // extra is set when coming from search; resolve from slug otherwise
          final extra = state.extra;
          if (extra is GoExampleIndex) {
            return ExampleReaderScreen(index: extra);
          }
          // Fallback: build a stub index from the path param; the screen will
          // load the full index list and jump to the right position.
          final slug = state.pathParameters['slug'] ?? '';
          return ExampleReaderScreen(
            index: GoExampleIndex(slug: slug, title: '', order: 0),
          );
        },
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
