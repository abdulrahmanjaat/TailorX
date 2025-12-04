import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';
import '../repositories/orders_firestore_repository.dart';
import '../services/orders_service.dart';
import '../../notifications/providers/notifications_providers.dart';
import '../../notifications/services/notification_service.dart';

class OrdersController extends StateNotifier<AsyncValue<List<OrderModel>>> {
  OrdersController(
    this._repository,
    this._notificationService,
  ) : super(const AsyncValue.loading()) {
    _loadOrders();
  }

  final OrdersFirestoreRepository _repository;
  final NotificationService? _notificationService;

  Future<void> _loadOrders() async {
    try {
      final orders = await _repository.getAllOrders();
      state = AsyncValue.data(orders);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addOrder(OrderModel order) async {
    try {
      await _repository.addOrder(order);
      await _loadOrders(); // Reload to get updated list
      
      // Trigger notification
      _notificationService?.notifyOrderCreated(order.id, order.customerName);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrder(OrderModel order) async {
    try {
      await _repository.updateOrder(order);
      await _loadOrders(); // Reload to get updated list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await _repository.deleteOrder(id);
      await _loadOrders(); // Reload to get updated list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(String id, OrderStatus status) async {
    try {
      // Get old status before update
      final oldOrder = state.value?.firstWhere((o) => o.id == id);
      final oldStatus = oldOrder?.status.label ?? '';
      
      await _repository.updateOrderStatus(id, status);
      await _loadOrders(); // Reload to get updated list
      
      // Trigger notification for status change
      if (oldOrder != null) {
        _notificationService?.notifyOrderStatusUpdated(
          id,
          oldOrder.customerName,
          oldStatus,
          status.label,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersController, AsyncValue<List<OrderModel>>>(
      (ref) => OrdersController(
        ref.read(ordersFirestoreRepositoryProvider),
        ref.read(notificationServiceProvider),
      ),
    );
