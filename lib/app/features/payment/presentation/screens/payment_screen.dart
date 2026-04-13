import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

// ── Payment Method Model ───────────────────────────────────────────────────

class _PaymentMethod {
  const _PaymentMethod({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    this.requiresPhone = true,
    this.requiresBankDetails = false,
  });

  final String id;
  final String label;
  final String sublabel;
  final String icon;
  final Color color;
  final bool requiresPhone;
  final bool requiresBankDetails;
}

const _methods = [
  _PaymentMethod(
    id: 'mtn_momo',
    label: 'MTN Mobile Money',
    sublabel: 'Instant · Available nationwide',
    icon: '📱',
    color: Color(0xFFFFC107),
  ),
  _PaymentMethod(
    id: 'orange_money',
    label: 'Orange Money',
    sublabel: 'Instant · Available in West Africa',
    icon: '🟠',
    color: Color(0xFFFF6B00),
  ),
  _PaymentMethod(
    id: 'wave',
    label: 'Wave',
    sublabel: 'Instant · Lowest fees',
    icon: '🌊',
    color: Color(0xFF1A73E8),
  ),
  _PaymentMethod(
    id: 'bank',
    label: 'Bank Transfer',
    sublabel: '1–2 business hours',
    icon: '🏦',
    color: Color(0xFF14B8A6),
    requiresPhone: false,
    requiresBankDetails: true,
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────────

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.listingTitle,
    required this.totalUSD,
    required this.nights,
    required this.localCurrency,
    required this.localTotal,
  });

  final String listingTitle;
  final double totalUSD;
  final int nights;
  final String localCurrency;
  final double localTotal;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'mtn_momo';
  final _phoneCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  bool _processing = false;

  _PaymentMethod get _current =>
      _methods.firstWhere((m) => m.id == _selectedMethod);

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_current.requiresPhone && _phoneCtrl.text.trim().length < 10) {
      _showSnack('Please enter a valid phone number.');
      return;
    }
    if (_current.requiresBankDetails &&
        (_bankNameCtrl.text.trim().isEmpty ||
            _accountCtrl.text.trim().isEmpty)) {
      _showSnack('Please fill in bank details.');
      return;
    }

    setState(() => _processing = true);
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _processing = false);
      context.go(AppRoutes.bookingConfirmation);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Escrow Banner ──────────────────────────────────────────
            _EscrowBanner().animate().fadeIn(duration: 400.ms),

            const SizedBox(height: AppDimensions.spaceXXL),

            // ── Order Summary ──────────────────────────────────────────
            _OrderSummary(
              listingTitle: widget.listingTitle,
              nights: widget.nights,
              totalUSD: widget.totalUSD,
              localCurrency: widget.localCurrency,
              localTotal: widget.localTotal,
            ).animate(delay: 80.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppDimensions.spaceXXL),
            const Divider(),
            const SizedBox(height: AppDimensions.spaceXXL),

            // ── Payment Methods ────────────────────────────────────────
            Text('Payment method', style: AppTextStyles.h3)
                .animate(delay: 120.ms)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceLG),

            ..._methods.asMap().entries.map(
              (e) => _MethodTile(
                method: e.value,
                isSelected: _selectedMethod == e.value.id,
                delay: 140 + e.key * 60,
                onTap: () => setState(() => _selectedMethod = e.value.id),
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            // ── Details form ───────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _current.requiresPhone
                  ? _PhoneField(
                      key: const ValueKey('phone'),
                      controller: _phoneCtrl,
                      methodLabel: _current.label,
                    )
                  : _current.requiresBankDetails
                      ? _BankFields(
                          key: const ValueKey('bank'),
                          bankCtrl: _bankNameCtrl,
                          accountCtrl: _accountCtrl,
                        )
                      : const SizedBox.shrink(key: ValueKey('none')),
            ),

            const SizedBox(height: AppDimensions.space3XL),

            // ── Terms note ─────────────────────────────────────────────
            Text(
              'By proceeding, you agree to our Terms of Service. Your payment is held in secure escrow and released to the host 24 hours after check-in.',
              style: AppTextStyles.bodyXS
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppDimensions.spaceXXL),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingPage,
          AppDimensions.spaceMD,
          AppDimensions.paddingPage,
          MediaQuery.of(context).padding.bottom + AppDimensions.spaceLG,
        ),
        child: AppButton(
          label: _processing
              ? 'Processing…'
              : 'Pay ${_localDisplay(widget.localTotal, widget.localCurrency)}',
          isLoading: _processing,
          onPressed: _processing ? null : _pay,
        ),
      ),
    );
  }

  String _localDisplay(double amount, String code) {
    final symbols = {
      'GHS': '₵',
      'NGN': '₦',
      'XOF': 'CFA ',
      'USD': '\$',
    };
    final sym = symbols[code] ?? '\$';
    return '$sym${amount.toStringAsFixed(0)}';
  }
}

