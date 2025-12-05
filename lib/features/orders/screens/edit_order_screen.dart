import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../notifications/providers/notifications_providers.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

class EditOrderScreen extends ConsumerStatefulWidget {
  const EditOrderScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends ConsumerState<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _notesController = TextEditingController();
  final _deliveryDateController = TextEditingController();

  OrderModel? _order;
  DateTime? _deliveryDate;
  String _currencySymbol = '\$'; // Default, will be updated

  @override
  void initState() {
    super.initState();
    _totalAmountController.addListener(() => setState(() {}));
    _advanceAmountController.addListener(() => setState(() {}));
    _loadCurrencySymbol();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
    });
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await CurrencyFormatter.getCurrencySymbol();
    if (mounted) {
      setState(() {
        _currencySymbol = symbol;
      });
    }
  }

  void _loadOrder() {
    final ordersAsync = ref.read(ordersProvider);
    final orders = ordersAsync.value ?? [];
    try {
      final order = orders.firstWhere((o) => o.id == widget.orderId);
      setState(() {
        _order = order;
        _totalAmountController.text = order.totalAmount.toStringAsFixed(0);
        _advanceAmountController.text = order.advanceAmount.toStringAsFixed(0);
        _notesController.text = order.notes ?? '';
        _deliveryDate = order.deliveryDate;
        _deliveryDateController.text = _formatDate(order.deliveryDate);
      });
    } catch (_) {
      if (mounted) {
        SnackbarService.showError(context, message: 'Order not found');
        context.pop();
      }
    }
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

  Future<void> _saveOrder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_order == null) return;
    if (_deliveryDate == null) {
      SnackbarService.showInfo(context, message: 'Please select delivery date');
      return;
    }

    final total = double.tryParse(_totalAmountController.text) ?? 0;
    final advance = double.tryParse(_advanceAmountController.text) ?? 0;

    final oldDeliveryDate = _order!.deliveryDate;
    final updatedOrder = _order!.copyWith(
      deliveryDate: _deliveryDate!,
      totalAmount: total,
      advanceAmount: advance,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await ref.read(ordersProvider.notifier).updateOrder(updatedOrder);

    // Trigger notification if delivery date changed
    if (_deliveryDate != oldDeliveryDate) {
      final notificationService = ref.read(notificationServiceProvider);
      notificationService.notifyDeliveryDateAssigned(
        updatedOrder.id,
        updatedOrder.customerName,
        _deliveryDate!,
      );
    }

    if (mounted) {
      SnackbarService.showSuccess(context, message: 'Order updated');
      // Redirect back to order detail screen
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) {
      return AppScaffold(
        title: 'Edit Order',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: 'Edit Order',
      padding: const EdgeInsets.all(AppSizes.lg),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            _order!.customerName,
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
                            _order!.orderType,
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
                prefixText: '$_currencySymbol: ',
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
                prefixText: '$_currencySymbol: ',
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
                        '$_currencySymbol${(double.tryParse(_totalAmountController.text) ?? 0) - (double.tryParse(_advanceAmountController.text) ?? 0)}',
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
                child: AppButton(label: 'Update Order', onPressed: _saveOrder),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }
}
