import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

class HostCreateListingScreen extends StatefulWidget {
  const HostCreateListingScreen({super.key});

  @override
  State<HostCreateListingScreen> createState() =>
      _HostCreateListingScreenState();
}

class _HostCreateListingScreenState extends State<HostCreateListingScreen> {
  final _pageCtrl = PageController();
  int _step = 0;
  static const _totalSteps = 6;

  // ── Step 1 data
  String _propertyType = 'Apartment';

  // ── Step 2 data
  int _bedrooms = 1;
  int _bathrooms = 1;
  int _maxGuests = 2;
  final _titleCtrl = TextEditingController();

  // ── Step 3 data
  final _addressCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  String _city = 'Accra';
  String _country = 'Ghana';

  // ── Step 4 data
  String _powerType = 'Generator Backup';
  bool _hasWifi = true;
  bool _hasAC = true;
  bool _hasWater = true;
  bool _hasParking = false;
  bool _hasSecurity = true;
  bool _hasPool = false;

  // ── Step 5 data (photos placeholder)
  int _photoCount = 0;

  // ── Step 6 data
  final _priceUSDCtrl = TextEditingController();
  final _priceLocalCtrl = TextEditingController();
  String _localCurrency = 'GHS';

  @override
  void dispose() {
    _pageCtrl.dispose();
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _landmarkCtrl.dispose();
    _priceUSDCtrl.dispose();
    _priceLocalCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      context.pop();
    }
  }

  void _submit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
        title: Text('Step ${_step + 1} of $_totalSteps'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / _totalSteps,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            minHeight: 4,
          ),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _step = i),
        children: [
          _Step1PropertyType(
            selected: _propertyType,
            onSelect: (v) => setState(() => _propertyType = v),
            onNext: _next,
          ),
          _Step2Basics(
            titleCtrl: _titleCtrl,
            bedrooms: _bedrooms,
            bathrooms: _bathrooms,
            maxGuests: _maxGuests,
            onBedroomsChanged: (v) => setState(() => _bedrooms = v),
            onBathroomsChanged: (v) => setState(() => _bathrooms = v),
            onGuestsChanged: (v) => setState(() => _maxGuests = v),
            onNext: _next,
          ),
          _Step3Location(
            addressCtrl: _addressCtrl,
            landmarkCtrl: _landmarkCtrl,
            city: _city,
            country: _country,
            onCityChanged: (v) => setState(() => _city = v),
            onCountryChanged: (v) => setState(() => _country = v),
            onNext: _next,
          ),
          _Step4Utilities(
            powerType: _powerType,
            hasWifi: _hasWifi,
            hasAC: _hasAC,
            hasWater: _hasWater,
            hasParking: _hasParking,
            hasSecurity: _hasSecurity,
            hasPool: _hasPool,
            onPowerTypeChanged: (v) => setState(() => _powerType = v),
            onToggle: (key, val) => setState(() {
              switch (key) {
                case 'wifi': _hasWifi = val; break;
                case 'ac': _hasAC = val; break;
                case 'water': _hasWater = val; break;
                case 'parking': _hasParking = val; break;
                case 'security': _hasSecurity = val; break;
                case 'pool': _hasPool = val; break;
              }
            }),
            onNext: _next,
          ),
          _Step5Photos(
            photoCount: _photoCount,
            onAddPhoto: () => setState(() => _photoCount++),
            onNext: _next,
          ),
          _Step6Pricing(
            priceUSDCtrl: _priceUSDCtrl,
            priceLocalCtrl: _priceLocalCtrl,
            localCurrency: _localCurrency,
            onCurrencyChanged: (v) => setState(() => _localCurrency = v),
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Property Type ──────────────────────────────────────────────────

class _Step1PropertyType extends StatelessWidget {
  const _Step1PropertyType({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  static const _types = [
    (icon: '🏢', label: 'Apartment'),
    (icon: '🏠', label: 'House'),
    (icon: '🏡', label: 'Villa'),
    (icon: '🛏️', label: 'Studio'),
    (icon: '🏘️', label: 'Duplex'),
    (icon: '💎', label: 'Penthouse'),
    (icon: '🔒', label: 'Shortlet'),
    (icon: '🛎️', label: 'Serviced'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What type of property\nare you listing?',
                  style: AppTextStyles.h2)
              .animate()
              .fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.space2XL),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.spaceMD,
              mainAxisSpacing: AppDimensions.spaceMD,
              childAspectRatio: 1.6,
              children: _types.asMap().entries.map((e) {
                final isSelected = selected == e.value.label;
                return GestureDetector(
                  onTap: () => onSelect(e.value.label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : Theme.of(context).colorScheme.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLG),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.value.icon,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(e.value.label,
                            style: AppTextStyles.labelMD.copyWith(
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.textPrimary,
                            )),
                      ],
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: e.key * 50)).fadeIn(duration: 350.ms);
              }).toList(),
            ),
          ),
          AppButton(label: 'Next', onPressed: onNext),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ── Step 2: Basics ─────────────────────────────────────────────────────────

class _Step2Basics extends StatelessWidget {
  const _Step2Basics({
    required this.titleCtrl,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    required this.onBedroomsChanged,
    required this.onBathroomsChanged,
    required this.onGuestsChanged,
    required this.onNext,
  });

  final TextEditingController titleCtrl;
  final int bedrooms, bathrooms, maxGuests;
  final ValueChanged<int> onBedroomsChanged, onBathroomsChanged, onGuestsChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic details', style: AppTextStyles.h2)
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.space2XL),
          Text('Listing title', style: AppTextStyles.labelMD)
              .animate(delay: 80.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceSM),
          TextFormField(
            controller: titleCtrl,
            maxLength: 60,
            decoration: InputDecoration(
              hintText: 'e.g. Cozy 2-Bed Shortlet in Lekki Phase 1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceXXL),
          _CounterRow(
            label: 'Bedrooms',
            value: bedrooms,
            min: 0,
            onChanged: onBedroomsChanged,
          ).animate(delay: 140.ms).fadeIn(),
          const Divider(height: AppDimensions.space3XL),
          _CounterRow(
            label: 'Bathrooms',
            value: bathrooms,
            min: 1,
            onChanged: onBathroomsChanged,
          ).animate(delay: 180.ms).fadeIn(),
          const Divider(height: AppDimensions.space3XL),
          _CounterRow(
            label: 'Max guests',
            value: maxGuests,
            min: 1,
            onChanged: onGuestsChanged,
          ).animate(delay: 220.ms).fadeIn(),
          const SizedBox(height: AppDimensions.space3XL),
          AppButton(label: 'Next', onPressed: onNext)
              .animate(delay: 260.ms).fadeIn(),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyLG),
        Row(
          children: [
            _CircleBtn(
              icon: Icons.remove_rounded,
              enabled: value > min,
              onTap: () => onChanged(value - 1),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '$value',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
            ),
            _CircleBtn(
              icon: Icons.add_rounded,
              enabled: true,
              onTap: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? AppColors.textSecondary : AppColors.border,
          ),
        ),
        child: Icon(icon, size: 18,
            color: enabled ? AppColors.textPrimary : AppColors.border),
      ),
    );
  }
}