// ── Escrow Banner ──────────────────────────────────────────────────────────

class _EscrowBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: AppColors.primaryDark,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escrow-Protected Payment',
                  style: AppTextStyles.labelMD
                      .copyWith(color: AppColors.primaryDark),
                ),
                const SizedBox(height: 3),
                Text(
                  'Your funds are held securely and only released to the host 24–48 hours after you check in.',
                  style: AppTextStyles.bodyXS
                      .copyWith(color: AppColors.primaryDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order Summary ──────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.listingTitle,
    required this.nights,
    required this.totalUSD,
    required this.localCurrency,
    required this.localTotal,
  });

  final String listingTitle;
  final int nights;
  final double totalUSD;
  final String localCurrency;
  final double localTotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order summary', style: AppTextStyles.h3),
        const SizedBox(height: AppDimensions.spaceMD),
        Container(
          padding: const EdgeInsets.all(AppDimensions.spaceLG),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _SummaryRow(label: listingTitle, value: ''),
              const SizedBox(height: AppDimensions.spaceXS),
              _SummaryRow(
                label: '$nights ${nights == 1 ? 'night' : 'nights'}',
                value: '\$${totalUSD.toStringAsFixed(0)}',
                isSubtle: true,
              ),
              if (localCurrency != 'USD') ...[
                const SizedBox(height: AppDimensions.spaceXS),
                _SummaryRow(
                  label: 'Local equivalent',
                  value: _localStr(),
                  isSubtle: true,
                  valueColor: AppColors.primaryDark,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceMD),
                child: Divider(),
              ),
              _SummaryRow(
                label: 'Total charged',
                value: '\$${totalUSD.toStringAsFixed(0)}',
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _localStr() {
    final symbols = {
      'GHS': '₵',
      'NGN': '₦',
      'XOF': 'CFA ',
    };
    final sym = symbols[localCurrency] ?? '';
    return '$sym${localTotal.toStringAsFixed(0)}';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isSubtle = false,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isSubtle;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? AppTextStyles.labelLG
        : isSubtle
            ? AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary)
            : AppTextStyles.bodyMD;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (value.isNotEmpty)
          Text(
            value,
            style: style.copyWith(
              color: valueColor ?? (isBold ? AppColors.textPrimary : null),
              fontWeight: isBold ? FontWeight.w700 : null,
            ),
          ),
      ],
    );
  }
}

// ── Method Tile ────────────────────────────────────────────────────────────

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.isSelected,
    required this.delay,
    required this.onTap,
  });

  final _PaymentMethod method;
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
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        decoration: BoxDecoration(
          color: isSelected
              ? method.color.withAlpha(20)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: isSelected ? method.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(method.icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: AppDimensions.spaceLG),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label, style: AppTextStyles.labelMD),
                  const SizedBox(height: 2),
                  Text(
                    method.sublabel,
                    style: AppTextStyles.bodyXS
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? method.color : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? method.color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 350.ms);
  }
}

// ── Phone Field ────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    super.key,
    required this.controller,
    required this.methodLabel,
  });

  final TextEditingController controller;
  final String methodLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$methodLabel number', style: AppTextStyles.labelMD),
        const SizedBox(height: AppDimensions.spaceSM),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'e.g. 0244 123 456',
            prefixIcon: const Icon(Icons.phone_android_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'A payment prompt will be sent to this number.',
                style: AppTextStyles.bodyXS
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Bank Fields ────────────────────────────────────────────────────────────

class _BankFields extends StatelessWidget {
  const _BankFields({
    super.key,
    required this.bankCtrl,
    required this.accountCtrl,
  });

  final TextEditingController bankCtrl;
  final TextEditingController accountCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bank details', style: AppTextStyles.labelMD),
        const SizedBox(height: AppDimensions.spaceSM),
        TextFormField(
          controller: bankCtrl,
          decoration: InputDecoration(
            hintText: 'Bank name (e.g. GTBank, GCB)',
            prefixIcon: const Icon(Icons.account_balance_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        TextFormField(
          controller: accountCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Account number',
            prefixIcon: const Icon(Icons.credit_card_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Text(
          'We will initiate the transfer after ID verification is complete.',
          style:
              AppTextStyles.bodyXS.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
