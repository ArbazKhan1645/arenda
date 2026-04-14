import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../application/auth_notifier.dart';
import '../../application/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref
        .read(authProvider.notifier)
        .signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (success && mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final errorMessage = authState is AuthError ? authState.message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: context.canPop()
            ? IconButton(
                icon: Icon(PhosphorIcons.x()),
                onPressed: () => context.canPop() ? context.pop() : null,
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingPage,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spaceXL),

                // Header
                Text(
                  'Welcome back',
                  style: AppTextStyles.h1,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppDimensions.spaceSM),

                Text(
                  'Sign in to continue your journey',
                  style: AppTextStyles.bodyLG.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),

                // Demo hint
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceMD),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.info(),
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.spaceSM),
                      Expanded(
                        child: Text(
                          'Demo: demo@arenda.com / demo1234',
                          style: AppTextStyles.bodyXS.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),

                // Email
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email address',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(
                    PhosphorIcons.envelope(),
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                // Password
                AppTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  prefixIcon: Icon(
                    PhosphorIcons.lock(),
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceSM),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyles.labelMD.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                // Error
                if (errorMessage != null) ...[
                  const SizedBox(height: AppDimensions.spaceSM),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceMD),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMD,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.warningCircle(),
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppDimensions.spaceSM),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: AppTextStyles.bodyXS.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).shakeX(hz: 3, amount: 4),
                ],

                const SizedBox(height: AppDimensions.spaceXXL),

                // Login button
                AppButton(
                  label: 'Continue',
                  onPressed: _submit,
                  isLoading: isLoading,
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceMD,
                      ),
                      child: Text(
                        'or',
                        style: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),

                const SizedBox(height: AppDimensions.spaceLG),

                // Social logins
                _SocialButton(
                  faIcon: FontAwesomeIcons.google,
                  iconColor: const Color(0xFF4285F4),
                  label: 'Continue with Google',
                  onTap: () {},
                ).animate(delay: 350.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceMD),

                _SocialButton(
                  faIcon: FontAwesomeIcons.apple,
                  iconColor: Colors.black,
                  label: 'Continue with Apple',
                  onTap: () {},
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.signup),
                      child: Text(
                        'Sign up',
                        style: AppTextStyles.labelMD.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 450.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.faIcon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData faIcon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(faIcon, size: 20, color: iconColor),
            const SizedBox(width: AppDimensions.spaceSM),
            Text(
              label,
              style: AppTextStyles.buttonLG.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