// ── Step 3: Location ───────────────────────────────────────────────────────

class _Step3Location extends StatelessWidget {
  const _Step3Location({
    required this.addressCtrl,
    required this.landmarkCtrl,
    required this.city,
    required this.country,
    required this.onCityChanged,
    required this.onCountryChanged,
    required this.onNext,
  });

  final TextEditingController addressCtrl, landmarkCtrl;
  final String city, country;
  final ValueChanged<String> onCityChanged, onCountryChanged;
  final VoidCallback onNext;

  static const _cities = ['Accra', 'Kumasi', 'Takoradi', 'Lagos', 'Abuja', 'Port Harcourt', 'Dakar', 'Abidjan', 'Lomé', 'Cotonou'];
  static const _countries = ['Ghana', 'Nigeria', 'Senegal', 'Ivory Coast', 'Togo', 'Benin', 'Other'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where is your property?', style: AppTextStyles.h2)
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'GPS coordinates are often inaccurate in West Africa. Landmark directions are essential.',
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
          ).animate(delay: 80.ms).fadeIn(),
          const SizedBox(height: AppDimensions.space2XL),
          _DropField(label: 'Country', value: country, items: _countries, onChanged: onCountryChanged, delay: 100),
          const SizedBox(height: AppDimensions.spaceLG),
          _DropField(label: 'City', value: city, items: _cities, onChanged: onCityChanged, delay: 130),
          const SizedBox(height: AppDimensions.spaceLG),
          Text('Street address', style: AppTextStyles.labelMD)
              .animate(delay: 160.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceSM),
          TextFormField(
            controller: addressCtrl,
            decoration: InputDecoration(
              hintText: 'e.g. 12 Adeola Odeku Street, Victoria Island',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          ).animate(delay: 180.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceLG),
          Row(
            children: [
              Text('Landmark directions', style: AppTextStyles.labelMD),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text('Important', style: AppTextStyles.bodyXS.copyWith(color: Colors.white)),
              ),
            ],
          ).animate(delay: 210.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceSM),
          TextFormField(
            controller: landmarkCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'e.g. Opposite GTBank on Adeola Odeku. Take the second left after the Total petrol station. Look for the cream building with black iron gates.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          ).animate(delay: 230.ms).fadeIn(),
          const SizedBox(height: AppDimensions.space2XL),
          AppButton(label: 'Next', onPressed: onNext).animate(delay: 260.ms).fadeIn(),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _DropField extends StatelessWidget {
  const _DropField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.delay,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMD),
        const SizedBox(height: AppDimensions.spaceSM),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ],
    ).animate(delay: Duration(milliseconds: delay)).fadeIn();
  }
}

