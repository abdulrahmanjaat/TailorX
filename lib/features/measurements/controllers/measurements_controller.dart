import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/measurement_model.dart';

class MeasurementsController extends StateNotifier<List<MeasurementModel>> {
  MeasurementsController() : super(_initialMeasurements);

  static Map<String, double> _values({
    double chest = 0,
    double shoulder = 0,
    double sleeve = 0,
    double neck = 0,
    double arm = 0,
    double bicep = 0,
    double wrist = 0,
    double shirtLength = 0,
    double waist = 0,
    double hip = 0,
    double thigh = 0,
    double knee = 0,
    double calf = 0,
    double ankle = 0,
    double pantLength = 0,
    double forkLength = 0,
    double bottom = 0,
    double backWidth = 0,
    double frontLength = 0,
    double belly = 0,
    double height = 0,
    double weight = 0,
  }) {
    return {
      'chest': chest,
      'shoulder': shoulder,
      'sleeve': sleeve,
      'neck': neck,
      'arm': arm,
      'bicep': bicep,
      'wrist': wrist,
      'shirtLength': shirtLength,
      'waist': waist,
      'hip': hip,
      'thigh': thigh,
      'knee': knee,
      'calf': calf,
      'ankle': ankle,
      'pantLength': pantLength,
      'forkLength': forkLength,
      'bottom': bottom,
      'backWidth': backWidth,
      'frontLength': frontLength,
      'belly': belly,
      'height': height,
      'weight': weight,
    };
  }

  static final _initialMeasurements = <MeasurementModel>[
    MeasurementModel(
      id: 'mea-1',
      customerId: 'cus-1',
      customerName: 'Ahmed Ali',
      gender: MeasurementGender.male,
      orderType: 'Pant Coat',
      values: _values(
        chest: 42,
        shoulder: 18,
        sleeve: 25,
        waist: 36,
        hip: 40,
        pantLength: 40,
        thigh: 23,
        height: 175,
        weight: 78,
      ),
      notes: 'Prefers regular fit',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    MeasurementModel(
      id: 'mea-2',
      customerId: 'cus-2',
      customerName: 'Fatima Khan',
      gender: MeasurementGender.female,
      orderType: 'Shalwar Kameez',
      values: _values(
        chest: 36,
        shoulder: 15,
        sleeve: 22,
        waist: 30,
        hip: 38,
        pantLength: 38,
        thigh: 21,
        height: 165,
        weight: 60,
      ),
      notes: 'Looser sleeves requested',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    MeasurementModel(
      id: 'mea-3',
      customerId: 'cus-3',
      customerName: 'Hassan Raza',
      gender: MeasurementGender.male,
      orderType: 'Kurta',
      values: _values(
        chest: 44,
        shoulder: 19,
        sleeve: 26,
        waist: 38,
        hip: 42,
        pantLength: 41,
        thigh: 24,
        height: 178,
        weight: 82,
      ),
      notes: 'Preferred slim taper',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  void addMeasurement(MeasurementModel measurement) {
    state = [...state, measurement];
  }

  void updateMeasurement(MeasurementModel measurement) {
    state = state
        .map((item) => item.id == measurement.id ? measurement : item)
        .toList();
  }

  void deleteMeasurement(String id) {
    state = state.where((measurement) => measurement.id != id).toList();
  }

  MeasurementModel? byCustomer(String customerId) {
    try {
      return state.firstWhere((item) => item.customerId == customerId);
    } catch (_) {
      return null;
    }
  }

  MeasurementModel? byId(String id) {
    try {
      return state.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}

final measurementsProvider =
    StateNotifierProvider<MeasurementsController, List<MeasurementModel>>(
      (ref) => MeasurementsController(),
    );
