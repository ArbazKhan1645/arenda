import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static final _pages = [
    _OnboardingPage(
      image: 'assets/images/onboarding/onboarding_1.jpg',
      badge: 'West Africa\'s #1 rental platform',
      title: 'Verified shortlets\nacross West Africa',
      subtitle: 'Every listing is physically vetted by our team. Find trusted apartments, villas and shortlets in Accra, Lagos, Dakar and beyond.',
      highlights: [
        _Highlight(icon: PhosphorIcons.sealCheck(PhosphorIconsStyle.fill), label: 'Physically vetted properties'),
        _Highlight(icon: PhosphorIcons.shield(PhosphorIconsStyle.fill), label: 'Trusted & verified hosts'),
      ],
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding/onboarding_2.jpg',
      badge: 'Pay the way you know',
      title: 'Mobile Money\npayments built in',
      subtitle: 'Pay with MTN MoMo, Orange Money, Wave or bank transfer. Your funds are held in escrow until check-in.',
      highlights: [
        _Highlight(icon: PhosphorIcons.lock(PhosphorIconsStyle.fill), label: 'Escrow payment protection'),
        _Highlight(icon: PhosphorIcons.deviceMobile(), label: 'MTN MoMo · Orange · Wave'),
      ],
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding/onboarding_3.jpg',
      badge: 'No more "near the big tree"',
      title: 'Navigate by\nlandmark directions',
      subtitle: 'GPS coordinates alone won\'t cut it. Every listing includes local landmark directions so you always find your way.',
      highlights: [
        _Highlight(icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill), label: 'Landmark-based navigation'),
        _Highlight(icon: PhosphorIcons.mapTrifold(), label: 'Local directions from hosts'),
      ],
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding/onboarding_4.jpg',
      badge: 'You\'re protected',
      title: 'ID-verified guests\n& trusted stays',
      subtitle: 'Ghana Card, NIN, Voter ID — all guests verify before check-in. Hosts are vetted. Your safety comes first.',
      highlights: [
        _Highlight(icon: PhosphorIcons.identificationCard(), label: 'Government ID verification'),
        _Highlight(icon: PhosphorIcons.headset(PhosphorIconsStyle.fill), label: '24/7 guest support'),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return _OnboardingPageView(page: _pages[index]);
            },
          ),

          // Bottom overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(220),
                  ],
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                AppDimensions.paddingPage,
                AppDimensions.space3XL,
                AppDimensions.paddingPage,
                MediaQuery.of(context).padding.bottom + AppDimensions.paddingPage,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(200),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      _pages[_currentPage].badge,
                      style: AppTextStyles.bodyXS.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate(key: ValueKey('badge$_currentPage')).fadeIn(duration: 300.ms),

                  const SizedBox(height: AppDimensions.spaceMD),

                  Text(
                    _pages[_currentPage].title,
                    style: AppTextStyles.displayMD.copyWith(
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ).animate(key: ValueKey(_currentPage)).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: AppDimensions.spaceMD),

                  Text(
                    _pages[_currentPage].subtitle,
                    style: AppTextStyles.bodyLG.copyWith(
                      color: Colors.white.withAlpha(204),
                    ),
                  ).animate(key: ValueKey('sub$_currentPage')).fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: AppDimensions.spaceLG),

                  // Highlight pills
                  Wrap(
                    spacing: AppDimensions.spaceSM,
                    runSpacing: AppDimensions.spaceSM,
                    children: _pages[_currentPage].highlights.map((h) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          border: Border.all(color: Colors.white.withAlpha(60)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(h.icon, color: Colors.white, size: 14),
                            const SizedBox(width: 5),
                            Text(h.label,
                                style: AppTextStyles.bodyXS.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ).toList(),
                  ).animate(key: ValueKey('chips$_currentPage')).fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: AppDimensions.spaceXXL),

                  Row(
                    children: [
                      // Page indicator
                      AnimatedSmoothIndicator(
                        activeIndex: _currentPage,
                        count: _pages.length,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: Colors.white,
                          dotColor: Colors.white38,
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                        ),
                      ),

                      const Spacer(),

                      // Next / Get Started button
                      SizedBox(
                        width: isLast ? 180 : 56,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isLast ? AppDimensions.radiusMD : AppDimensions.radiusFull,
                              ),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: isLast
                              ? Text(
                                  'Get Started',
                                  style: AppTextStyles.buttonLG.copyWith(color: Colors.white),
                                )
                              : Icon(PhosphorIcons.arrowRight(PhosphorIconsStyle.bold), color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  if (!isLast) ...[
                    const SizedBox(height: AppDimensions.spaceLG),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: Text(
                          'Skip',
                          style: AppTextStyles.bodyMD.copyWith(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      page.image,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.highlights,
  });

  final String image;
  final String badge;
  final String title;
  final String subtitle;
  final List<_Highlight> highlights;
}

class _Highlight {
  const _Highlight({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
