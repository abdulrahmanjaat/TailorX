enum MeasurementGender { male, female, unisex }

extension MeasurementGenderX on MeasurementGender {
  String get label {
    switch (this) {
      case MeasurementGender.male:
        return 'Male';
      case MeasurementGender.female:
        return 'Female';
      case MeasurementGender.unisex:
        return 'Unisex';
    }
  }
}

class MeasurementModel {
  MeasurementModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.gender,
    required this.orderType,
    required this.values,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final MeasurementGender gender;
  final String orderType;
  final Map<String, double> values;
  final String? notes;
  final DateTime createdAt;

  MeasurementModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    MeasurementGender? gender,
    String? orderType,
    Map<String, double>? values,
    String? notes,
    DateTime? createdAt,
  }) {
    return MeasurementModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      gender: gender ?? this.gender,
      orderType: orderType ?? this.orderType,
      values: values ?? this.values,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double? valueFor(String key) => values[key];
}
