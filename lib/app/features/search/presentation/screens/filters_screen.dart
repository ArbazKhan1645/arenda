import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../application/search_notifier.dart';
import '../../application/search_state.dart';

class FiltersScreen extends ConsumerStatefulWidget {
  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  late SearchFilters _filters;

  @override
  void initState() {
    super.initState();
    final state = ref.read(searchProvider);
    _filters = state is SearchLoaded ? state.filters : const SearchFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _filters = const SearchFilters()),
            child: Text('Clear all',
                style:
                    AppTextStyles.labelMD.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        children: [
          // Price Range
          Text('Price range', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            '\$${_filters.minPrice.toInt()} – \$${_filters.maxPrice.toInt()} / night',
            style:
                AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
          ),
          RangeSlider(
            values: RangeValues(_filters.minPrice, _filters.maxPrice),
            min: 0,
            max: 1000,
            divisions: 100,
            activeColor: AppColors.primary,
            labels: RangeLabels(
              '\$${_filters.minPrice.toInt()}',
              '\$${_filters.maxPrice.toInt()}',
            ),
            onChanged: (v) => setState(() => _filters =
                _filters.copyWith(minPrice: v.start, maxPrice: v.end)),
          ),

          const Divider(height: AppDimensions.space2XL),

          // Bedrooms
          _CounterRow(
            label: 'Bedrooms',
            value: _filters.minBedrooms,
            onDecrement: _filters.minBedrooms > 0
                ? () => setState(() => _filters =
                    _filters.copyWith(minBedrooms: _filters.minBedrooms - 1))
                : null,
            onIncrement: () => setState(() => _filters =
                _filters.copyWith(minBedrooms: _filters.minBedrooms + 1)),
          ),

          const Divider(height: AppDimensions.spaceXXL),

          // Bathrooms
          _CounterRow(
            label: 'Bathrooms',
            value: _filters.minBathrooms,
            onDecrement: _filters.minBathrooms > 0
                ? () => setState(() => _filters =
                    _filters.copyWith(minBathrooms: _filters.minBathrooms - 1))
                : null,
            onIncrement: () => setState(() => _filters =
                _filters.copyWith(minBathrooms: _filters.minBathrooms + 1)),
          ),

          const Divider(height: AppDimensions.spaceXXL),

          // Guests
          _CounterRow(
            label: 'Guests',
            value: _filters.minGuests,
            onDecrement: _filters.minGuests > 1
                ? () => setState(() => _filters =
                    _filters.copyWith(minGuests: _filters.minGuests - 1))
                : null,
            onIncrement: () => setState(() => _filters =
                _filters.copyWith(minGuests: _filters.minGuests + 1)),
          ),

          const Divider(height: AppDimensions.spaceXXL),

          // Superhost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Superhost', style: AppTextStyles.h4),
                  Text('Stay with top-rated hosts',
                      style: AppTextStyles.bodySM),
                ],
              ),
              Switch(
                value: _filters.superhost,
                onChanged: (v) =>
                    setState(() => _filters = _filters.copyWith(superhost: v)),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space3XL),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingPage,
          AppDimensions.spaceLG,
          AppDimensions.paddingPage,
          MediaQuery.of(context).padding.bottom + AppDimensions.spaceLG,
        ),
        child: AppButton(
          label: 'Show results',
          onPressed: () {
            ref.read(searchProvider.notifier).applyFilters(_filters);
            context.pop();
          },
        ),
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.onIncrement,
    this.onDecrement,
  });

  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.h4),
        Row(
          children: [
            _CircleButton(
              icon: Icons.remove_rounded,
              onTap: onDecrement,
              enabled: onDecrement != null,
            ),
            SizedBox(
              width: 40,
              child: Text(
                value == 0 ? 'Any' : '$value+',
                style: AppTextStyles.bodyLG,
                textAlign: TextAlign.center,
              ),
            ),
            _CircleButton(
              icon: Icons.add_rounded,
              onTap: onIncrement,
              enabled: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? AppColors.textSecondary : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.textPrimary : AppColors.border,
        ),
      ),
    );
  }
}
