import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.height = AppDimensions.buttonHeight,
    this.width,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double height;
  final double? width;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDimensions.radiusMD;
    final isActive = !isDisabled && !isLoading;

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: switch (variant) {
        AppButtonVariant.primary => _PrimaryButton(
            label: label,
            onPressed: isActive ? onPressed : null,
            isLoading: isLoading,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            radius: radius,
          ),
        AppButtonVariant.secondary => _SecondaryButton(
            label: label,
            onPressed: isActive ? onPressed : null,
            isLoading: isLoading,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            radius: radius,
          ),
        AppButtonVariant.outline => _OutlineButton(
            label: label,
            onPressed: isActive ? onPressed : null,
            isLoading: isLoading,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            radius: radius,
          ),
        AppButtonVariant.ghost => _GhostButton(
            label: label,
            onPressed: isActive ? onPressed : null,
            isLoading: isLoading,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            radius: radius,
          ),
        AppButtonVariant.danger => _DangerButton(
            label: label,
            onPressed: isActive ? onPressed : null,
            isLoading: isLoading,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            radius: radius,
          ),
      },
    );
  }
}

// ── Internal Variants ──────────────────────────────────────────────────────

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.labelColor,
    required this.isLoading,
    this.prefixIcon,
    this.suffixIcon,
    this.loaderColor,
  });

  final String label;
  final Color labelColor;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? loaderColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            loaderColor ?? AppColors.background,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          prefixIcon!,
          const SizedBox(width: AppDimensions.spaceSM),
        ],
        Text(
          label,
          style: AppTextStyles.buttonLG.copyWith(color: labelColor),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: AppDimensions.spaceSM),
          suffixIcon!,
        ],
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.radius,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double radius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null
            ? AppColors.border
            : AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        elevation: 0,
      ),
      child: _ButtonContent(
        label: label,
        labelColor: Colors.white,
        isLoading: isLoading,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.radius,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double radius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        elevation: 0,
      ),
      child: _ButtonContent(
        label: label,
        labelColor: AppColors.primaryDark,
        isLoading: isLoading,
        loaderColor: AppColors.primaryDark,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.radius,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double radius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      child: _ButtonContent(
        label: label,
        labelColor: AppColors.textPrimary,
        isLoading: isLoading,
        loaderColor: AppColors.textPrimary,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.radius,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double radius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      child: _ButtonContent(
        label: label,
        labelColor: AppColors.primary,
        isLoading: isLoading,
        loaderColor: AppColors.primary,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.radius,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double radius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        elevation: 0,
      ),
      child: _ButtonContent(
        label: label,
        labelColor: Colors.white,
        isLoading: isLoading,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
