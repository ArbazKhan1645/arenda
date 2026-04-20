import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/auth_notifier.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // 3 slides as requested by client
  static final _pages = [
    _OnboardingPage(
      image: 'assets/images/onboarding/onboarding_1.jpg',
      badge: 'Plateforme N°1 en Côte d\'Ivoire',
      title: 'Logements vérifiés\nen Côte d\'Ivoire',
      subtitle:
          'Chaque annonce est vérifiée physiquement par notre équipe. Trouvez des appartements, villas et shortlets de confiance à Abidjan, Yamoussoukro, San Pedro et plus encore.',
      highlights: [
        _Highlight(
          icon: PhosphorIcons.sealCheck(PhosphorIconsStyle.fill),
          label: 'Propriétés vérifiées sur place',
        ),
        _Highlight(
          icon: PhosphorIcons.shield(PhosphorIconsStyle.fill),
          label: 'Hôtes certifiés & fiables',
        ),
      ],
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding/onboarding_2.jpg',
      badge: 'Payez comme vous le souhaitez',
      title: 'Paiements Mobile\nMoney intégrés',
      subtitle:
          'Payez avec Orange Money, MTN MoMo, Wave ou virement bancaire. Vos fonds sont sécurisés en séquestre jusqu\'à l\'arrivée.',
      highlights: [
        _Highlight(
          icon: PhosphorIcons.lock(PhosphorIconsStyle.fill),
          label: 'Protection par séquestre',
        ),
        _Highlight(
          icon: PhosphorIcons.deviceMobile(),
          label: 'Orange · MTN · Wave · CIB',
        ),
      ],
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding/onboarding_3.jpg',
      badge: 'Votre sécurité avant tout',
      title: 'Invités vérifiés\n& séjours sûrs',
      subtitle:
          'CNI, passeport — tous les voyageurs vérifient leur identité avant l\'arrivée. Les hôtes sont contrôlés. Votre sécurité est notre priorité.',
      highlights: [
        _Highlight(
          icon: PhosphorIcons.identificationCard(),
          label: 'Vérification d\'identité officielle',
        ),
        _Highlight(
          icon: PhosphorIcons.headset(PhosphorIconsStyle.fill),
          label: 'Support 24h/24 & 7j/7',
        ),
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
      _markAndNavigate(AppRoutes.login);
    }
  }

  void _continueAsGuest() {
    _markAndNavigate(AppRoutes.home);
  }

  Future<void> _markAndNavigate(String route) async {
    await ref.read(authProvider.notifier).markOnboarded();
    if (mounted) context.go(route);
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
            itemBuilder: (context, index) =>
                _OnboardingPageView(page: _pages[index]),
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
                  colors: [Colors.transparent, Colors.black.withAlpha(230)],
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                AppDimensions.paddingPage,
                AppDimensions.space3XL,
                AppDimensions.paddingPage,
                MediaQuery.of(context).padding.bottom +
                    AppDimensions.paddingPage,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge chip
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(210),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: Text(
                          _pages[_currentPage].badge,
                          style: AppTextStyles.bodyXS.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .animate(key: ValueKey('badge$_currentPage'))
                      .fadeIn(duration: 300.ms),

                  const SizedBox(height: AppDimensions.spaceMD),

                  Text(
                        _pages[_currentPage].title,
                        style: AppTextStyles.displayMD.copyWith(
                          color: Colors.white,
                          height: 1.15,
                        ),
                      )
                      .animate(key: ValueKey(_currentPage))
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: AppDimensions.spaceMD),

                  Text(
                        _pages[_currentPage].subtitle,
                        style: AppTextStyles.bodyLG.copyWith(
                          color: Colors.white.withAlpha(200),
                        ),
                      )
                      .animate(key: ValueKey('sub$_currentPage'))
                      .fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: AppDimensions.spaceLG),

                  // Highlight pills
                  Wrap(
                        spacing: AppDimensions.spaceSM,
                        runSpacing: AppDimensions.spaceSM,
                        children: _pages[_currentPage].highlights
                            .map(
                              (h) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(25),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(60),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(h.icon, color: Colors.white, size: 14),
                                    const SizedBox(width: 5),
                                    Text(
                                      h.label,
                                      style: AppTextStyles.bodyXS.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      )
                      .animate(key: ValueKey('chips$_currentPage'))
                      .fadeIn(duration: 400.ms, delay: 200.ms),

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
                      // Next / Commencer button
                      SizedBox(
                        width: isLast ? 180 : 56,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isLast
                                    ? AppDimensions.radiusMD
                                    : AppDimensions.radiusFull,
                              ),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: isLast
                              ? Text(
                                  'Commencer',
                                  style: AppTextStyles.buttonLG.copyWith(
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  PhosphorIcons.arrowRight(
                                    PhosphorIconsStyle.bold,
                                  ),
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spaceMD),

                  // Continue as guest
                  Center(
                    child: TextButton(
                      onPressed: _continueAsGuest,
                      child: Text(
                        'Continuer sans inscription',
                        style: AppTextStyles.bodyMD.copyWith(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white38,
                        ),
                      ),
                    ),
                  ),
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
