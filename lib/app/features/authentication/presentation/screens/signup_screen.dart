import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _usePhone = false;
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
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final identifier = _usePhone
        ? '+225${_phoneCtrl.text.trim().replaceAll(' ', '')}'
        : _emailCtrl.text.trim();
    final success = await ref.read(authProvider.notifier).signUp(
          email: identifier,
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
          icon: Icon(PhosphorIcons.x()),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingPage),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spaceXL),

                Text(
                  'Créer un compte',
                  style: AppTextStyles.h1,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppDimensions.spaceSM),

                Text(
                  'Rejoignez des milliers de voyageurs en Côte d\'Ivoire',
                  style: AppTextStyles.bodyLG.copyWith(color: AppColors.textSecondary),
                ).animate(delay: 80.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),

                // Phone / Email toggle
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
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD - 2),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.labelMD,
                    unselectedLabelStyle: AppTextStyles.bodyMD,
                    padding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(text: '🇨🇮  Numéro CI'),
                      Tab(text: '✉️  E-mail'),
                    ],
                  ),
                ).animate(delay: 120.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),

                // Full name
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Nom complet',
                  hint: 'Votre nom complet',
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(PhosphorIcons.user(), size: 18, color: AppColors.textSecondary),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Le nom est requis';
                    if (v.trim().length < 2) return 'Nom trop court';
                    return null;
                  },
                ).animate(delay: 160.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                // Phone or Email field
                if (_usePhone) ...[
                  _PhoneFieldCI(controller: _phoneCtrl)
                      .animate().fadeIn(duration: 300.ms),
                ] else ...[
                  AppTextField(
                    controller: _emailCtrl,
                    label: 'Adresse e-mail',
                    hint: 'vous@exemple.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(PhosphorIcons.envelope(), size: 18, color: AppColors.textSecondary),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'L\'e-mail est requis';
                      if (!RegExp(r'^[\w.]+@([\w]+\.)+[\w]+$').hasMatch(v.trim())) {
                        return 'Entrez un e-mail valide';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 300.ms),
                ],

                const SizedBox(height: AppDimensions.spaceLG),

                // Password
                AppTextField(
                  controller: _passwordCtrl,
                  label: 'Mot de passe',
                  hint: 'Au moins 8 caractères',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(PhosphorIcons.lock(), size: 18, color: AppColors.textSecondary),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le mot de passe est requis';
                    if (v.length < 8) return 'Minimum 8 caractères';
                    return null;
                  },
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                // Confirm password
                AppTextField(
                  controller: _confirmPasswordCtrl,
                  label: 'Confirmer le mot de passe',
                  hint: 'Répétez votre mot de passe',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  prefixIcon: Icon(PhosphorIcons.lock(), size: 18, color: AppColors.textSecondary),
                  validator: (v) {
                    if (v != _passwordCtrl.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ).animate(delay: 240.ms).fadeIn(duration: 400.ms),

                // Error
                if (errorMessage != null) ...[
                  const SizedBox(height: AppDimensions.spaceLG),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceMD),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.warningCircle(), size: 16, color: AppColors.error),
                        const SizedBox(width: AppDimensions.spaceSM),
                        Expanded(
                          child: Text(errorMessage,
                              style: AppTextStyles.bodyXS.copyWith(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).shakeX(hz: 3, amount: 4),
                ],

                const SizedBox(height: AppDimensions.spaceXXL),

                AppButton(
                  label: 'Créer mon compte',
                  onPressed: _submit,
                  isLoading: isLoading,
                ).animate(delay: 280.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                Text(
                  'En créant un compte, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyXS.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.6,
                  ),
                ).animate(delay: 320.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
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
                ).animate(delay: 360.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── CI Phone Field ────────────────────────────────────────────────────────────

class _PhoneFieldCI extends StatelessWidget {
  const _PhoneFieldCI({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Numéro de téléphone', style: AppTextStyles.labelMD),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Text('🇨🇮', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text('+225', style: AppTextStyles.labelMD),
                ],
              ),
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
                  hintStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.textTertiary),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Le numéro est requis';
                  if (v.trim().length < 8) return 'Numéro invalide';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
