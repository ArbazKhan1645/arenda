import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../authentication/application/auth_notifier.dart';
import '../../../authentication/application/auth_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState is AuthAuthenticated;

    if (!isLoggedIn) return _UnauthenticatedView();

    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        children: [
          // Avatar & name
          Column(
            children: [
              AppAvatar(
                imageUrl: user.avatarUrl,
                name: user.name,
                size: AppDimensions.avatarXL,
                borderColor: AppColors.primary,
                borderWidth: 2,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Text(user.name, style: AppTextStyles.h2),
              if (user.bio != null) ...[
                const SizedBox(height: AppDimensions.spaceXS),
                Text(
                  user.bio!,
                  style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppDimensions.spaceSM),
              if (user.location != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(user.location!,
                        style: AppTextStyles.bodyMD
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.spaceXXL),

          // ID verification status card
          _IdVerificationCard()
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.spaceXXL),

          // Become a Host CTA
          _BecomeHostCard()
              .animate(delay: 150.ms)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.spaceXXL),
          const Divider(),
          const SizedBox(height: AppDimensions.spaceXXL),

          // Menu items
          _MenuItem(
            icon: Icons.person_outline_rounded,
            label: 'Edit profile',
            onTap: () => context.push(AppRoutes.editProfile),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          _MenuItem(
            icon: Icons.luggage_outlined,
            label: 'My trips',
            onTap: () => context.push(AppRoutes.bookingHistory),
          ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

          _MenuItem(
            icon: Icons.favorite_outline_rounded,
            label: 'Wishlists',
            onTap: () => context.go(AppRoutes.wishlist),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

          _MenuItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Messages',
            onTap: () => context.go(AppRoutes.inbox),
          ).animate(delay: 350.ms).fadeIn(duration: 400.ms),

          _MenuItem(
            icon: Icons.dashboard_outlined,
            label: 'Host dashboard',
            onTap: () => context.push(AppRoutes.hostDashboard),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

          _MenuItem(
            icon: Icons.shield_outlined,
            label: 'Trust & Safety',
            onTap: () => context.push(AppRoutes.trustSafety),
          ).animate(delay: 450.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.spaceXXL),
          const Divider(),
          const SizedBox(height: AppDimensions.spaceXXL),

          _MenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Help Center',
            onTap: () {},
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

          _MenuItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {},
          ).animate(delay: 550.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.spaceXXL),
          const Divider(),
          const SizedBox(height: AppDimensions.spaceXXL),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: Text('Log out',
                style: AppTextStyles.bodyLG.copyWith(color: AppColors.error)),
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.space4XL),
        ],
      ),
    );
  }
}

class _IdVerificationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: const Color(0xFFFF9800).withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.badge_outlined, color: Color(0xFFE65100), size: 24),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify your identity',
                  style: AppTextStyles.labelMD.copyWith(color: const Color(0xFFE65100)),
                ),
                const SizedBox(height: 3),
                Text(
                  'Required for check-in. Upload your Ghana Card, NIN, or Passport.',
                  style: AppTextStyles.bodyXS.copyWith(color: const Color(0xFFBF360C)),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          GestureDetector(
            onTap: () => context.push(AppRoutes.idVerification),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Text(
                'Verify',
                style: AppTextStyles.labelSM.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BecomeHostCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Become a Host',
                  style: AppTextStyles.labelLG.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Earn up to \$1,200/month listing your\nproperty in West Africa.',
                  style: AppTextStyles.bodyMD.copyWith(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMD),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.becomeHost),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                    child: Text(
                      'Learn more',
                      style: AppTextStyles.labelSM.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          const Icon(Icons.home_work_rounded, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: AppTextStyles.bodyLG),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

class _UnauthenticatedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline_rounded, size: 80, color: AppColors.border),
            const SizedBox(height: AppDimensions.spaceLG),
            Text('Log in to your account',
                style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'Sign in to view your profile, trips and wishlists.',
              style: AppTextStyles.bodyLG.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space2XL),
            AppButton(
              label: 'Log in',
              onPressed: () => context.go(AppRoutes.login),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            AppButton(
              label: 'Sign up',
              variant: AppButtonVariant.outline,
              onPressed: () => context.go(AppRoutes.signup),
            ),
          ],
        ),
      ),
    );
  }
}
