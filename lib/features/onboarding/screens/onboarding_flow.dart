import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/go_tour_prefs.dart';
import '../../../providers/tour_content_provider.dart';
import '../../../shared/widgets/go_tour_loader.dart';
import '../pages/onboarding_page_1.dart';
import '../pages/onboarding_page_2.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _startLearning() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(GoTourPrefs.onboarded, true);

    if (!mounted) return;
    await GoTourLoader.show<void>(
      context,
      label: 'Fetching content…',
      future: ref
          .read(tourContentNotifierProvider.notifier)
          .fetchFromApi()
          .then((_) {}),
    ).catchError((_) {}); // errors are non-fatal

    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (_) {},
        children: [
          OnboardingPage1(
            onNext: () => _goToPage(1),
            onSkip: _startLearning,
          ),
          OnboardingPage2(onStart: _startLearning),
        ],
      ),
    );
  }
}
