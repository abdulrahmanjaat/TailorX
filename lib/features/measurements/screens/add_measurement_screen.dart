import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../customers/controllers/customers_controller.dart';
import '../controllers/measurements_controller.dart';
import '../models/measurement_model.dart';
import '../widgets/gender_selector.dart';
import '../widgets/measurement_field.dart';
import '../widgets/measurement_group_card.dart';

class AddMeasurementScreen extends ConsumerStatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  ConsumerState<AddMeasurementScreen> createState() =>
      _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends ConsumerState<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _customOrderTypeController = TextEditingController();

  late final Map<String, TextEditingController> _controllers;

  String? _selectedCustomerId;
  MeasurementGender _gender = MeasurementGender.male; // Default to Male
  String? _selectedOrderType;

  // Male order types
  static const _maleOrderTypes = [
    'Shalwar Kameez',
    'Kurta',
    'Waistcoat',
    'Pant Coat',
    'Pajama Suit',
    'Sherwani',
    'Kameez Shalwar',
    'Custom',
  ];

  // Female order types
  static const _femaleOrderTypes = [
    '2-Piece Suit',
    '3-Piece Suit',
    'Kameez Shalwar',
    'Frock',
    'Maxi',
    'Abaya',
    'Trouser Shirt',
    'Lehenga',
    'Custom',
  ];

  // Male fields
  static const _maleFields = [
    'chest',
    'shoulder',
    'sleeve',
    'neck',
    'arm',
    'bicep',
    'wrist',
    'shirtLength',
    'waist',
    'hip',
    'thigh',
    'knee',
    'calf',
    'ankle',
    'pantLength',
    'forkLength',
    'bottom',
    'backWidth',
    'frontLength',
    'belly',
    'height',
    'weight',
  ];

  // Female fields
  static const _femaleFields = [
    'bust',
    'waist',
    'hip',
    'shoulder',
    'armhole',
    'sleeve',
    'neck',
    'kameezLength',
    'trouserLength',
    'wrist',
    'bottom',
    'backWidth',
    'frontLength',
    'belly',
    'height',
    'weight',
  ];

  List<String> get _currentOrderTypes {
    return _gender == MeasurementGender.male
        ? _maleOrderTypes
        : _femaleOrderTypes;
  }

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _initializeControllers(
      _maleFields,
    ); // Initialize with male fields by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadParamsFromRoute();
    });
  }

  bool _customerFromRoute = false;
  String? _editingMeasurementId;

  void _loadParamsFromRoute() {
    final uri = GoRouterState.of(context).uri;
    final params = uri.queryParameters;

    if (params.containsKey('customerId')) {
      setState(() {
        _selectedCustomerId = params['customerId'];
        _customerFromRoute = true;
      });
    }

    // Load measurement for editing
    if (params.containsKey('measurementId')) {
      _editingMeasurementId = params['measurementId'];
      final measurementsAsync = ref.read(measurementsProvider);
      final measurements = measurementsAsync.value ?? [];
      try {
        final measurement = measurements.firstWhere(
          (m) => m.id == _editingMeasurementId,
        );
        setState(() {
          _selectedCustomerId = measurement.customerId;
          _customerFromRoute = true;
          _gender = measurement.gender;
          _selectedOrderType = measurement.orderType == 'Custom'
              ? 'Custom'
              : measurement.orderType;
          // Prefill controllers with measurement values
          measurement.values.forEach((key, value) {
            if (_controllers.containsKey(key)) {
              _controllers[key]!.text = value.toString();
            }
          });
          if (measurement.notes != null) {
            _notesController.text = measurement.notes!;
          }
        });
      } catch (_) {
        // Measurement not found
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _notesController.dispose();
    _customOrderTypeController.dispose();
    super.dispose();
  }

  void _initializeControllers(List<String> fields) {
    for (final key in fields) {
      if (!_controllers.containsKey(key)) {
        _controllers[key] = TextEditingController();
      }
    }
  }

  List<String> get _currentFields {
    return _gender == MeasurementGender.male ? _maleFields : _femaleFields;
  }

  Future<void> _saveMeasurement() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCustomerId == null) {
      SnackbarService.showInfo(context, message: 'Select customer');
      return;
    }
    if (_selectedOrderType == null) {
      SnackbarService.showInfo(context, message: 'Select order type');
      return;
    }

    // If Custom is selected, validate and use the custom text
    String orderType;
    if (_selectedOrderType == 'Custom') {
      final customType = _customOrderTypeController.text.trim();
      if (customType.isEmpty) {
        SnackbarService.showInfo(context, message: 'Enter custom order type');
        return;
      }
      orderType = customType;
    } else {
      orderType = _selectedOrderType!;
    }

    final customersAsync = ref.read(customersProvider);
    final customers = customersAsync.value ?? [];
    final customer = customers.firstWhere(
      (c) => c.id == _selectedCustomerId,
      orElse: () {
        throw Exception('Customer not found. Please select a valid customer.');
      },
    );

    final values = <String, double>{};
    _controllers.forEach((key, controller) {
      final value = double.tryParse(controller.text.trim());
      if (value != null) {
        values[key] = value;
      }
    });

    final measurement = MeasurementModel(
      id: 'mea-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customer.id,
      customerName: customer.name,
      gender: _gender,
      orderType: orderType,
      values: values,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    if (_editingMeasurementId != null) {
      // Update existing measurement
      final measurementsAsync = ref.read(measurementsProvider);
      final measurements = measurementsAsync.value ?? [];
      final existingMeasurement = measurements.firstWhere(
        (m) => m.id == _editingMeasurementId,
      );

      final updatedMeasurement = existingMeasurement.copyWith(
        gender: _gender,
        orderType: orderType,
        values: values,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await ref
          .read(measurementsProvider.notifier)
          .updateMeasurement(updatedMeasurement);
      if (mounted) {
        SnackbarService.showSuccess(context, message: 'Measurement updated');
        context.pop();
      }
    } else {
      // Add new measurement
      await ref.read(measurementsProvider.notifier).addMeasurement(measurement);
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          message: 'Measurement saved successfully',
        );
        // Redirect to Add Order Screen with measurement data
        context.pushReplacement(
          '${AppRoutes.addOrder}?customerId=${customer.id}&customerName=${Uri.encodeComponent(customer.name)}&phone=${Uri.encodeComponent(customer.phone)}&gender=${_gender.name}&orderType=${Uri.encodeComponent(orderType)}&measurementId=${measurement.id}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final customers = customersAsync.value ?? [];

    // Ensure controllers are initialized for current fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeControllers(_currentFields);
      }
    });

    return AppScaffold(
      title: _editingMeasurementId != null
          ? 'Edit Measurement'
          : 'Add Measurement',
      padding: const EdgeInsets.all(AppSizes.lg),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_customerFromRoute && _selectedCustomerId != null)
                Builder(
                  builder: (context) {
                    final customer =
                        customers
                            .where((c) => c.id == _selectedCustomerId)
                            .isNotEmpty
                        ? customers.firstWhere(
                            (c) => c.id == _selectedCustomerId,
                          )
                        : null;
                    return CustomCard(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.primary),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer', style: AppTextStyles.caption),
                                Text(
                                  customer?.name ?? 'Customer not found',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedCustomerId,
                  items: customers
                      .map(
                        (customer) => DropdownMenuItem(
                          value: customer.id,
                          child: Text(customer.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCustomerId = value),
                  decoration: const InputDecoration(
                    labelText: 'Select Customer',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      value == null ? 'Customer required' : null,
                ),
              const SizedBox(height: AppSizes.lg),
              Text('Gender', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSizes.sm),
              GenderSelector(
                value: _gender,
                onChanged: (gender) {
                  setState(() {
                    _gender = gender;
                    _selectedOrderType =
                        null; // Reset order type when gender changes
                    // Dispose old controllers
                    for (final controller in _controllers.values) {
                      controller.dispose();
                    }
                    // Re-initialize controllers for new gender fields
                    _controllers.clear();
                    _initializeControllers(_currentFields);
                  });
                },
              ),
              const SizedBox(height: AppSizes.lg),
              DropdownButtonFormField<String>(
                initialValue: _selectedOrderType,
                items: _currentOrderTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedOrderType = value),
                decoration: const InputDecoration(
                  labelText: 'Order Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (value) =>
                    value == null ? 'Order type required' : null,
              ),
              if (_selectedOrderType == 'Custom') ...[
                const SizedBox(height: AppSizes.md),
                AppInputField(
                  controller: _customOrderTypeController,
                  labelText: 'Enter Custom Order Type',
                  hintText: 'Type your order type',
                  prefix: const Icon(Icons.edit_outlined),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Enter custom order type' : null,
                ),
              ],
              const SizedBox(height: AppSizes.lg),
              MeasurementGroupCard(
                title: 'Upper Body',
                children: _currentFields
                    .take(_gender == MeasurementGender.male ? 8 : 7)
                    .map((key) {
                      if (!_controllers.containsKey(key)) {
                        _controllers[key] = TextEditingController();
                      }
                      return MeasurementField(
                        label: _label(key),
                        controller: _controllers[key]!,
                      );
                    })
                    .toList(),
              ),
              const SizedBox(height: AppSizes.lg),
              MeasurementGroupCard(
                title: 'Lower Body',
                children: _currentFields
                    .skip(_gender == MeasurementGender.male ? 8 : 7)
                    .take(_gender == MeasurementGender.male ? 9 : 7)
                    .map((key) {
                      if (!_controllers.containsKey(key)) {
                        _controllers[key] = TextEditingController();
                      }
                      return MeasurementField(
                        label: _label(key),
                        controller: _controllers[key]!,
                      );
                    })
                    .toList(),
              ),
              if (_currentFields.length >
                  (_gender == MeasurementGender.male ? 17 : 14)) ...[
                const SizedBox(height: AppSizes.lg),
                MeasurementGroupCard(
                  title: 'Additional',
                  children: _currentFields
                      .skip(_gender == MeasurementGender.male ? 17 : 14)
                      .map(
                        (key) => MeasurementField(
                          label: _label(key),
                          controller: _controllers[key]!,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: AppSizes.lg),
              AppInputField(
                controller: _notesController,
                labelText: 'Notes',
                hintText: 'Add special instructions',
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.xl),
              Center(
                child: AppButton(
                  label: _editingMeasurementId != null
                      ? 'Update Measurement'
                      : 'Save & Create Order',
                  onPressed: _saveMeasurement,
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  String _label(String key) {
    switch (key) {
      case 'pantLength':
        return 'Pant Length';
      case 'forkLength':
        return 'Fork Length';
      case 'backWidth':
        return 'Back Width';
      case 'frontLength':
        return 'Front Length';
      case 'shirtLength':
        return 'Shirt Length';
      case 'kameezLength':
        return 'Kameez Length';
      case 'trouserLength':
        return 'Trouser Length';
      case 'armhole':
        return 'Armhole';
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }
}
