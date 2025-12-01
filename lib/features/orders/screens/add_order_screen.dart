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
import '../../measurements/controllers/measurements_controller.dart';
import '../../measurements/models/measurement_model.dart';
import '../controllers/orders_controller.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class _SelectedItem {
  final String measurementId;
  final MeasurementModel measurement;
  int quantity;
  double unitPrice;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  _SelectedItem({
    required this.measurementId,
    required this.measurement,
    this.quantity = 1,
    this.unitPrice = 0,
  }) : quantityController = TextEditingController(text: '1'),
       priceController = TextEditingController();

  double get lineTotal => unitPrice * quantity;

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
  }
}

class AddOrderScreen extends ConsumerStatefulWidget {
  const AddOrderScreen({super.key});

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _advanceAmountController = TextEditingController();
  final _notesController = TextEditingController();
  final _deliveryDateController = TextEditingController();

  String? _customerId;
  String? _customerName;
  String? _phone;
  DateTime? _deliveryDate;

  final List<_SelectedItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _advanceAmountController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadParamsFromRoute();
    });
  }

  void _loadParamsFromRoute() {
    final uri = GoRouterState.of(context).uri;
    final params = uri.queryParameters;

    setState(() {
      // If customerId is provided, load customer data
      if (params.containsKey('customerId')) {
        _customerId = params['customerId'];
        final customersAsync = ref.read(customersProvider);
        final customers = customersAsync.value ?? [];
        try {
          final customer = customers.firstWhere((c) => c.id == _customerId);
          _customerName = customer.name;
          _phone = customer.phone;
        } catch (_) {
          // Customer not found
        }
      } else {
        // Legacy support for old flow
        _customerId = params['customerId'];
        _customerName = params['customerName'] != null
            ? Uri.decodeComponent(params['customerName']!)
            : null;
        _phone = params['phone'] != null
            ? Uri.decodeComponent(params['phone']!)
            : null;
      }

      final measurementId = params['measurementId'];

      // Legacy support: if single measurement comes from route, add it
      if (measurementId != null) {
        final measurementsAsync = ref.read(measurementsProvider);
        final measurements = measurementsAsync.value ?? [];
        try {
          final measurement = measurements.firstWhere(
            (m) => m.id == measurementId,
          );
          _addMeasurementItem(measurement);
        } catch (_) {
          // Measurement not found
        }
      }
    });
  }

  void _addMeasurementItem(MeasurementModel measurement) {
    final item = _SelectedItem(
      measurementId: measurement.id,
      measurement: measurement,
      quantity: 1,
      unitPrice: 0,
    );

    item.quantityController.addListener(() {
      setState(() {
        item.quantity = int.tryParse(item.quantityController.text) ?? 1;
        _updateTotalAmount();
      });
    });

    item.priceController.addListener(() {
      setState(() {
        item.unitPrice = double.tryParse(item.priceController.text) ?? 0;
        _updateTotalAmount();
      });
    });

    setState(() {
      _selectedItems.add(item);
    });
  }

  void _removeItem(_SelectedItem item) {
    item.dispose();
    setState(() {
      _selectedItems.remove(item);
      _updateTotalAmount();
    });
  }

  void _updateTotalAmount() {
    // Total is calculated from selected items
    // This is handled in the UI display
  }

  double get _subtotal {
    return _selectedItems.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  @override
  void dispose() {
    for (final item in _selectedItems) {
      item.dispose();
    }
    _advanceAmountController.dispose();
    _notesController.dispose();
    _deliveryDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDeliveryDate() async {
    if (!mounted) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _deliveryDate = picked;
        _deliveryDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _saveOrder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_customerId == null) {
      SnackbarService.showInfo(context, message: 'Customer is required');
      return;
    }
    if (_selectedItems.isEmpty) {
      SnackbarService.showInfo(
        context,
        message: 'Please select at least one measurement',
      );
      return;
    }
    if (_deliveryDate == null) {
      SnackbarService.showInfo(context, message: 'Please select delivery date');
      return;
    }

    // Validate all items have quantity and price
    for (final item in _selectedItems) {
      if (item.quantity < 1) {
        SnackbarService.showInfo(
          context,
          message:
              'Quantity must be at least 1 for ${item.measurement.orderType}',
        );
        return;
      }
      if (item.unitPrice <= 0) {
        SnackbarService.showInfo(
          context,
          message: 'Please enter price for ${item.measurement.orderType}',
        );
        return;
      }
    }

    final advance = double.tryParse(_advanceAmountController.text) ?? 0;
    final subtotal = _subtotal;

    // Create order items
    final orderItems = _selectedItems.map((item) {
      return OrderItem(
        orderType: item.measurement.orderType,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        measurementId: item.measurementId,
        measurementMap: item.measurement.values,
      );
    }).toList();

    // Determine gender from first item
    final gender = _selectedItems.first.measurement.gender.name;

    final order = OrderModel(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      customerId: _customerId!,
      customerName: _customerName ?? 'Unknown',
      items: orderItems,
      gender: gender,
      deliveryDate: _deliveryDate!,
      createdAt: DateTime.now(),
      status: OrderStatus.newOrder,
      totalAmount: subtotal,
      advanceAmount: advance,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await ref.read(ordersProvider.notifier).addOrder(order);
    if (mounted) {
      SnackbarService.showSuccess(
        context,
        message: 'Order created successfully',
      );
      // Redirect to receipt screen
      context.pushReplacement('${AppRoutes.orderReceipt}/${order.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create New Order',
      padding: const EdgeInsets.all(AppSizes.lg),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_customerName != null) ...[
                CustomCard(
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
                              _customerName!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_phone != null)
                              Text(_phone!, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                // Show customer measurements if customerId is provided
                if (_customerId != null) _buildMeasurementSelection(context),
              ],
              if (_selectedItems.isNotEmpty) ...[
                const SizedBox(height: AppSizes.lg),
                Text('Order Items', style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSizes.sm),
                ..._selectedItems.map((item) => _buildOrderItemCard(item)),
                const SizedBox(height: AppSizes.md),
                CustomCard(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: AppTextStyles.bodyLarge),
                          Text(
                            '\$${_subtotal.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.md),
              GestureDetector(
                onTap: _selectDeliveryDate,
                child: AppInputField(
                  controller: _deliveryDateController,
                  labelText: 'Delivery Date',
                  hintText: 'Pick delivery date',
                  prefix: const Icon(Icons.calendar_today_outlined),
                  enabled: false,
                  validator: (value) =>
                      _deliveryDate == null ? 'Select delivery date' : null,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              AppInputField(
                controller: _advanceAmountController,
                labelText: 'Advance Amount',
                hintText: 'Enter advance amount',
                keyboardType: TextInputType.number,
                prefix: const Icon(Icons.payments_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter advance amount';
                  }
                  return double.tryParse(value) == null
                      ? 'Enter valid number'
                      : null;
                },
              ),
              const SizedBox(height: AppSizes.sm),
              if (_advanceAmountController.text.isNotEmpty &&
                  _selectedItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Balance', style: AppTextStyles.bodyLarge),
                      Text(
                        '\$${(_subtotal - (double.tryParse(_advanceAmountController.text) ?? 0)).toStringAsFixed(2)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSizes.md),
              AppInputField(
                controller: _notesController,
                labelText: 'Notes (optional)',
                hintText: 'Add instructions for this order',
                prefix: const Icon(Icons.note_outlined),
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.xl),
              Center(
                child: AppButton(label: 'Save Order', onPressed: _saveOrder),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(_SelectedItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: CustomCard(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.measurement.gender == MeasurementGender.female
                      ? Icons.female
                      : Icons.male,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    item.measurement.orderType,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () => _removeItem(item),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: AppInputField(
                    controller: item.quantityController,
                    labelText: 'Quantity',
                    hintText: '1',
                    keyboardType: TextInputType.number,
                    prefix: const Icon(Icons.numbers),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty < 1) {
                        return 'Min: 1';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: AppInputField(
                    controller: item.priceController,
                    labelText: 'Unit Price',
                    hintText: '0.00',
                    keyboardType: TextInputType.number,
                    prefix: const Icon(Icons.attach_money),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Invalid price';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Line Total', style: AppTextStyles.caption),
                Text(
                  '\$${item.lineTotal.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementSelection(BuildContext context) {
    if (_customerId == null) return const SizedBox.shrink();

    final measurementsAsync = ref.watch(measurementsProvider);
    final measurements = measurementsAsync.value ?? [];
    final customerMeasurements = measurements
        .where((m) => m.customerId == _customerId)
        .toList();

    if (customerMeasurements.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No measurements found', style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSizes.sm),
                AppButton(
                  label: 'Create New Measurement',
                  onPressed: () => context.push(
                    '${AppRoutes.addMeasurement}?customerId=$_customerId',
                  ),
                  type: AppButtonType.secondary,
                  isSmall: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Measurements', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSizes.sm),
        Text(
          'Select one or more measurements to add to this order',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSizes.sm),
        ...customerMeasurements.map((measurement) {
          final isSelected = _selectedItems.any(
            (item) => item.measurementId == measurement.id,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: CustomCard(
              padding: const EdgeInsets.all(AppSizes.md),
              onTap: () {
                if (isSelected) {
                  // Remove if already selected
                  final item = _selectedItems.firstWhere(
                    (item) => item.measurementId == measurement.id,
                  );
                  _removeItem(item);
                } else {
                  // Add if not selected
                  _addMeasurementItem(measurement);
                }
              },
              child: Row(
                children: [
                  Icon(
                    measurement.gender == MeasurementGender.female
                        ? Icons.female
                        : Icons.male,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${measurement.orderType} - ${measurement.gender.label}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Created ${_formatDate(measurement.createdAt)}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSizes.sm),
        AppButton(
          label: 'Create New Measurement',
          onPressed: () => context.push(
            '${AppRoutes.addMeasurement}?customerId=$_customerId',
          ),
          type: AppButtonType.secondary,
          isSmall: true,
        ),
        const SizedBox(height: AppSizes.md),
      ],
    );
  }
}
