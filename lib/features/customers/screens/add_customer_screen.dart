import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../shared/widgets/app_scaffold.dart';
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

    final customer = CustomerModel(
      id: 'cus-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(customersProvider.notifier).addCustomer(customer);

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
              AppInputField(
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: '+92 300 1234567',
                keyboardType: TextInputType.phone,
                prefix: const Icon(Icons.phone_outlined),
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'Phone'),
              ),
              const SizedBox(height: AppSizes.md),
              AppInputField(
                controller: _emailController,
                labelText: 'Email (Optional)',
                hintText: 'customer@example.com',
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(Icons.email_outlined),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return Validators.email(value);
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              AppInputField(
                controller: _addressController,
                labelText: 'Address (Optional)',
                hintText: 'Enter address',
                prefix: const Icon(Icons.location_on_outlined),
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
