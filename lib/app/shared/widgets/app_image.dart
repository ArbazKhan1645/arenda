import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_shimmer.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) =>
          placeholder ??
          AppShimmer(
            width: width ?? double.infinity,
            height: height ?? double.infinity,
          ),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: AppColors.surface,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
