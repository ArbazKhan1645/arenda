import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/shared/widgets/app_avatar.dart';
import 'package:arenda/app/shared/widgets/app_button.dart';
import 'package:arenda/app/features/authentication/application/auth_notifier.dart';
import 'package:arenda/app/features/authentication/application/auth_state.dart';

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
          IconButton(icon: Icon(PhosphorIcons.gear()), onPressed: () {}),
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
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppDimensions.spaceSM),
              if (user.location != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.mapPin(),
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      user.location!,
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceXXL),

          // ID verification status card
          _IdVerificationCard(),

          const SizedBox(height: AppDimensions.spaceXXL),

          // Become a Host CTA
          _BecomeHostCard(),

          const SizedBox(height: AppDimensions.spaceXXL),
          const Divider(),
          const SizedBox(height: AppDimensions.spaceXXL),

          /// 🔥 NEW MODERN MENU SECTION
          _ProfileSection(
            title: 'Account',
            children: [
              _ModernMenuItem(
                icon: PhosphorIcons.user(),
                label: 'Edit profile',
                onTap: () => context.push(AppRoutes.editProfile),
              ),
              _ModernMenuItem(
                icon: PhosphorIcons.suitcase(),
                label: 'My trips',
                onTap: () => context.push(AppRoutes.bookingHistory),
              ),
              _ModernMenuItem(
                icon: PhosphorIcons.heart(),
                label: 'Wishlists',
                onTap: () => context.go(AppRoutes.wishlist),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _ProfileSection(
            title: 'Hosting',
            children: [
              _ModernMenuItem(
                icon: PhosphorIcons.chatCircle(),
                label: 'Messages',
                onTap: () => context.go(AppRoutes.inbox),
              ),
              _ModernMenuItem(
                icon: PhosphorIcons.squaresFour(),
                label: 'Host dashboard',
                onTap: () => context.push(AppRoutes.hostDashboard),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _ProfileSection(
            title: 'Support',
            children: [
              _ModernMenuItem(
                icon: PhosphorIcons.shield(),
                label: 'Trust & Safety',
                onTap: () => context.push(AppRoutes.trustSafety),
              ),
              _ModernMenuItem(
                icon: PhosphorIcons.question(),
                label: 'Help Center',
                onTap: () {},
              ),
              _ModernMenuItem(
                icon: PhosphorIcons.lock(),
                label: 'Privacy Policy',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceXXL),
          const Divider(),
          const SizedBox(height: AppDimensions.spaceXXL),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(PhosphorIcons.signOut(), color: AppColors.error),
            title: Text(
              'Log out',
              style: AppTextStyles.bodyLG.copyWith(color: AppColors.error),
            ),
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),

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
            child: Icon(
              PhosphorIcons.identificationCard(),
              color: const Color(0xFFE65100),
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify your identity',
                  style: AppTextStyles.labelMD.copyWith(
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Required for check-in. Upload your Ghana Card, NIN, or Passport.',
                  style: AppTextStyles.bodyXS.copyWith(
                    color: const Color(0xFFBF360C),
                  ),
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
        gradient: const LinearGradient(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSM,
                      ),
                    ),
                    child: Text(
                      'Learn more',
                      style: AppTextStyles.labelSM.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Icon(
            PhosphorIcons.buildings(PhosphorIconsStyle.fill),
            color: Colors.white,
            size: 48,
          ),
        ],
      ),
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
            Icon(PhosphorIcons.user(), size: 80, color: AppColors.border),
            const SizedBox(height: AppDimensions.spaceLG),
            Text(
              'Log in to your account',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'Sign in to view your profile, trips and wishlists.',
              style: AppTextStyles.bodyLG.copyWith(
                color: AppColors.textSecondary,
              ),
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

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMD.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ModernMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModernMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            /// ICON CONTAINER
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),

            const SizedBox(width: 14),

            /// TEXT
            Expanded(child: Text(label, style: AppTextStyles.bodyLG)),

            /// ARROW
            Icon(
              PhosphorIcons.caretRight(),
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
