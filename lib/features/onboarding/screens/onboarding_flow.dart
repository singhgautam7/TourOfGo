import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/go_tour_prefs.dart';
import '../../../providers/tour_content_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_loader.dart';
import '../widgets/onboarding_dots_indicator.dart';
import '../pages/onboarding_page_1.dart';
import '../pages/onboarding_page_2.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _startLearning() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(GoTourPrefs.onboarded, true);

    if (!mounted) return;
    await KuberLoader.show<void>(
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
    final last = _page == 1;
    // Only the pages swipe; the dots and the buttons are one fixed footer,
    // as in Perch's and Kuber's welcome.
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: const [OnboardingPage1(), OnboardingPage2()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin,
                KuberSpace.lg,
                KuberSpace.screenMargin,
                KuberSpace.xl,
              ),
              child: Column(
                children: [
                  OnboardingDotsIndicator(pageCount: 2, currentPage: _page),
                  const SizedBox(height: KuberSpace.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: last ? 'Start learning' : 'Get started',
                          icon: Icons.arrow_forward_rounded,
                          iconAfterLabel: true,
                          type: AppButtonType.primary,
                          fullWidth: true,
                          onPressed: last ? _startLearning : () => _goToPage(1),
                        ),
                      ),
                      // Skip beside the main action (Perch's welcome); the
                      // last page has nothing left to skip.
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: last
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(
                                  left: KuberSpace.md,
                                ),
                                child: AppButton(
                                  label: 'Skip',
                                  type: AppButtonType.outline,
                                  onPressed: _startLearning,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
