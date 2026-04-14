import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../application/review_notifier.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddReviewScreen extends ConsumerStatefulWidget {
  const AddReviewScreen({super.key, required this.listingId});

  final String listingId;

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;
  String? _error;

  static const _ratingLabels = [
    '',
    'Terrible',
    'Poor',
    'Okay',
    'Good',
    'Amazing!',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() => _error = 'Please select a rating.');
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      setState(() => _error = 'Please write a comment.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    await ref.read(reviewProvider.notifier).addReview(
          listingId: widget.listingId,
          rating: _rating,
          comment: _commentController.text.trim(),
        );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a review'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.x()),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Rating Stars ────────────────────────────────────────────
            Text('Your rating', style: AppTextStyles.h3)
                .animate()
                .fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceLG),
            _StarSelector(
              rating: _rating,
              onChanged: (v) => setState(() {
                _rating = v;
                _error = null;
              }),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceSM),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _rating > 0
                  ? Text(
                      _ratingLabels[_rating],
                      key: ValueKey(_rating),
                      style: AppTextStyles.labelMD.copyWith(
                        color: _ratingColor(_rating),
                      ),
                    )
                  : const SizedBox(key: ValueKey(0)),
            ),

            const SizedBox(height: AppDimensions.space3XL),
            const Divider(),
            const SizedBox(height: AppDimensions.space3XL),

            // ── Comment ─────────────────────────────────────────────────
            Text('Your experience', style: AppTextStyles.h3)
                .animate(delay: 150.ms)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'Tell other guests what made this stay special.',
              style:
                  AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
            ).animate(delay: 180.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceLG),
            TextFormField(
              controller: _commentController,
              maxLines: 6,
              maxLength: 500,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                hintText:
                    'Share details about the location, cleanliness, host communication…',
                hintStyle: AppTextStyles.bodyMD
                    .copyWith(color: AppColors.textTertiary),
                contentPadding: const EdgeInsets.all(AppDimensions.spaceLG),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLG),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLG),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLG),
                  borderSide: BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

            // ── Error ────────────────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: AppDimensions.spaceMD),
              Row(
                children: [
                  Icon(PhosphorIcons.info(),
                      size: 16, color: AppColors.error),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Text(
                    _error!,
                    style: AppTextStyles.bodySM
                        .copyWith(color: AppColors.error),
                  ),
                ],
              ).animate().fadeIn(duration: 200.ms),
            ],

            const SizedBox(height: AppDimensions.space3XL),

            // ── Category Ratings ─────────────────────────────────────────
            Text('Category ratings', style: AppTextStyles.h3)
                .animate(delay: 250.ms)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.spaceLG),
            ..._CategoryRow.categories.asMap().entries.map(
              (e) => _CategoryRow(
                label: e.value,
                delay: 280 + e.key * 40,
              ),
            ),

            const SizedBox(height: AppDimensions.space4XL),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingPage,
          AppDimensions.spaceLG,
          AppDimensions.paddingPage,
          MediaQuery.of(context).padding.bottom + AppDimensions.spaceLG,
        ),
        child: AppButton(
          label: 'Submit review',
          isLoading: _submitting,
          onPressed: _submitting ? null : _submit,
        ),
      ),
    );
  }

  Color _ratingColor(int r) {
    if (r <= 2) return AppColors.error;
    if (r == 3) return AppColors.warning;
    return AppColors.success;
  }
}

// ── Star Selector ──────────────────────────────────────────────────────────

class _StarSelector extends StatelessWidget {
  const _StarSelector({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final starIndex = i + 1;
        return GestureDetector(
          onTap: () => onChanged(starIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              starIndex <= rating
                  ? PhosphorIcons.star(PhosphorIconsStyle.fill)
                  : PhosphorIcons.star(PhosphorIconsStyle.fill),
              size: 44,
              color: starIndex <= rating ? AppColors.star : AppColors.border,
            ),
          ),
        );
      }),
    );
  }
}

// ── Category Row ───────────────────────────────────────────────────────────

class _CategoryRow extends StatefulWidget {
  const _CategoryRow({required this.label, required this.delay});

  final String label;
  final int delay;

  static const categories = [
    'Cleanliness',
    'Accuracy',
    'Check-in',
    'Communication',
    'Location',
    'Value',
  ];

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  int _value = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceLG),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.label, style: AppTextStyles.bodyLG),
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _value = star),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    star <= _value
                        ? PhosphorIcons.star(PhosphorIconsStyle.fill)
                        : PhosphorIcons.star(PhosphorIconsStyle.fill),
                    size: 24,
                    color: star <= _value ? AppColors.star : AppColors.border,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.05, end: 0, duration: 400.ms);
  }
}
