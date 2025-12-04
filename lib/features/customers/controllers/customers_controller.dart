import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer_model.dart';
import '../repositories/customers_firestore_repository.dart';
import '../services/customers_service.dart';
import '../../notifications/providers/notifications_providers.dart';
import '../../notifications/services/notification_service.dart';

class CustomersController
    extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  CustomersController(
    this._repository,
    this._notificationService,
  ) : super(const AsyncValue.loading()) {
    _loadCustomers();
  }

  final CustomersFirestoreRepository _repository;
  final NotificationService? _notificationService;

  Future<void> _loadCustomers() async {
    try {
      final customers = await _repository.getAllCustomers();
      state = AsyncValue.data(customers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await _repository.addCustomer(customer);
      await _loadCustomers(); // Reload to get updated list
      
      // Trigger notification
      _notificationService?.notifyCustomerAdded(customer.name);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _repository.updateCustomer(customer);
      await _loadCustomers(); // Reload to get updated list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      await _loadCustomers(); // Reload to get updated list
    } catch (e) {
      rethrow;
    }
  }

  CustomerModel? byId(String id) {
    final customers = state.value;
    if (customers == null) return null;
    try {
      return customers.firstWhere((customer) => customer.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Finds a customer by phone number or name (case-insensitive)
  /// Returns the first matching customer or null if not found
  Future<CustomerModel?> findByPhoneOrName(String phone, String name) async {
    try {
      return await _repository.findByPhoneOrName(phone, name);
    } catch (_) {
      return null;
    }
  }
}

final customersProvider =
    StateNotifierProvider<CustomersController, AsyncValue<List<CustomerModel>>>(
      (ref) => CustomersController(
        ref.read(customersFirestoreRepositoryProvider),
        ref.read(notificationServiceProvider),
      ),
    );
