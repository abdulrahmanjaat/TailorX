import '../models/notification_model.dart';
import '../repositories/notifications_firestore_repository.dart';

class NotificationService {
  NotificationService({required this.repository});

  final NotificationsFirestoreRepository repository;

  /// Create a notification for a new customer added
  Future<void> notifyCustomerAdded(String customerName) async {
    final notification = NotificationModel(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Customer Added',
      message: 'Customer "$customerName" has been added to your list',
      type: NotificationType.customerAdded,
      createdAt: DateTime.now(),
      isRead: false,
    );
    await repository.createNotification(notification);
  }

  /// Create a notification for a new measurement saved
  Future<void> notifyMeasurementSaved(
    String customerName,
    String orderType,
  ) async {
    final notification = NotificationModel(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Measurement Saved',
      message: 'Measurement for "$orderType" has been saved for $customerName',
      type: NotificationType.measurementSaved,
      createdAt: DateTime.now(),
      isRead: false,
    );
    await repository.createNotification(notification);
  }

  /// Create a notification for a new order created
  Future<void> notifyOrderCreated(String orderId, String customerName) async {
    final notification = NotificationModel(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Order Created',
      message: 'New order has been created for $customerName',
      type: NotificationType.orderCreated,
      orderId: orderId,
      createdAt: DateTime.now(),
      isRead: false,
    );
    await repository.createNotification(notification);
  }

  /// Create a notification for order status update
  Future<void> notifyOrderStatusUpdated(
    String orderId,
    String customerName,
    String oldStatus,
    String newStatus,
  ) async {
    // Only notify when status changes to completed
    if (newStatus.toLowerCase() == 'completed') {
      final notification = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Order Completed',
        message: 'Order for $customerName has been marked as completed',
        type: NotificationType.orderStatusUpdated,
        orderId: orderId,
        createdAt: DateTime.now(),
        isRead: false,
      );
      await repository.createNotification(notification);
    }
  }

  /// Create a notification for fitting date assignment
  Future<void> notifyFittingDateAssigned(
    String orderId,
    String customerName,
    DateTime fittingDate,
  ) async {
    final dateStr = _formatDate(fittingDate);
    final notification = NotificationModel(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Fitting Date Assigned',
      message: 'Fitting date for $customerName has been set to $dateStr',
      type: NotificationType.fittingDateAssigned,
      orderId: orderId,
      createdAt: DateTime.now(),
      isRead: false,
    );
    await repository.createNotification(notification);
  }

  /// Create a notification for delivery date assignment
  Future<void> notifyDeliveryDateAssigned(
    String orderId,
    String customerName,
    DateTime deliveryDate,
  ) async {
    final dateStr = _formatDate(deliveryDate);
    final notification = NotificationModel(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Delivery Date Assigned',
      message: 'Delivery date for $customerName has been set to $dateStr',
      type: NotificationType.deliveryDateAssigned,
      orderId: orderId,
      createdAt: DateTime.now(),
      isRead: false,
    );
    await repository.createNotification(notification);
  }

  /// Format date for notification message
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
