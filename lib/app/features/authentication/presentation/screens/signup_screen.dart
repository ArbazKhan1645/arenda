import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../application/auth_notifier.dart';
import '../../application/auth_state.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref.read(authProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
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
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
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

                Text('Create account', style: AppTextStyles.h1)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppDimensions.spaceSM),

                Text(
                  'Join millions of travelers worldwide',
                  style: AppTextStyles.bodyLG
                      .copyWith(color: AppColors.textSecondary),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),

                // Full name
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Full name',
                  hint: 'Your full name',
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      size: 18, color: AppColors.textSecondary),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length < 2) return 'Name too short';
                    return null;
                  },
                ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                // Email
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email address',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined,
                      size: 18, color: AppColors.textSecondary),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w.]+@([\w]+\.)+[\w]+$').hasMatch(v.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                // Password
                AppTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  hint: 'At least 8 characters',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      size: 18, color: AppColors.textSecondary),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'At least 8 characters required';
                    return null;
                  },
                ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                // Confirm password
                AppTextField(
                  controller: _confirmPasswordCtrl,
                  label: 'Confirm password',
                  hint: 'Re-enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      size: 18, color: AppColors.textSecondary),
                  validator: (v) {
                    if (v != _passwordCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                // Error
                if (errorMessage != null) ...[
                  const SizedBox(height: AppDimensions.spaceLG),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceMD),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 16, color: AppColors.error),
                        const SizedBox(width: AppDimensions.spaceSM),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: AppTextStyles.bodyXS
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).shakeX(hz: 3, amount: 4),
                ],

                const SizedBox(height: AppDimensions.spaceXXL),

                AppButton(
                  label: 'Create account',
                  onPressed: _submit,
                  isLoading: isLoading,
                ).animate(delay: 350.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                // Terms
                Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyXS.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.6,
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMD
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: Text(
                        'Log in',
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
