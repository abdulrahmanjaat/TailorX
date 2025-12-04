import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/measurement_model.dart';
import '../repositories/measurements_firestore_repository.dart';
import '../services/measurements_service.dart';
import '../../notifications/providers/notifications_providers.dart';
import '../../notifications/services/notification_service.dart';

class MeasurementsController
    extends StateNotifier<AsyncValue<List<MeasurementModel>>> {
  MeasurementsController(
    this._repository,
    this._notificationService,
  ) : super(const AsyncValue.loading()) {
    _loadMeasurements();
  }

  final MeasurementsFirestoreRepository _repository;
  final NotificationService? _notificationService;

  Future<void> _loadMeasurements() async {
    try {
      final measurements = await _repository.getAllMeasurements();
      state = AsyncValue.data(measurements);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addMeasurement(MeasurementModel measurement) async {
    try {
      await _repository.addMeasurement(measurement);
      await _loadMeasurements(); // Reload to get updated list
      
      // Trigger notification
      _notificationService?.notifyMeasurementSaved(
        measurement.customerName,
        measurement.orderType,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMeasurement(MeasurementModel measurement) async {
    try {
      await _repository.updateMeasurement(measurement);
      await _loadMeasurements(); // Reload to get updated list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMeasurement(String id) async {
    try {
      await _repository.deleteMeasurement(id);
      await _loadMeasurements(); // Reload to get updated list
    } catch (e) {
      rethrow;
    }
  }

  MeasurementModel? byCustomer(String customerId) {
    final measurements = state.value;
    if (measurements == null) return null;
    try {
      return measurements.firstWhere((item) => item.customerId == customerId);
    } catch (_) {
      return null;
    }
  }

  MeasurementModel? byId(String id) {
    final measurements = state.value;
    if (measurements == null) return null;
    try {
      return measurements.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}

final measurementsProvider =
    StateNotifierProvider<
      MeasurementsController,
      AsyncValue<List<MeasurementModel>>
    >(
      (ref) => MeasurementsController(
        ref.read(measurementsFirestoreRepositoryProvider),
        ref.read(notificationServiceProvider),
      ),
    );
