import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/services/snackbar_service.dart';
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
  PhoneNumber? _phoneNumber;
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String? _initialCountryCode;

  @override
  void initState() {
    super.initState();
    _loadCountryCode();
  }

  Future<void> _loadCountryCode() async {
    final countryCode = await SecureStorageService.instance.getCountryCode();
    if (mounted) {
      setState(() {
        _initialCountryCode = countryCode ?? 'PK'; // Default to Pakistan
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    // Get full phone number with country code from the phone field
    // completeNumber includes country code (e.g., +923001234567)
    final phone =
        _phoneNumber?.completeNumber ??
        (_phoneController.text.isNotEmpty ? _phoneController.text.trim() : '');

    // Check if customer already exists
    final existingCustomer = await ref
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

    try {
      await ref.read(customersProvider.notifier).addCustomer(customer);
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          message: 'Customer created successfully',
        );

        // Redirect to Add Measurement Screen with customer data
        context.pushReplacement(
          '${AppRoutes.addMeasurement}?customerId=${customer.id}&customerName=${Uri.encodeComponent(customer.name)}&phone=${Uri.encodeComponent(customer.phone)}',
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to save customer. ';
        if (e.toString().contains('permission-denied')) {
          errorMessage += 'Please make sure you are signed in.';
        } else if (e.toString().contains('not authenticated')) {
          errorMessage += 'Your session has expired. Please sign in again.';
        } else {
          errorMessage += e.toString();
        }
        SnackbarService.showError(context, message: errorMessage);
      }
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone Number',
                    style: AppTextStyles.bodyRegular.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  _initialCountryCode == null
                      ? const SizedBox(
                          height: 56,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : IntlPhoneField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: 'Enter phone number',
                            hintStyle: AppTextStyles.inputHint.copyWith(
                              color: AppColors.dark.withValues(alpha: 0.6),
                            ),
                            labelStyle: TextStyle(
                              color: AppColors.dark,
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.md,
                            ),
                            constraints: const BoxConstraints(minHeight: 56),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGray,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGray,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.error,
                                width: 2,
                              ),
                            ),
                          ),
                          initialCountryCode: _initialCountryCode ?? 'PK',
                          onChanged: (phone) {
                            setState(() {
                              _phoneNumber = phone;
                            });
                          },
                          validator: (phone) {
                            if (phone == null || phone.number.isEmpty) {
                              return 'Phone number is required';
                            }
                            // Validate minimum length (10 digits after country code)
                            if (phone.number.length < 10) {
                              return 'Phone number must be at least 10 digits';
                            }
                            return null;
                          },
                        ),
                ],
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
              Center(
                child: AppButton(
                  label: 'Save Customer',
                  onPressed: _saveCustomer,
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }
}
