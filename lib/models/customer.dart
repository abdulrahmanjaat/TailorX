// customer.dart
import 'measurement_model.dart';

class Customer {
  final String id;
  final String name;
  final String phone; // REQUIRED, UNIQUE
  final String address;
  final List<Measurement> measurements;
  final DateTime createdAt;
  final DateTime? lastOrderDate;
  final String userId;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address = '',
    required this.measurements,
    required this.createdAt,
    this.lastOrderDate,
    required this.userId,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    List<Measurement>? measurements,
    DateTime? createdAt,
    DateTime? lastOrderDate,
    String? userId,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      measurements: measurements ?? this.measurements,
      createdAt: createdAt ?? this.createdAt,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      userId: userId ?? this.userId,
    );
  }

  // Add a measurement to the customer
  Customer addMeasurement(Measurement measurement) {
    final updatedMeasurements = List<Measurement>.from(measurements);
    updatedMeasurements.add(measurement);
    return copyWith(measurements: updatedMeasurements);
  }
}
