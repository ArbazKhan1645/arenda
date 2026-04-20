import 'package:flutter/material.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/shared/widgets/app_image.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48.0,
    this.borderColor,
    this.borderWidth = 0,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final initials = _getInitials(name);

    Widget avatar = hasImage
        ? AppImage(
            url: imageUrl!,
            width: size,
            height: size,
            borderRadius: BorderRadius.circular(size / 2),
          )
        : Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.labelMD.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: size * 0.35,
                ),
              ),
            ),
          );

    if (borderWidth > 0) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? AppColors.background,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    return avatar;
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}
