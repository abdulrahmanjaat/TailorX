// garment_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../utils/app_spacing.dart';

class GarmentSelectionScreen extends StatefulWidget {
  const GarmentSelectionScreen({super.key});

  @override
  State<GarmentSelectionScreen> createState() => _GarmentSelectionScreenState();
}

class _GarmentSelectionScreenState extends State<GarmentSelectionScreen> {
  String? _selectedGarmentId;

  static const List<Map<String, String>> garments = [
    {
      'id': 'shirt',
      'english': 'Shirt',
      'urdu': 'قمیض',
      'icon': 'lib/assets/images/icons/shirt.png',
    },
    {
      'id': 'sherwani',
      'english': 'Sherwani',
      'urdu': 'شیروانی',
      'icon': 'lib/assets/images/icons/sherwani.png',
    },
    {
      'id': 'waistcoat',
      'english': 'Waistcoat',
      'urdu': 'ویسٹ کوٹ',
      'icon': 'lib/assets/images/icons/waiscoat.png',
    },
    {
      'id': 'coat_pent',
      'english': 'Coat Pant',
      'urdu': 'کوٹ پینٹ',
      'icon': 'lib/assets/images/icons/suit_icon.png',
    },
    {
      'id': 'kameez_shalwar',
      'english': 'Kameez Shalwar',
      'urdu': 'قمیض شلوار',
      'icon': 'lib/assets/images/icons/kurta.png',
    },
  ];

  void _continue(BuildContext context, String? customerId, String? userId) {
    if (_selectedGarmentId == null) return;
    String route = '';
    switch (_selectedGarmentId) {
      case 'shirt':
        route = '/shirt-measurement';
        break;
      case 'sherwani':
        route = '/sherwani-measurement';
        break;
      case 'waistcoat':
        route = '/waistcoat-measurement';
        break;
      case 'coat_pent':
        route = '/coat-measurement';
        break;
      case 'kameez_shalwar':
        route = '/kameez-shalwar-measurement';
        break;
      default:
        return;
    }
    Navigator.pushNamed(
      context,
      route,
      arguments: {'customerId': customerId, 'userId': userId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final customerId =
        args is Map<String, dynamic> ? args['customerId'] as String? : null;
    final userId =
        args is Map<String, dynamic> ? args['userId'] as String? : null;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isUrdu = languageProvider.isUrdu;
    final colorScheme = Theme.of(context).colorScheme;
    final maxContentWidth = AppSpacing.responsiveMaxWidth(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 720;
    final horizontalPadding = isTablet ? AppSpacing.lg : AppSpacing.md;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'کپڑے کی قسم منتخب کریں' : 'Select garment type'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          constraints.maxWidth >= 1000
                              ? 4
                              : constraints.maxWidth >= 720
                              ? 3
                              : 2;
                      final gridPadding =
                          constraints.maxWidth >= 720
                              ? AppSpacing.lg
                              : AppSpacing.md;
                      return Padding(
                        padding: EdgeInsets.all(gridPadding),
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: garments.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                                childAspectRatio: 0.9,
                              ),
                          itemBuilder: (context, index) {
                            final garment = garments[index];
                            final isSelected =
                                _selectedGarmentId == garment['id'];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedGarmentId = garment['id'];
                                });
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? colorScheme.secondary
                                            : colorScheme.outlineVariant,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.secondary.withValues(
                                        alpha: isSelected ? 0.25 : 0.1,
                                      ),
                                      blurRadius: isSelected ? 18 : 8,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Image.asset(
                                        garment['icon']!,
                                        width: 80,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    Text(
                                      garment['english']!,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      garment['urdu']!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'NotoNastaliqUrdu',
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    AppSpacing.md,
                  ),
                  child: FilledButton(
                    onPressed:
                        _selectedGarmentId == null
                            ? null
                            : () => _continue(context, customerId, userId),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(
                        isUrdu ? 'آگے بڑھیں' : 'Continue',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
