import 'package:arenda/app/shared/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/shared/widgets/app_button.dart';
import 'package:arenda/app/shared/widgets/app_text_field.dart';
import 'package:arenda/app/features/authentication/application/auth_notifier.dart';
import 'package:arenda/app/features/authentication/application/auth_state.dart';
import 'package:arenda/app/features/authentication/domain/enums/auth_provider_type.dart';
import 'package:arenda/app/features/authentication/presentation/screens/otp_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _usePhone = true;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _usePhone = _tabController.index == 0);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_usePhone) {
      // Phone → OTP screen
      final identifier = '+225${_phoneCtrl.text.trim().replaceAll(' ', '')}';
      await context.push(
        AppRoutes.otp,
        extra: OtpArgs(
          providerType: AuthProviderType.phone,
          identifier: identifier,
          name: _nameCtrl.text.trim(),
          isSignUp: true,
        ),
      );
    } else {
      // Email + password → direct sign up
      final success = await ref
          .read(authProvider.notifier)
          .signUp(
            email: _emailCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
      if (success && mounted) context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final errorMessage = (!_usePhone && authState is AuthError)
        ? authState.message
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(PhosphorIcons.x()),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.login),
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
                const SizedBox(height: AppDimensions.spaceLG),

                // Brand mark
                Row(
                  children: [
                    const AppLogo(),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'arenda',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Rejoignez 1000+ voyageurs en CI',
                          style: AppTextStyles.bodyXS.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppDimensions.space2XL),

                Text('Créer un compte', style: AppTextStyles.h1)
                    .animate(delay: 60.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppDimensions.spaceSM),

                Text(
                  _usePhone
                      ? 'Votre numéro CI, votre identité sur arenda.'
                      : 'Créez votre compte avec un e-mail et un mot de passe.',
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),

                // Tab switcher
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMD - 2,
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.labelMD,
                    unselectedLabelStyle: AppTextStyles.bodyMD,
                    padding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(text: 'Numéro CI'),
                      Tab(text: 'E-mail'),
                    ],
                  ),
                ).animate(delay: 120.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),

                // Full name (always shown)
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Nom complet',
                  hint: 'Votre nom complet',
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(
                    PhosphorIcons.user(),
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Le nom est requis';
                    }
                    if (v.trim().length < 2) return 'Nom trop court';
                    return null;
                  },
                ).animate(delay: 160.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                // Phone or Email + password fields
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _usePhone
                      ? _CIPhoneField(
                          key: const ValueKey('phone'),
                          controller: _phoneCtrl,
                        )
                      : _EmailPasswordFields(
                          key: const ValueKey('email'),
                          emailCtrl: _emailCtrl,
                          passwordCtrl: _passwordCtrl,
                          confirmCtrl: _confirmCtrl,
                          onSubmit: _submit,
                        ),
                ),

                const SizedBox(height: AppDimensions.spaceMD),

                Row(
                  children: [
                    Icon(
                      PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _usePhone
                          ? 'Vérification par code OTP envoyé par SMS'
                          : 'Vos données sont chiffrées et sécurisées',
                      style: AppTextStyles.bodyXS.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                // Error (email path only)
                if (errorMessage != null) ...[
                  const SizedBox(height: AppDimensions.spaceMD),
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

                const SizedBox(height: AppDimensions.space2XL),

                AppButton(
                  label: _usePhone ? 'Recevoir le code' : 'Créer mon compte',
                  onPressed: _submit,
                  isLoading: isLoading,
                ).animate(delay: 240.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                Text(
                  'En créant un compte, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyXS.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.6,
                  ),
                ).animate(delay: 260.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: Text(
                        'Se connecter',
                        style: AppTextStyles.labelMD.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 280.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── CI phone field with IntrinsicHeight ───────────────────────────────────────

class _CIPhoneField extends StatelessWidget {
  const _CIPhoneField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Numéro de téléphone', style: AppTextStyles.labelMD),
        const SizedBox(height: 6),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(child: _CIFlag()),
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: AppTextStyles.bodyMD,
                  decoration: InputDecoration(
                    hintText: '07 00 00 00 00',
                    hintStyle: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Le numéro est requis';
                    }
                    if (v.trim().length < 8) return 'Numéro invalide';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Email + password + confirm ────────────────────────────────────────────────

class _EmailPasswordFields extends StatelessWidget {
  const _EmailPasswordFields({
    super.key,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.onSubmit,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: emailCtrl,
          label: 'Adresse e-mail',
          hint: 'vous@exemple.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icon(
            PhosphorIcons.envelope(),
            size: 18,
            color: AppColors.textSecondary,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'L\'e-mail est requis';
            if (!RegExp(r'^[\w.]+@([\w]+\.)+[\w]+$').hasMatch(v.trim())) {
              return 'Entrez un e-mail valide';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spaceLG),
        AppTextField(
          controller: passwordCtrl,
          label: 'Mot de passe',
          hint: 'Au moins 8 caractères',
          obscureText: true,
          textInputAction: TextInputAction.next,
          prefixIcon: Icon(
            PhosphorIcons.lock(),
            size: 18,
            color: AppColors.textSecondary,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Le mot de passe est requis';
            if (v.length < 8) return 'Minimum 8 caractères';
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spaceLG),
        AppTextField(
          controller: confirmCtrl,
          label: 'Confirmer le mot de passe',
          hint: 'Répétez votre mot de passe',
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
          prefixIcon: Icon(
            PhosphorIcons.lock(),
            size: 18,
            color: AppColors.textSecondary,
          ),
          validator: (v) {
            if (v != passwordCtrl.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ── CI flag widget (CustomPainter — works on all platforms) ─────────────────

class _CIFlag extends StatelessWidget {
  const _CIFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: CustomPaint(size: const Size(28, 20), painter: _CIFlagPainter()),
    );
  }
}

class _CIFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / 3;
    // Orange stripe
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, size.height),
      Paint()..color = const Color(0xFFF77F00),
    );
    // White stripe
    canvas.drawRect(
      Rect.fromLTWH(w, 0, w, size.height),
      Paint()..color = Colors.white,
    );
    // Green stripe
    canvas.drawRect(
      Rect.fromLTWH(w * 2, 0, w, size.height),
      Paint()..color = const Color(0xFF009A44),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
