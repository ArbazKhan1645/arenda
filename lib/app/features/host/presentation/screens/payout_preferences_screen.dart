// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PayoutPreferencesScreen extends ConsumerStatefulWidget {
  const PayoutPreferencesScreen({super.key});

  @override
  ConsumerState<PayoutPreferencesScreen> createState() =>
      _PayoutPreferencesScreenState();
}

class _PayoutPreferencesScreenState
    extends ConsumerState<PayoutPreferencesScreen> {
  String _selected = 'mtn_momo';
  String _currency = 'GHS';
  bool _saving = false;

  final _mtnCtrl = TextEditingController();
  final _orangeCtrl = TextEditingController();
  final _waveCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();

  static const _methods = [
    (
      id: 'mtn_momo',
      label: 'MTN Mobile Money',
      icon: '📱',
      color: Color(0xFFFFC107),
    ),
    (
      id: 'orange_money',
      label: 'Orange Money',
      icon: '🟠',
      color: Color(0xFFFF6B00),
    ),
    (id: 'wave', label: 'Wave', icon: '🌊', color: Color(0xFF1A73E8)),
    (id: 'bank', label: 'Bank Transfer', icon: '🏦', color: Color(0xFF14B8A6)),
  ];

  static const _currencies = [
    (code: 'GHS', label: '🇬🇭 Ghana Cedi (GHS)'),
    (code: 'NGN', label: '🇳🇬 Nigerian Naira (NGN)'),
    (code: 'XOF', label: '🌍 West African CFA (XOF)'),
    (code: 'USD', label: '🇺🇸 US Dollar (USD)'),
  ];

  @override
  void dispose() {
    _mtnCtrl.dispose();
    _orangeCtrl.dispose();
    _waveCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payout preferences saved!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payout preferences')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Currency ────────────────────────────────────────────
            Text(
              'Payout currency',
              style: AppTextStyles.h3,
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'Choose the currency in which you want to receive earnings.',
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate(delay: 60.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceLG),
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: _currencies
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.code,
                      child: Text(c.label, style: AppTextStyles.bodyMD),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _currency = v ?? _currency),
            ).animate(delay: 80.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppDimensions.space3XL),
            const Divider(),
            const SizedBox(height: AppDimensions.space3XL),

            // ── Primary Method ───────────────────────────────────────
            Text(
              'Primary payout method',
              style: AppTextStyles.h3,
            ).animate(delay: 120.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'This is how you\'ll receive earnings by default.',
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceLG),

            ..._methods.asMap().entries.map(
              (e) => _MethodSelector(
                id: e.value.id,
                label: e.value.label,
                icon: e.value.icon,
                color: e.value.color,
                isSelected: _selected == e.value.id,
                delay: 170 + e.key * 60,
                onTap: () => setState(() => _selected = e.value.id),
              ),
            ),

            const SizedBox(height: AppDimensions.space2XL),

            // ── Account details ──────────────────────────────────────
            Text(
              'Account details',
              style: AppTextStyles.h3,
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceLG),

            _LabeledField(
              label: 'MTN MoMo number',
              controller: _mtnCtrl,
              hint: 'e.g. 0244 123 456',
              icon: '📱',
              delay: 420,
            ),
            _LabeledField(
              label: 'Orange Money number',
              controller: _orangeCtrl,
              hint: 'e.g. 0554 789 012',
              icon: '🟠',
              delay: 460,
            ),
            _LabeledField(
              label: 'Wave number',
              controller: _waveCtrl,
              hint: 'e.g. +221 77 123 4567',
              icon: '🌊',
              delay: 500,
            ),

            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              'Bank account',
              style: AppTextStyles.labelMD,
            ).animate(delay: 540.ms).fadeIn(),
            const SizedBox(height: AppDimensions.spaceSM),
            TextFormField(
              controller: _bankNameCtrl,
              decoration: InputDecoration(
                hintText: 'Bank name (e.g. GCB Bank, GTBank)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
              ),
            ).animate(delay: 560.ms).fadeIn(),
            const SizedBox(height: AppDimensions.spaceMD),
            TextFormField(
              controller: _accountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Account number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
              ),
            ).animate(delay: 590.ms).fadeIn(),

            const SizedBox(height: AppDimensions.space3XL),

            // ── Info note ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceLG),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    PhosphorIcons.info(),
                    size: 18,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: AppDimensions.spaceSM),
                  Expanded(
                    child: Text(
                      'Payouts are processed 24–48 hours after guest check-in. You\'ll receive a push notification when funds are released.',
                      style: AppTextStyles.bodyXS.copyWith(
                        color: AppColors.primaryDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 620.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppDimensions.space3XL),

            AppButton(
              label: 'Save preferences',
              isLoading: _saving,
              onPressed: _saving ? null : _save,
            ).animate(delay: 660.ms).fadeIn(duration: 400.ms),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

// ── Method Selector ────────────────────────────────────────────────────────

class _MethodSelector extends StatelessWidget {
  const _MethodSelector({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.delay,
    required this.onTap,
  });

  final String id;
  final String label;
  final String icon;
  final Color color;
  final bool isSelected;
  final int delay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceLG,
          vertical: AppDimensions.spaceMD,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(18) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(child: Text(label, style: AppTextStyles.labelMD)),
            if (isSelected)
              Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 350.ms);
  }
}

// ── Labeled Field ──────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.delay,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String icon;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.labelSM),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceXS),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]')),
            ],
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 350.ms);
  }
}