// ── Step 4: Utilities ──────────────────────────────────────────────────────

class _Step4Utilities extends StatelessWidget {
  const _Step4Utilities({
    required this.powerType,
    required this.hasWifi, required this.hasAC,
    required this.hasWater, required this.hasParking,
    required this.hasSecurity, required this.hasPool,
    required this.onPowerTypeChanged,
    required this.onToggle,
    required this.onNext,
  });

  final String powerType;
  final bool hasWifi, hasAC, hasWater, hasParking, hasSecurity, hasPool;
  final ValueChanged<String> onPowerTypeChanged;
  final void Function(String key, bool val) onToggle;
  final VoidCallback onNext;

  static const _powerTypes = ['24/7 Grid', 'Solar Backup', 'Generator Backup', 'No Backup'];

  @override
  Widget build(BuildContext context) {
    final amenities = [
      (key: 'wifi',     label: 'High-Speed WiFi',    icon: Icons.wifi_rounded,           value: hasWifi),
      (key: 'ac',       label: 'Air Conditioning',    icon: Icons.ac_unit_rounded,         value: hasAC),
      (key: 'water',    label: '24/7 Water Supply',   icon: Icons.water_drop_rounded,      value: hasWater),
      (key: 'parking',  label: 'Parking',             icon: Icons.local_parking_rounded,   value: hasParking),
      (key: 'security', label: 'CCTV / Security',     icon: Icons.security_rounded,        value: hasSecurity),
      (key: 'pool',     label: 'Swimming Pool',       icon: Icons.pool_rounded,            value: hasPool),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Utilities & verification', style: AppTextStyles.h2)
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Guests rely on these claims. Only tick what is actually available.',
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
          ).animate(delay: 80.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceXXL),
          Text('Power backup type', style: AppTextStyles.labelMD)
              .animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceSM),
          Wrap(
            spacing: AppDimensions.spaceSM,
            runSpacing: AppDimensions.spaceSM,
            children: _powerTypes.map((t) {
              final sel = powerType == t;
              return GestureDetector(
                onTap: () => onPowerTypeChanged(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(t, style: AppTextStyles.labelSM.copyWith(
                      color: sel ? Colors.white : AppColors.textPrimary)),
                ),
              );
            }).toList(),
          ).animate(delay: 120.ms).fadeIn(),
          const SizedBox(height: AppDimensions.space2XL),
          Text('Amenities', style: AppTextStyles.labelMD)
              .animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceMD),
          ...amenities.asMap().entries.map((e) {
            final item = e.value;
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(item.icon, color: AppColors.textSecondary),
              title: Text(item.label, style: AppTextStyles.bodyLG),
              value: item.value,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => onToggle(item.key, v),
            ).animate(delay: Duration(milliseconds: 170 + e.key * 40)).fadeIn();
          }),
          const SizedBox(height: AppDimensions.space2XL),
          AppButton(label: 'Next', onPressed: onNext)
              .animate(delay: 400.ms).fadeIn(),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ── Step 5: Photos ─────────────────────────────────────────────────────────

