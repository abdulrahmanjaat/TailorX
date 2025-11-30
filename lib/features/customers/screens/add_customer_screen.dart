import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/international_phone_field.dart';
import '../controllers/customers_controller.dart';
import '../models/customer_model.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFieldKey = GlobalKey<InternationalPhoneFieldState>();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    // Get full phone number with country code from the phone field
    final phone =
        _phoneFieldKey.currentState?.getFullPhoneNumber() ??
        _phoneController.text.trim();

    // Check if customer already exists
    final existingCustomer = ref
        .read(customersProvider.notifier)
        .findByPhoneOrName(phone, name);

    if (existingCustomer != null) {
      // Customer already exists - redirect to customer detail screen
      SnackbarService.showInfo(
        context,
        message: 'Customer already exists. Opening customer details...',
      );
      if (mounted) {
        context.pushReplacement(
          '${AppRoutes.customerDetail}/${existingCustomer.id}',
        );
      }
      return;
    }

    // Create new customer
    final customer = CustomerModel(
      id: 'cus-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(customersProvider.notifier).addCustomer(customer);
    SnackbarService.showSuccess(
      context,
      message: 'Customer created successfully',
    );

    // Redirect to Add Measurement Screen with customer data
    if (mounted) {
      context.pushReplacement(
        '${AppRoutes.addMeasurement}?customerId=${customer.id}&customerName=${Uri.encodeComponent(customer.name)}&phone=${Uri.encodeComponent(customer.phone)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Add Customer',
      padding: const EdgeInsets.all(AppSizes.lg),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInputField(
                controller: _nameController,
                labelText: 'Full Name',
                hintText: 'Enter customer name',
                prefix: const Icon(Icons.person_outline),
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'Name'),
              ),
              const SizedBox(height: AppSizes.md),
              InternationalPhoneField(
                key: _phoneFieldKey,
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: '1234567890',
                validator: (value) => Validators.phone(value),
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'customer@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.md,
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return Validators.email(value);
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address (Optional)',
                  hintText: 'Enter address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.md,
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.xl),
              AppButton(label: 'Save Customer', onPressed: _saveCustomer),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }
}
