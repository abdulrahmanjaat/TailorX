import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../models/customer.dart';
import '../../models/measurement_model.dart';
import '../../providers/language_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_spacing.dart';
import '../coat_measurement_screen.dart';
import '../kameez_shalwar_screen.dart';
import '../measurement_detail_screen.dart';
import '../sherwani_measurement_screen.dart';
import '../shirt_measurement_screen.dart';
import '../waistcoat_measurement_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _BlockingLoader extends StatelessWidget {
  const _BlockingLoader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.2),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
        ),
      ),
    );
  }
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showEditCustomerSheet(
    BuildContext parentContext,
    Customer customer,
    LanguageProvider languageProvider,
  ) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final addressController = TextEditingController(text: customer.address);
    final isUrdu = languageProvider.isUrdu;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final viewInsets = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.lg,
            bottom: viewInsets + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUrdu ? 'گاہک میں ترمیم کریں' : 'Edit customer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: isUrdu ? 'نام' : 'Name',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: isUrdu ? 'فون نمبر' : 'Phone number',
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: isUrdu ? 'پتہ' : 'Address',
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () async {
                    setState(() => _isSaving = true);
                    final firestoreService = FirestoreService();
                    final phoneExists = await firestoreService.phoneExists(
                      phoneController.text.trim(),
                      excludeCustomerId: customer.id,
                    );
                    if (phoneExists) {
                      if (!mounted || !parentContext.mounted) return;
                      setState(() => _isSaving = false);
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            isUrdu
                                ? 'یہ فون نمبر پہلے سے موجود ہے'
                                : 'This phone number already exists.',
                          ),
                          backgroundColor:
                              Theme.of(parentContext).colorScheme.error,
                        ),
                      );
                      return;
                    }
                    final updatedCustomer = customer.copyWith(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      address: addressController.text.trim(),
                    );
                    await firestoreService.addCustomer(updatedCustomer);
                    if (!mounted || !parentContext.mounted) return;
                    setState(() => _isSaving = false);
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          isUrdu ? 'گاہک اپ ڈیٹ ہوگیا' : 'Customer updated',
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Center(child: Text(isUrdu ? 'محفوظ کریں' : 'Save')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final String? customerId = switch (args) {
      final String id => id,
      final Map<String, dynamic> data => data['customerId'] as String?,
      _ => null,
    };
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isUrdu = languageProvider.isUrdu;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxContentWidth = AppSpacing.responsiveMaxWidth(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 720;
    final horizontalPadding = isTablet ? AppSpacing.xl : AppSpacing.md;
    final bodyPadding = EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: AppSpacing.sm,
    );
    if (customerId != null) {
      return _buildExistingCustomerView(
        customerId: customerId,
        languageProvider: languageProvider,
        isUrdu: isUrdu,
        bodyPadding: bodyPadding,
        horizontalPadding: horizontalPadding,
        maxContentWidth: maxContentWidth,
        colorScheme: colorScheme,
        theme: theme,
      );
    }

    return _buildNewCustomerForm(
      isUrdu: isUrdu,
      bodyPadding: bodyPadding,
      maxContentWidth: maxContentWidth,
      colorScheme: colorScheme,
      theme: theme,
    );
  }

  Widget _buildExistingCustomerView({
    required String customerId,
    required LanguageProvider languageProvider,
    required bool isUrdu,
    required EdgeInsets bodyPadding,
    required double horizontalPadding,
    required double maxContentWidth,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return StreamBuilder<Customer>(
      stream: FirestoreService().getCustomerById(customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(
                isUrdu ? 'گاہک لوڈ کرنے میں مسئلہ' : 'Unable to load customer',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final customer = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(isUrdu ? 'گاہک کی تفصیل' : 'Customer Detail'),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: colorScheme.secondaryContainer,
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color:
                                                colorScheme
                                                    .onSecondaryContainer,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      customer.phone,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme
                                                .onSecondaryContainer
                                                .withValues(alpha: 0.7),
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: colorScheme.secondary,
                                ),
                                onPressed:
                                    () => _showEditCustomerSheet(
                                      context,
                                      customer,
                                      languageProvider,
                                    ),
                                tooltip: isUrdu ? 'ترمیم کریں' : 'Edit',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: colorScheme.error,
                                ),
                                onPressed:
                                    () =>
                                        _handleDeleteCustomer(customer, isUrdu),
                                tooltip: isUrdu ? 'حذف کریں' : 'Delete',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: bodyPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  isUrdu
                                      ? 'محفوظ شدہ پیمائشیں'
                                      : 'Saved measurements',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Expanded(
                                  child: StreamBuilder<List<Measurement>>(
                                    stream: FirestoreService().getMeasurements(
                                      customer.id,
                                    ),
                                    builder: (context, measurementSnapshot) {
                                      if (measurementSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (measurementSnapshot.hasError) {
                                        return Center(
                                          child: Text(
                                            isUrdu
                                                ? 'پیمائشیں لوڈ کرنے میں مسئلہ'
                                                : 'Unable to load measurements',
                                          ),
                                        );
                                      }
                                      final measurements =
                                          measurementSnapshot.data ?? [];
                                      final savedGarments =
                                          measurements
                                              .map((m) => m.garmentType)
                                              .toSet();

                                      return Column(
                                        children: [
                                          Expanded(
                                            child:
                                                measurements.isEmpty
                                                    ? Center(
                                                      child: Text(
                                                        isUrdu
                                                            ? 'کوئی پیمائش نہیں ملی'
                                                            : 'No measurements yet',
                                                        style:
                                                            theme
                                                                .textTheme
                                                                .bodyLarge,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )
                                                    : ListView.separated(
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      padding: EdgeInsets.zero,
                                                      itemCount:
                                                          measurements.length,
                                                      separatorBuilder:
                                                          (_, _) => SizedBox(
                                                            height:
                                                                AppSpacing.sm,
                                                          ),
                                                      itemBuilder: (
                                                        context,
                                                        index,
                                                      ) {
                                                        final measurement =
                                                            measurements[index];
                                                        return Card(
                                                          margin:
                                                              EdgeInsets.zero,
                                                          child: ListTile(
                                                            title: Text(
                                                              languageProvider
                                                                  .getTranslation(
                                                                    'garments',
                                                                    measurement
                                                                        .garmentType,
                                                                  ),
                                                              style: theme
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                            ),
                                                            subtitle: Text(
                                                              '${isUrdu ? 'تاریخ' : 'Date'}: '
                                                              '${_formatDate(measurement.createdAt)}',
                                                            ),
                                                            trailing: Icon(
                                                              Icons
                                                                  .chevron_right,
                                                              color:
                                                                  colorScheme
                                                                      .secondary,
                                                            ),
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        _,
                                                                      ) => MeasurementDetailScreen(
                                                                        measurement:
                                                                            measurement,
                                                                      ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ),
                                          ),
                                          SizedBox(height: AppSpacing.md),
                                          FilledButton.icon(
                                            icon: const Icon(Icons.add),
                                            onPressed:
                                                savedGarments.length ==
                                                        _supportedGarments
                                                            .length
                                                    ? null
                                                    : () => _showGarmentChooser(
                                                      customer: customer,
                                                      languageProvider:
                                                          languageProvider,
                                                      savedGarments:
                                                          savedGarments,
                                                    ),
                                            label: Text(
                                              isUrdu
                                                  ? 'نئی پیمائش شامل کریں'
                                                  : 'Add new measurement',
                                            ),
                                          ),
                                          SizedBox(height: AppSpacing.lg),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isSaving) const _BlockingLoader(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewCustomerForm({
    required bool isUrdu,
    required EdgeInsets bodyPadding,
    required double maxContentWidth,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'گاہک کی معلومات' : 'Customer Information'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: bodyPadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUrdu ? 'گاہک کی معلومات' : 'Customer Information',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        _buildLabeledField(
                          controller: _nameController,
                          label: isUrdu ? 'نام' : 'Name',
                          hint: isUrdu ? 'نام درج کریں' : 'Enter full name',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return isUrdu
                                  ? 'نام ضروری ہے'
                                  : 'Name is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSpacing.md),
                        _buildLabeledField(
                          controller: _phoneController,
                          label: isUrdu ? 'فون نمبر' : 'Phone Number',
                          hint:
                              isUrdu
                                  ? 'فون نمبر درج کریں'
                                  : 'Enter phone number',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return isUrdu
                                  ? 'فون نمبر ضروری ہے'
                                  : 'Phone number is required';
                            }
                            if (value.trim().length < 6) {
                              return isUrdu
                                  ? 'درست فون نمبر درج کریں'
                                  : 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSpacing.md),
                        _buildLabeledField(
                          controller: _addressController,
                          label: isUrdu ? 'پتہ' : 'Address',
                          hint: isUrdu ? 'پتہ درج کریں' : 'Enter address',
                          maxLines: 2,
                          textInputAction: TextInputAction.newline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return isUrdu
                                  ? 'پتہ ضروری ہے'
                                  : 'Address is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: _saveCustomerAndProceed,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Center(
                              child: Text(
                                isUrdu ? 'آگے بڑھیں' : 'Continue',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isSaving) const _BlockingLoader(),
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isMultilineField =
        maxLines > 1 || keyboardType == TextInputType.multiline;
    final effectiveKeyboardType =
        isMultilineField ? TextInputType.multiline : keyboardType;
    final effectiveTextInputAction =
        isMultilineField ? TextInputAction.newline : textInputAction;

    return TextFormField(
      controller: controller,
      keyboardType: effectiveKeyboardType,
      textInputAction: effectiveTextInputAction,
      maxLines: maxLines,
      textCapitalization:
          effectiveKeyboardType == TextInputType.name
              ? TextCapitalization.words
              : effectiveKeyboardType == TextInputType.phone
              ? TextCapitalization.none
              : TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
    );
  }

  Future<void> _handleDeleteCustomer(Customer customer, bool isUrdu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(isUrdu ? 'تصدیق کریں' : 'Confirm'),
            content: Text(
              isUrdu
                  ? 'کیا آپ واقعی اس گاہک اور تمام پیمائشیں حذف کرنا چاہتے ہیں؟'
                  : 'Are you sure you want to delete this customer and all measurements?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(isUrdu ? 'نہیں' : 'No'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(isUrdu ? 'ہاں' : 'Yes'),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      await FirestoreService().deleteCustomer(customer.userId, customer.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isUrdu ? 'گاہک حذف ہوگیا' : 'Customer deleted'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUrdu ? 'گاہک حذف نہ ہوسکا' : 'Failed to delete customer',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showGarmentChooser({
    required Customer customer,
    required LanguageProvider languageProvider,
    required Set<String> savedGarments,
  }) async {
    final availableGarments =
        _supportedGarments
            .where((garment) => !savedGarments.contains(garment))
            .toList();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final isUrdu = languageProvider.isUrdu;
        final viewInsets = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.lg,
            bottom: viewInsets + AppSpacing.lg,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUrdu ? 'لباس منتخب کریں' : 'Select garment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  if (availableGarments.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        isUrdu
                            ? 'تمام پیمائشیں پہلے ہی محفوظ ہیں'
                            : 'All measurements are already saved.',
                      ),
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children:
                          availableGarments.map((garment) {
                            return FilledButton.tonal(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                _navigateToMeasurement(
                                  garmentType: garment,
                                  customer: customer,
                                );
                              },
                              child: Text(
                                languageProvider.getTranslation(
                                  'garments',
                                  garment,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToMeasurement({
    required String garmentType,
    required Customer customer,
  }) {
    final Widget? screen = switch (garmentType) {
      'sherwani' => const SherwaniMeasurementScreen(),
      'waistcoat' => const WaistcoatMeasurementScreen(),
      'shirt' => const ShirtMeasurementScreen(),
      'kameez_shalwar' => const KameezShalwarMeasurementScreen(),
      'coat_pent' => const CoatMeasurementScreen(),
      _ => null,
    };
    if (screen == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
        settings: RouteSettings(
          arguments: {'customerId': customer.id, 'userId': customer.userId},
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => _dateFormat.format(date.toLocal());

  static const List<String> _supportedGarments = [
    'sherwani',
    'waistcoat',
    'shirt',
    'kameez_shalwar',
    'coat_pent',
  ];

  static final DateFormat _dateFormat = DateFormat.yMMMd();

  Future<void> _saveCustomerAndProceed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final languageProvider = context.read<LanguageProvider>();
    final isUrdu = languageProvider.isUrdu;
    final colorScheme = Theme.of(context).colorScheme;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError(isUrdu ? 'صارف لاگ ان نہیں ہے' : 'User not logged in');
      }
      final firestoreService = FirestoreService();
      final phoneExists = await firestoreService.phoneExists(
        _phoneController.text.trim(),
      );
      if (phoneExists) {
        throw StateError(
          isUrdu
              ? 'یہ فون نمبر پہلے سے موجود ہے'
              : 'This phone number already exists.',
        );
      }

      final customerId = 'cust_${DateTime.now().millisecondsSinceEpoch}';
      final customer = Customer(
        id: customerId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        measurements: const [],
        createdAt: DateTime.now(),
        userId: user.uid,
      );
      await firestoreService.addCustomer(customer);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/garment-selection',
        arguments: {'customerId': customerId, 'userId': user.uid},
      );
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: colorScheme.error,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUrdu ? 'گاہک محفوظ نہیں ہو سکا' : 'Unable to save customer',
          ),
          backgroundColor: colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
