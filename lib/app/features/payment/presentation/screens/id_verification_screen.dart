import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/shared/widgets/app_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ── ID Type Model ──────────────────────────────────────────────────────────

class _IdType {
  const _IdType({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.country,
  });

  final String id;
  final String label;
  final String sublabel;
  final String icon;
  final String country;
}

const _idTypes = [
  _IdType(
    id: 'ghana_card',
    label: 'Ghana Card',
    sublabel: 'National ID for Ghanaian citizens',
    icon: '🇬🇭',
    country: 'Ghana',
  ),
  _IdType(
    id: 'nin',
    label: 'NIN (National ID)',
    sublabel: 'Nigerian National Identification Number',
    icon: '🇳🇬',
    country: 'Nigeria',
  ),
  _IdType(
    id: 'voter_id',
    label: "Voter's ID Card",
    sublabel: 'Issued by Electoral Commission',
    icon: '🗳️',
    country: 'Ghana / Nigeria',
  ),
  _IdType(
    id: 'passport',
    label: 'International Passport',
    sublabel: 'Valid for all nationalities',
    icon: '🛂',
    country: 'All countries',
  ),
  _IdType(
    id: 'drivers_license',
    label: "Driver's License",
    sublabel: 'Valid photo ID',
    icon: '🪪',
    country: 'All countries',
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────────

class IdVerificationScreen extends StatefulWidget {
  const IdVerificationScreen({super.key, this.returnRoute});

  /// Route to push after successful verification (optional).
  final String? returnRoute;

  @override
  State<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen> {
  int _step =
      0; // 0 = select type, 1 = upload front, 2 = upload back, 3 = selfie, 4 = done
  String? _selectedId;
  bool _frontUploaded = false;
  bool _backUploaded = false;
  bool _selfieUploaded = false;
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your ID'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.x()),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (_step) {
          0 => _StepSelectId(
            key: const ValueKey(0),
            selectedId: _selectedId,
            onSelect: (id) => setState(() => _selectedId = id),
            onNext: () => setState(() => _step = 1),
          ),
          1 => _StepUploadPhoto(
            key: const ValueKey(1),
            title: 'Front of ID',
            instruction:
                'Make sure all corners are visible and the text is clearly readable.',
            icon: PhosphorIcons.creditCard(),
            isUploaded: _frontUploaded,
            onUpload: () => setState(() => _frontUploaded = true),
            onNext: () => setState(() => _step = 2),
          ),
          2 => _StepUploadPhoto(
            key: const ValueKey(2),
            title: 'Back of ID',
            instruction: 'Place the ID on a flat surface with good lighting.',
            icon: PhosphorIcons.arrowsIn(),
            isUploaded: _backUploaded,
            onUpload: () => setState(() => _backUploaded = true),
            onNext: () => setState(() => _step = 3),
          ),
          3 => _StepSelfie(
            key: const ValueKey(3),
            isUploaded: _selfieUploaded,
            onUpload: () => setState(() => _selfieUploaded = true),
            onNext: () async {
              setState(() => _processing = true);
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                setState(() {
                  _processing = false;
                  _step = 4;
                });
              }
            },
            processing: _processing,
          ),
          _ => _StepSuccess(
            key: const ValueKey(4),
            onContinue: () {
              if (widget.returnRoute != null) {
                context.push(widget.returnRoute!);
              } else {
                context.pop();
              }
            },
          ),
        },
      ),
    );
  }
}

// ── Step Indicator ─────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final done = i < current;
        final active = i == current;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: done || active ? AppColors.primary : AppColors.border,
            ),
          ),
        );
      }),
    );
  }
}

// ── Step 0: Select ID type ─────────────────────────────────────────────────

