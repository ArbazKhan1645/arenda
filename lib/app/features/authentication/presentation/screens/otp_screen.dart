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
import '../../application/auth_notifier.dart';
import '../../application/auth_state.dart';
import '../../domain/enums/auth_provider_type.dart';

// ── Navigation args ───────────────────────────────────────────────────────────

class OtpArgs {
  final AuthProviderType providerType;
  final String identifier;
  final String? name;
  final bool isSignUp;

  const OtpArgs({
    required this.providerType,
    required this.identifier,
    this.name,
    this.isSignUp = false,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class OtpScreen extends ConsumerStatefulWidget {
  final OtpArgs args;
  const OtpScreen({super.key, required this.args});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = '';
  int _resendSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _resendSeconds = 30);
    _tickTimer();
  }

  Future<void> _tickTimer() async {
    while (_resendSeconds > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _resendSeconds--);
    }
  }

  Future<void> _verify() async {
    if (_code.length != 6) return;
    final isLoading = ref.read(authProvider) is AuthLoading;
    if (isLoading) return;

    bool success;
    if (widget.args.isSignUp) {
      success = await ref
          .read(authProvider.notifier)
          .verifyOtpSignUp(
            identifier: widget.args.identifier,
            name: widget.args.name ?? '',
            otp: _code,
          );
    } else {
      success = await ref
          .read(authProvider.notifier)
          .verifyOtpSignIn(identifier: widget.args.identifier, otp: _code);
    }

    if (!mounted) return;
    if (success) context.go(AppRoutes.home);
  }

  String get _maskedDestination {
    final id = widget.args.identifier;
    if (widget.args.providerType == AuthProviderType.email) {
      final idx = id.indexOf('@');
      if (idx > 3) {
        return '${id.substring(0, 3)}***${id.substring(idx)}';
      }
    } else {
      if (id.length >= 6) {
        return '${id.substring(0, id.length - 4)}****';
      }
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final hasError = authState is AuthError;
    final isPhone = widget.args.providerType == AuthProviderType.phone;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingPage,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceXL),

              // Icon
              Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isPhone
                          ? PhosphorIcons.deviceMobile(PhosphorIconsStyle.fill)
                          : PhosphorIcons.envelope(PhosphorIconsStyle.fill),
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

              Text(
                    'Vérifiez votre\n${isPhone ? 'numéro' : 'e-mail'}',
                    style: AppTextStyles.h1,
                  )
                  .animate(delay: 80.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppDimensions.spaceSM),

              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Code à 6 chiffres envoyé à '),
                    TextSpan(
                      text: _maskedDestination,
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 120.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.space3XL),

              // OTP boxes
              _OtpBoxes(
                hasError: hasError,
                onChanged: (code) {
                  setState(() => _code = code);
                  if (hasError) ref.read(authProvider.notifier).clearError();
                },
                onCompleted: (code) {
                  setState(() => _code = code);
                  _verify();
                },
              ).animate(delay: 160.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.spaceMD),

              // Demo hint badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.info(),
                        size: 13,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Code démo : 123456',
                        style: AppTextStyles.bodyXS.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

              // Error
              if (hasError) ...[
                const SizedBox(height: AppDimensions.spaceMD),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceMD),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
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
                          'Code incorrect. Essayez 123456.',
                          style: AppTextStyles.bodyXS.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).shakeX(hz: 3, amount: 4),
              ],

              const Spacer(),

              AppButton(
                label: 'Vérifier',
                onPressed: _code.length == 6 ? _verify : null,
                isLoading: isLoading,
              ).animate(delay: 240.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.spaceLG),

              Center(
                child: _resendSeconds > 0
                    ? Text(
                        'Renvoyer le code dans ${_resendSeconds}s',
                        style: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : TextButton(
                        onPressed: _startResendTimer,
                        child: Text(
                          'Renvoyer le code',
                          style: AppTextStyles.labelMD.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ).animate(delay: 280.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 6-box OTP input ───────────────────────────────────────────────────────────

class _OtpBoxes extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;
  final bool hasError;

  const _OtpBoxes({
    required this.onChanged,
    required this.onCompleted,
    required this.hasError,
  });

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (final n in _nodes) {
      n.addListener(_rebuild);
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _nodes[0].requestFocus(),
    );
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.removeListener(_rebuild);
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int i, String val) {
    setState(() {});
    final code = _code;
    widget.onChanged(code);
    if (val.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
    if (code.length == 6) widget.onCompleted(code);
  }

  KeyEventResult _onKey(int i, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[i].text.isEmpty &&
        i > 0) {
      _controllers[i - 1].clear();
      _nodes[i - 1].requestFocus();
      setState(() {});
      widget.onChanged(_code);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final isFilled = _controllers[i].text.isNotEmpty;
        final isFocused = _nodes[i].hasFocus;
        return Focus(
          onKeyEvent: (_, event) => _onKey(i, event),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 58,
            decoration: BoxDecoration(
              color: isFilled ? AppColors.primarySurface : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.hasError
                    ? AppColors.error
                    : isFocused
                    ? AppColors.primary
                    : isFilled
                    ? AppColors.primary.withAlpha(100)
                    : AppColors.border,
                width: isFocused || widget.hasError ? 2.0 : 1.5,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: _controllers[i],
              focusNode: _nodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => _onChanged(i, v),
            ),
          ),
        );
      }),
    );
  }
}
