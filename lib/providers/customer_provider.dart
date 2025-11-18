import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  Customer? _currentCustomer;
  final List<String> _selectedGarments = [];

  // Getters
  Customer? get currentCustomer => _currentCustomer;
  List<String> get selectedGarments => _selectedGarments;

  // Set selected garments for current measurement session
  void setSelectedGarments(List<String> garments) {
    _selectedGarments.clear();
    _selectedGarments.addAll(garments);
    notifyListeners();
  }

  // Set current customer (for UI selection only)
  void setCurrentCustomer(Customer? customer) {
    _currentCustomer = customer;
    notifyListeners();
  }

  // Clear current customer selection
  void clearCurrentCustomer() {
    _currentCustomer = null;
    _selectedGarments.clear();
    notifyListeners();
  }

  // Search customers by name or phone (UI only, not used for Firestore data)
  // This can be removed if not needed
}