class _StepSelectId extends StatelessWidget {
  const _StepSelectId({
    super.key,
    required this.selectedId,
    required this.onSelect,
    required this.onNext,
  });

  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepIndicator(current: 0, total: 4),
          const SizedBox(height: AppDimensions.spaceXXL),
          Text(
            'Select your ID type',
            style: AppTextStyles.h2,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'We need a government-issued photo ID to verify your identity before check-in.',
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.space2XL),
          Expanded(
            child: ListView.separated(
              itemCount: _idTypes.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimensions.spaceMD),
              itemBuilder: (context, i) {
                final t = _idTypes[i];
                final selected = selectedId == t.id;
                return GestureDetector(
                      onTap: () => onSelect(t.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(AppDimensions.spaceLG),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryLight
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLG,
                          ),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(t.icon, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: AppDimensions.spaceLG),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.label, style: AppTextStyles.labelMD),
                                  Text(
                                    t.sublabel,
                                    style: AppTextStyles.bodyXS.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              Icon(
                                PhosphorIcons.checkCircle(
                                  PhosphorIconsStyle.fill,
                                ),
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    )
                    .animate(delay: Duration(milliseconds: 80 + i * 50))
                    .fadeIn(duration: 350.ms);
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          AppButton(
            label: 'Continue',
            isDisabled: selectedId == null,
            onPressed: selectedId != null ? onNext : null,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ── Step 1 & 2: Upload photo ───────────────────────────────────────────────

class _StepUploadPhoto extends StatelessWidget {
  const _StepUploadPhoto({
    super.key,
    required this.title,
    required this.instruction,
    required this.icon,
    required this.isUploaded,
    required this.onUpload,
    required this.onNext,
  });

  final String title;
  final String instruction;
  final IconData icon;
  final bool isUploaded;
  final VoidCallback onUpload;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(current: title.contains('Front') ? 1 : 2, total: 4),
          const SizedBox(height: AppDimensions.spaceXXL),
          Text(
            title,
            style: AppTextStyles.h2,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            instruction,
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.space3XL),
          GestureDetector(
            onTap: onUpload,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.success.withAlpha(20)
                    : AppColors.border.withAlpha(40),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                border: Border.all(
                  color: isUploaded ? AppColors.success : AppColors.border,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUploaded ? PhosphorIcons.checkCircle() : icon,
                    size: 56,
                    color: isUploaded
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  Text(
                    isUploaded
                        ? 'Photo uploaded ✓'
                        : 'Tap to take photo or upload',
                    style: AppTextStyles.labelMD.copyWith(
                      color: isUploaded
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
          const Spacer(),
          AppButton(
            label: 'Continue',
            isDisabled: !isUploaded,
            onPressed: isUploaded ? onNext : null,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ── Step 3: Selfie ─────────────────────────────────────────────────────────

class _StepSelfie extends StatelessWidget {
  const _StepSelfie({
    super.key,
    required this.isUploaded,
    required this.onUpload,
    required this.onNext,
    required this.processing,
  });

  final bool isUploaded;
  final VoidCallback onUpload;
  final VoidCallback onNext;
  final bool processing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepIndicator(current: 3, total: 4),
          const SizedBox(height: AppDimensions.spaceXXL),
          Text(
            'Take a selfie',
            style: AppTextStyles.h2,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Hold your device at eye level. Make sure your face is clearly visible in good lighting.',
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.space3XL),
          GestureDetector(
            onTap: onUpload,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUploaded
                      ? AppColors.success.withAlpha(20)
                      : AppColors.border.withAlpha(40),
                  border: Border.all(
                    color: isUploaded ? AppColors.success : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isUploaded
                          ? PhosphorIcons.checkCircle()
                          : PhosphorIcons.smiley(),
                      size: 64,
                      color: isUploaded
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isUploaded ? 'Selfie taken ✓' : 'Tap to open camera',
                      style: AppTextStyles.bodyXS.copyWith(
                        color: isUploaded
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
          const Spacer(),
          AppButton(
            label: processing ? 'Verifying…' : 'Submit for Verification',
            isLoading: processing,
            isDisabled: !isUploaded || processing,
            onPressed: isUploaded && !processing ? onNext : null,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ── Step 4: Success ────────────────────────────────────────────────────────

class _StepSuccess extends StatelessWidget {
  const _StepSuccess({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
              color: AppColors.success,
              size: 52,
            ),
          ).animate().scale(
            begin: const Offset(0.6, 0.6),
            duration: 500.ms,
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: AppDimensions.space2XL),
          Text(
            'ID Submitted!',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            'Your documents are under review. Verification usually completes within 2 hours. You\'ll receive a notification once approved.',
            style: AppTextStyles.bodyLG.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.space3XL),
          _TrustPoint(
            icon: PhosphorIcons.lock(),
            text: 'Your ID is encrypted and stored securely.',
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.spaceMD),
          _TrustPoint(
            icon: PhosphorIcons.eyeSlash(),
            text: 'Only shared with hosts after confirmed booking.',
          ).animate(delay: 480.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.space3XL),
          AppButton(
            label: 'Continue',
            onPressed: onContinue,
          ).animate(delay: 560.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

class _TrustPoint extends StatelessWidget {
  const _TrustPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppDimensions.spaceMD),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