class _Step5Photos extends StatelessWidget {
  const _Step5Photos({
    required this.photoCount,
    required this.onAddPhoto,
    required this.onNext,
  });

  final int photoCount;
  final VoidCallback onAddPhoto;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add photos', style: AppTextStyles.h2)
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Add at least 5 high-quality photos. Good photos increase bookings by 3×.',
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
          ).animate(delay: 80.ms).fadeIn(),
          const SizedBox(height: AppDimensions.space2XL),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                ...List.generate(photoCount, (i) => _PhotoTile(index: i)),
                GestureDetector(
                  onTap: onAddPhoto,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_rounded,
                            size: 32, color: AppColors.primary),
                        const SizedBox(height: 4),
                        Text('Add', style: AppTextStyles.bodyXS
                            .copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (photoCount < 5)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
              child: Text(
                '${5 - photoCount} more photo${5 - photoCount == 1 ? "" : "s"} required',
                style: AppTextStyles.bodyXS.copyWith(color: AppColors.warning),
              ),
            ),
          AppButton(
            label: 'Next',
            isDisabled: photoCount < 1,
            onPressed: photoCount >= 1 ? onNext : null,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.index});
  final int index;

  static const _colors = [
    Color(0xFFB2DFDB), Color(0xFFB3E5FC), Color(0xFFC8E6C9),
    Color(0xFFFFF9C4), Color(0xFFFFCCBC), Color(0xFFE1BEE7),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _colors[index % _colors.length],
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: const Icon(Icons.image_rounded, color: Colors.white54, size: 32),
    );
  }
}

// ── Step 6: Pricing ────────────────────────────────────────────────────────

class _Step6Pricing extends StatelessWidget {
  const _Step6Pricing({
    required this.priceUSDCtrl,
    required this.priceLocalCtrl,
    required this.localCurrency,
    required this.onCurrencyChanged,
    required this.onSubmit,
  });

  final TextEditingController priceUSDCtrl, priceLocalCtrl;
  final String localCurrency;
  final ValueChanged<String> onCurrencyChanged;
  final VoidCallback onSubmit;

  static const _currencies = [
    (code: 'GHS', label: '₵ Ghana Cedi'),
    (code: 'NGN', label: '₦ Nigerian Naira'),
    (code: 'XOF', label: 'CFA West African CFA'),
    (code: 'USD', label: '\$ US Dollar'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set your price', style: AppTextStyles.h2)
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Set a price in USD for international travellers, and optionally in local currency for local guests.',
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
          ).animate(delay: 80.ms).fadeIn(),
          const SizedBox(height: AppDimensions.space2XL),
          Text('Price per night (USD)', style: AppTextStyles.labelMD)
              .animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceSM),
          TextFormField(
            controller: priceUSDCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '\$  ',
              hintText: 'e.g. 75',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          ).animate(delay: 120.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceXXL),
          Text('Local currency (optional)', style: AppTextStyles.labelMD)
              .animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spaceSM),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: localCurrency,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  items: _currencies.map((c) => DropdownMenuItem(
                    value: c.code,
                    child: Text(c.label, style: AppTextStyles.bodyMD),
                  )).toList(),
                  onChanged: (v) { if (v != null) onCurrencyChanged(v); },
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: priceLocalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                  ),
                ),
              ),
            ],
          ).animate(delay: 170.ms).fadeIn(),
          const SizedBox(height: AppDimensions.space2XL),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceLG),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.primaryDark),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: Text(
                    'A 10% platform fee applies to each booking. Payouts are processed 24–48 hours after guest check-in.',
                    style: AppTextStyles.bodyXS.copyWith(color: AppColors.primaryDark, height: 1.5),
                  ),
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: AppDimensions.space3XL),
          AppButton(
            label: 'Submit listing',
            onPressed: onSubmit,
          ).animate(delay: 240.ms).fadeIn(),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

// ── Success Dialog ─────────────────────────────────────────────────────────

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppDimensions.spaceLG),
          const Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppDimensions.spaceLG),
          Text('Listing Submitted!', style: AppTextStyles.h2,
              textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Your listing is under review. Our team will physically visit and verify the property within 48 hours.',
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space2XL),
          AppButton(
            label: 'Go to Dashboard',
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.hostDashboard);
            },
          ),
          const SizedBox(height: AppDimensions.spaceMD),
        ],
      ),
    );
  }
}
