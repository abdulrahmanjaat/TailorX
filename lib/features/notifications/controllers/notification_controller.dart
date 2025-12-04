import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../providers/notifications_providers.dart';
import '../repositories/notifications_firestore_repository.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.icon,
    this.isRead = false,
    this.orderId,
  });

  final String id;
  final String title;
  final String body;
  final String timestamp;
  final IconData icon;
  final bool isRead;
  final String? orderId;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      icon: icon,
      isRead: isRead ?? this.isRead,
      orderId: orderId,
    );
  }

  static NotificationItem fromModel(NotificationModel model) {
    IconData icon;
    switch (model.type) {
      case NotificationType.customerAdded:
        icon = Icons.person_add;
        break;
      case NotificationType.measurementSaved:
        icon = Icons.straighten;
        break;
      case NotificationType.orderCreated:
        icon = Icons.receipt_long;
        break;
      case NotificationType.orderStatusUpdated:
        icon = Icons.check_circle;
        break;
      case NotificationType.fittingDateAssigned:
        icon = Icons.event;
        break;
      case NotificationType.deliveryDateAssigned:
        icon = Icons.local_shipping;
        break;
    }

    return NotificationItem(
      id: model.id,
      title: model.title,
      body: model.message,
      timestamp: _formatTimestamp(model.createdAt),
      icon: icon,
      isRead: model.isRead,
      orderId: model.orderId,
    );
  }

  static String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }
}

class NotificationController extends StateNotifier<List<NotificationItem>> {
  NotificationController(this._repository) : super([]);

  final NotificationsFirestoreRepository _repository;

  void loadNotifications(List<NotificationModel> models) {
    state = models.map((model) => NotificationItem.fromModel(model)).toList();
  }

  Future<void> markAllRead() async {
    await _repository.markAllAsRead();
    state = [for (final item in state) item.copyWith(isRead: true)];
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    state = [
      for (final item in state)
        item.id == id ? item.copyWith(isRead: true) : item,
    ];
  }

  void toggleRead(String id) {
    state = [
      for (final item in state)
        item.id == id ? item.copyWith(isRead: !item.isRead) : item,
    ];
  }

  Future<void> remove(String id) async {
    await _repository.deleteNotification(id);
    state = state.where((item) => item.id != id).toList();
  }
}

final notificationListProvider =
    StateNotifierProvider<NotificationController, List<NotificationItem>>((
      ref,
    ) {
      final controller = NotificationController(
        ref.read(notificationsFirestoreRepositoryProvider),
      );
      // Watch notifications stream and update controller
      ref.listen(notificationsStreamProvider, (previous, next) {
        next.whenData((notifications) {
          controller.loadNotifications(notifications);
        });
      });
      return controller;
    });
