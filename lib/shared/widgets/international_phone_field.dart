import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

class InternationalPhoneField extends StatefulWidget {
  const InternationalPhoneField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.initialCountryCode,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? initialCountryCode;

  @override
  InternationalPhoneFieldState createState() => InternationalPhoneFieldState();
}

class InternationalPhoneFieldState extends State<InternationalPhoneField> {
  CountryCode? _selectedCountry;
  final List<CountryCode> _countries = [
    const CountryCode(
      name: 'Pakistan',
      code: 'PK',
      dialCode: '+92',
      flag: '🇵🇰',
    ),
    const CountryCode(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
    const CountryCode(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
      flag: '🇺🇸',
    ),
    const CountryCode(
      name: 'United Kingdom',
      code: 'GB',
      dialCode: '+44',
      flag: '🇬🇧',
    ),
    const CountryCode(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    const CountryCode(
      name: 'Australia',
      code: 'AU',
      dialCode: '+61',
      flag: '🇦🇺',
    ),
    const CountryCode(
      name: 'Bangladesh',
      code: 'BD',
      dialCode: '+880',
      flag: '🇧🇩',
    ),
    const CountryCode(
      name: 'Saudi Arabia',
      code: 'SA',
      dialCode: '+966',
      flag: '🇸🇦',
    ),
    const CountryCode(
      name: 'United Arab Emirates',
      code: 'AE',
      dialCode: '+971',
      flag: '🇦🇪',
    ),
    const CountryCode(
      name: 'Qatar',
      code: 'QA',
      dialCode: '+974',
      flag: '🇶🇦',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Set initial country based on initialCountryCode or default to Pakistan
    _selectedCountry = widget.initialCountryCode != null
        ? _countries.firstWhere(
            (c) => c.code == widget.initialCountryCode,
            orElse: () => _countries[0],
          )
        : _countries[0];

    // If controller has existing value, try to extract country code
    if (widget.controller.text.isNotEmpty) {
      _extractCountryFromText(widget.controller.text);
    }
  }

  void _extractCountryFromText(String text) {
    for (final country in _countries) {
      if (text.startsWith(country.dialCode)) {
        setState(() {
          _selectedCountry = country;
          // Remove dial code from controller if it exists
          if (widget.controller.text.startsWith(country.dialCode)) {
            widget.controller.text = text
                .substring(country.dialCode.length)
                .trim();
          }
        });
        break;
      }
    }
  }

  String get _fullPhoneNumber {
    final phoneNumber = widget.controller.text.trim();
    if (phoneNumber.isEmpty) return '';
    return '${_selectedCountry?.dialCode} $phoneNumber';
  }

  /// Public getter to get the full phone number with country code
  String get fullPhoneNumber {
    final phoneNumber = widget.controller.text.trim();
    if (phoneNumber.isEmpty) return '';
    return '${_selectedCountry?.dialCode} $phoneNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyles.bodyRegular.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
        ],
        Row(
          children: [
            // Country selector dropdown
            InkWell(
              onTap: () => _showCountryPicker(context),
              borderRadius: BorderRadius.circular(AppSizes.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.md,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.dark.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry?.flag ?? '🇵🇰',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      _selectedCountry?.dialCode ?? '+92',
                      style: AppTextStyles.bodyRegular,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: AppColors.dark,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            // Phone number input
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: widget.hintText ?? '1234567890',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                    borderSide: BorderSide(
                      color: AppColors.dark.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                    borderSide: BorderSide(
                      color: AppColors.dark.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.md,
                  ),
                ),
                style: AppTextStyles.bodyRegular,
                validator: (value) {
                  if (widget.validator != null) {
                    // Pass full phone number with country code for validation
                    return widget.validator!(_fullPhoneNumber);
                  }
                  // Default validation: minimum 10 digits
                  final phoneNumber = value?.trim() ?? '';
                  if (phoneNumber.isEmpty) {
                    return 'Phone number is required';
                  }
                  if (phoneNumber.length < 10) {
                    return 'Phone number must be at least 10 digits';
                  }
                  return null;
                },
                onChanged: (value) {
                  widget.onChanged?.call(_fullPhoneNumber);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Country', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSizes.lg),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  final isSelected = country.code == _selectedCountry?.code;
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(country.name),
                    subtitle: Text(country.dialCode),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedCountry = country;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getFullPhoneNumber() {
    return _fullPhoneNumber;
  }

  CountryCode? get selectedCountry => _selectedCountry;
}
