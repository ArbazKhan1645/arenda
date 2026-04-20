import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
    // Auto-navigate back after 2.5 s
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingPage,
          ),
          child: _sent ? _SuccessView(email: _emailCtrl.text.trim()) : _FormView(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            loading: _loading,
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

// ── Form view ─────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.spaceXL),

          Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  PhosphorIcons.lockKey(PhosphorIconsStyle.fill),
                  size: 28,
                  color: AppColors.primary,
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 300.ms),

          const SizedBox(height: AppDimensions.spaceXL),

          Text('Mot de passe oublié ?', style: AppTextStyles.h1)
              .animate(delay: 80.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppDimensions.spaceSM),

          Text(
                'Entrez l\'adresse e-mail associée à votre compte. Nous vous enverrons un lien de réinitialisation.',
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              )
              .animate(delay: 120.ms)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.space3XL),

          AppTextField(
                controller: emailCtrl,
                label: 'Adresse e-mail',
                hint: 'vous@exemple.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                prefixIcon: Icon(
                  PhosphorIcons.envelope(),
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'L\'e-mail est requis';
                  }
                  if (!v.contains('@')) return 'Entrez un e-mail valide';
                  return null;
                },
              )
              .animate(delay: 160.ms)
              .fadeIn(duration: 400.ms),

          const Spacer(),

          AppButton(
                label: 'Envoyer le lien',
                onPressed: onSubmit,
                isLoading: loading,
              )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.spaceXXL),
        ],
      ),
    );
  }
}

// ── Success view ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimensions.spaceXL),

        Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                size: 30,
                color: Color(0xFF2E7D32),
              ),
            )
            .animate()
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1.0, 1.0),
              duration: 500.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 300.ms),

        const SizedBox(height: AppDimensions.spaceXL),

        Text('E-mail envoyé !', style: AppTextStyles.h1)
            .animate(delay: 80.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0),

        const SizedBox(height: AppDimensions.spaceSM),

        RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
                children: [
                  const TextSpan(
                    text: 'Un lien de réinitialisation a été envoyé à ',
                  ),
                  TextSpan(
                    text: email,
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text:
                        '. Vérifiez également vos spams si vous ne le voyez pas.',
                  ),
                ],
              ),
            )
            .animate(delay: 120.ms)
            .fadeIn(duration: 400.ms),

        const SizedBox(height: AppDimensions.space2XL),

        Container(
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.clockCountdown(PhosphorIconsStyle.fill),
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spaceSM),
                  Text(
                    'Redirection automatique dans quelques secondes…',
                    style: AppTextStyles.bodyXS.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
            .animate(delay: 200.ms)
            .fadeIn(duration: 400.ms),
      ],
    );
  }
}
