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
import '../../measurements/controllers/measurements_controller.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

class AddOrderScreen extends ConsumerStatefulWidget {
  const AddOrderScreen({super.key});

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _notesController = TextEditingController();
  final _deliveryDateController = TextEditingController();

  String? _customerId;
  String? _customerName;
  String? _phone;
  String? _gender;
  String? _orderType;
  String? _measurementId;
  Map<String, double> _measurementMap = {};
  DateTime? _deliveryDate;

  @override
  void initState() {
    super.initState();
    _totalAmountController.addListener(() => setState(() {}));
    _advanceAmountController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadParamsFromRoute();
    });
  }

  void _loadParamsFromRoute() {
    final uri = GoRouterState.of(context).uri;
    final params = uri.queryParameters;

    setState(() {
      _customerId = params['customerId'];
      _customerName = params['customerName'] != null
          ? Uri.decodeComponent(params['customerName']!)
          : null;
      _phone = params['phone'] != null
          ? Uri.decodeComponent(params['phone']!)
          : null;
      _gender = params['gender'];
      _orderType = params['orderType'] != null
          ? Uri.decodeComponent(params['orderType']!)
          : null;
      _measurementId = params['measurementId'];

      if (_measurementId != null) {
        final measurements = ref.read(measurementsProvider);
        try {
          final measurement = measurements.firstWhere(
            (m) => m.id == _measurementId,
          );
          _measurementMap = measurement.values;
        } catch (_) {
          // Measurement not found
        }
      }
    });
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
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

  void _saveOrder() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_customerId == null || _orderType == null) {
      SnackbarService.showInfo(
        context,
        message: 'Missing required information',
      );
      return;
    }
    if (_deliveryDate == null) {
      SnackbarService.showInfo(context, message: 'Please select delivery date');
      return;
    }

    final total = double.tryParse(_totalAmountController.text) ?? 0;
    final advance = double.tryParse(_advanceAmountController.text) ?? 0;

    final order = OrderModel(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      customerId: _customerId!,
      customerName: _customerName ?? 'Unknown',
      orderType: _orderType!,
      gender: _gender ?? 'Unknown',
      measurementId: _measurementId,
      measurementMap: _measurementMap,
      deliveryDate: _deliveryDate!,
      createdAt: DateTime.now(),
      status: OrderStatus.newOrder,
      totalAmount: total,
      advanceAmount: advance,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    ref.read(ordersProvider.notifier).addOrder(order);

    // Redirect to receipt screen
    if (mounted) {
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
              ],
              if (_orderType != null) ...[
                CustomCard(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      const Icon(Icons.category, color: AppColors.primary),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order Type', style: AppTextStyles.caption),
                            Text(
                              _orderType!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ],
              if (_measurementMap.isNotEmpty) ...[
                CustomCard(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.straighten,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            'Measurements (Preview)',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Wrap(
                        spacing: AppSizes.sm,
                        runSpacing: AppSizes.xs,
                        children: _measurementMap.entries
                            .take(8)
                            .map(
                              (entry) => Chip(
                                label: Text(
                                  '${_label(entry.key)}: ${entry.value}',
                                  style: AppTextStyles.caption,
                                ),
                                backgroundColor: AppColors.surface,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ],
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
                controller: _totalAmountController,
                labelText: 'Total Amount',
                hintText: 'Enter total amount',
                keyboardType: TextInputType.number,
                prefix: const Icon(Icons.currency_rupee),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter total amount';
                  }
                  return double.tryParse(value) == null
                      ? 'Enter valid number'
                      : null;
                },
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
              if (_totalAmountController.text.isNotEmpty &&
                  _advanceAmountController.text.isNotEmpty)
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
                        'PKR ${(double.tryParse(_totalAmountController.text) ?? 0) - (double.tryParse(_advanceAmountController.text) ?? 0)}',
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
              AppButton(label: 'Save Order', onPressed: _saveOrder),
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
