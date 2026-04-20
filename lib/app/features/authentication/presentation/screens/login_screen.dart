import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // true = phone login (CI), false = email login
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
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final identifier = _usePhone
        ? '+225${_phoneCtrl.text.trim().replaceAll(' ', '')}'
        : _emailCtrl.text.trim();
    final success = await ref
        .read(authProvider.notifier)
        .signIn(identifier, _passwordCtrl.text);
    if (success && mounted) context.go(AppRoutes.home);
  }

  void _continueAsGuest() => context.go(AppRoutes.home);

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
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingPage),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spaceXL),

                // Header
                Text(
                  'Bon retour',
                  style: AppTextStyles.h1,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppDimensions.spaceSM),

                Text(
                  'Connectez-vous pour continuer',
                  style: AppTextStyles.bodyLG.copyWith(color: AppColors.textSecondary),
                ).animate(delay: 80.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),

                // Phone / Email tab toggle
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
                ).animate(delay: 140.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),

                // Phone field (Ivory Coast)
                if (_usePhone) ...[
                  _PhoneField(
                    controller: _phoneCtrl,
                  ).animate().fadeIn(duration: 300.ms),
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
                      if (!v.contains('@')) return 'Entrez un e-mail valide';
                      return null;
                    },
                  ).animate().fadeIn(duration: 300.ms),
                ],

                const SizedBox(height: AppDimensions.spaceLG),

                // Password
                AppTextField(
                  controller: _passwordCtrl,
                  label: 'Mot de passe',
                  hint: 'Entrez votre mot de passe',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  prefixIcon: Icon(PhosphorIcons.lock(), size: 18, color: AppColors.textSecondary),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le mot de passe est requis';
                    return null;
                  },
                ).animate(delay: 40.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceSM),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Mot de passe oublié ?',
                      style: AppTextStyles.labelMD.copyWith(color: AppColors.primary),
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
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.warningCircle(), size: 16, color: AppColors.error),
                        const SizedBox(width: AppDimensions.spaceSM),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: AppTextStyles.bodyXS.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).shakeX(hz: 3, amount: 4),
                ],

                const SizedBox(height: AppDimensions.spaceXXL),

                // Login button
                AppButton(
                  label: 'Se connecter',
                  onPressed: _submit,
                  isLoading: isLoading,
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                // Continue as guest
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _continueAsGuest,
                    child: Text('Continuer sans inscription'),
                  ),
                ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas encore de compte ? ',
                      style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.signup),
                      child: Text(
                        'S\'inscrire',
                        style: AppTextStyles.labelMD.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Phone field with CI prefix ────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéro de téléphone',
          style: AppTextStyles.labelMD,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Country prefix badge
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
