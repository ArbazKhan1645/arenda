import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class AppRatingBar extends StatelessWidget {
  const AppRatingBar({
    super.key,
    required this.rating,
    this.size = 14.0,
    this.color = AppColors.star,
    this.showLabel = false,
    this.reviewCount,
  });

  final double rating;
  final double size;
  final Color color;
  final bool showLabel;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: color),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(2),
          style: TextStyle(
            fontSize: size - 1,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (showLabel && reviewCount != null) ...[
          const SizedBox(width: AppDimensions.spaceXS),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size - 1,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class AppStarRatingInput extends StatefulWidget {
  const AppStarRatingInput({
    super.key,
    required this.onRatingChanged,
    this.initialRating = 0,
    this.starSize = 36.0,
  });

  final ValueChanged<int> onRatingChanged;
  final int initialRating;
  final double starSize;

  @override
  State<AppStarRatingInput> createState() => _AppStarRatingInputState();
}

class _AppStarRatingInputState extends State<AppStarRatingInput> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < _rating;
        return GestureDetector(
          onTap: () {
            setState(() => _rating = index + 1);
            widget.onRatingChanged(index + 1);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: widget.starSize,
              color: filled ? AppColors.star : AppColors.border,
            ),
          ),
        );
      }),
    );
  }
}
