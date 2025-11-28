import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer_model.dart';

class CustomersController extends StateNotifier<List<CustomerModel>> {
  CustomersController() : super(_initialCustomers);

  static final _initialCustomers = <CustomerModel>[
    CustomerModel(
      id: 'cus-1',
      name: 'Ahmed Ali',
      phone: '+92 300 1234567',
      email: 'ahmed.taylor@example.com',
      address: 'Lahore, Pakistan',
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
    CustomerModel(
      id: 'cus-2',
      name: 'Fatima Khan',
      phone: '+92 301 9876543',
      email: 'fatima.couture@example.com',
      address: 'Karachi, Pakistan',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    CustomerModel(
      id: 'cus-3',
      name: 'Hassan Raza',
      phone: '+92 302 7654321',
      email: 'hassan.studio@example.com',
      address: 'Islamabad, Pakistan',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
  ];

  void addCustomer(CustomerModel customer) {
    state = [...state, customer];
  }

  void updateCustomer(CustomerModel customer) {
    state = state
        .map((item) => item.id == customer.id ? customer : item)
        .toList();
  }

  void deleteCustomer(String id) {
    state = state.where((customer) => customer.id != id).toList();
  }

  CustomerModel? byId(String id) {
    try {
      return state.firstWhere((customer) => customer.id == id);
    } catch (_) {
      return null;
    }
  }
}

final customersProvider =
    StateNotifierProvider<CustomersController, List<CustomerModel>>(
      (ref) => CustomersController(),
    );
