// measurement_model.dart
class MeasurementFieldModel {
  final String label;
  final String value;

  MeasurementFieldModel({required this.label, required this.value});

  Map<String, dynamic> toMap() => {'label': label, 'value': value};
  static MeasurementFieldModel fromMap(Map<String, dynamic> map) =>
      MeasurementFieldModel(label: map['label'], value: map['value']);
}

class MeasurementSection {
  final String sectionName;
  final List<MeasurementFieldModel> fields;

  MeasurementSection({required this.sectionName, required this.fields});

  Map<String, dynamic> toMap() => {
    'sectionName': sectionName,
    'fields': fields.map((f) => f.toMap()).toList(),
  };

  static MeasurementSection fromMap(Map<String, dynamic> map) =>
      MeasurementSection(
        sectionName: map['sectionName'],
        fields:
            (map['fields'] as List)
                .map((f) => MeasurementFieldModel.fromMap(f))
                .toList(),
      );
}

class SectionedMeasurement {
  final List<MeasurementSection> sections;
  SectionedMeasurement({required this.sections});

  Map<String, dynamic> toMap() => {
    'sections': sections.map((s) => s.toMap()).toList(),
  };

  static SectionedMeasurement fromMap(Map<String, dynamic> map) =>
      SectionedMeasurement(
        sections:
            (map['sections'] as List)
                .map((s) => MeasurementSection.fromMap(s))
                .toList(),
      );
}

class Measurement {
  final String id;
  final String garmentType;
  final String customerName;
  final String phone;
  final Map<String, double> measurements;
  final Map<String, String> additionalDetails;
  final String designNotes;
  final DateTime createdAt;
  final DateTime deliveryDate;
  final String customerId;
  final String userId;
  final List<MeasurementSection>?
  sectionedMeasurements; // New field for section-wise storage

  Measurement({
    required this.id,
    required this.garmentType,
    required this.customerName,
    required this.phone,
    required this.measurements,
    required this.additionalDetails,
    this.designNotes = '',
    required this.createdAt,
    required this.deliveryDate,
    required this.customerId,
    required this.userId,
    this.sectionedMeasurements,
  });

  Measurement copyWith({
    String? id,
    String? garmentType,
    String? customerName,
    String? phone,
    Map<String, double>? measurements,
    Map<String, String>? additionalDetails,
    String? designNotes,
    DateTime? createdAt,
    DateTime? deliveryDate,
    String? customerId,
    String? userId,
    List<MeasurementSection>? sectionedMeasurements,
  }) {
    return Measurement(
      id: id ?? this.id,
      garmentType: garmentType ?? this.garmentType,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      measurements: measurements ?? this.measurements,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      designNotes: designNotes ?? this.designNotes,
      createdAt: createdAt ?? this.createdAt,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      customerId: customerId ?? this.customerId,
      userId: userId ?? this.userId,
      sectionedMeasurements:
          sectionedMeasurements ?? this.sectionedMeasurements,
    );
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'] ?? '',
      garmentType: map['garmentType'] ?? '',
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      measurements: Map<String, double>.from(map['measurements'] ?? {}),
      additionalDetails: Map<String, String>.from(
        map['additionalDetails'] ?? {},
      ),
      designNotes: map['designNotes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      deliveryDate: DateTime.parse(map['deliveryDate']),
      customerId: map['customerId'] ?? '',
      userId: map['userId'] ?? '',
      sectionedMeasurements:
          map['sectionedMeasurement'] != null
              ? (SectionedMeasurement.fromMap(
                map['sectionedMeasurement'],
              ).sections)
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'garmentType': garmentType,
      'customerName': customerName,
      'phone': phone,
      'measurements': measurements,
      'additionalDetails': additionalDetails,
      'designNotes': designNotes,
      'createdAt': createdAt.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'customerId': customerId,
      'userId': userId,
      if (sectionedMeasurements != null)
        'sectionedMeasurement':
            SectionedMeasurement(sections: sectionedMeasurements!).toMap(),
    };
  }
}
