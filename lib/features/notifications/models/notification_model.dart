import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  customerAdded,
  measurementSaved,
  orderCreated,
  orderStatusUpdated,
  fittingDateAssigned,
  deliveryDateAssigned,
}

extension NotificationTypeX on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.customerAdded:
        return 'customer_added';
      case NotificationType.measurementSaved:
        return 'measurement_saved';
      case NotificationType.orderCreated:
        return 'order_created';
      case NotificationType.orderStatusUpdated:
        return 'order_status_updated';
      case NotificationType.fittingDateAssigned:
        return 'fitting_date_assigned';
      case NotificationType.deliveryDateAssigned:
        return 'delivery_date_assigned';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'customer_added':
        return NotificationType.customerAdded;
      case 'measurement_saved':
        return NotificationType.measurementSaved;
      case 'order_created':
        return NotificationType.orderCreated;
      case 'order_status_updated':
        return NotificationType.orderStatusUpdated;
      case 'fitting_date_assigned':
        return NotificationType.fittingDateAssigned;
      case 'delivery_date_assigned':
        return NotificationType.deliveryDateAssigned;
      default:
        return NotificationType.orderCreated;
    }
  }
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.orderId,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? orderId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? orderId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.value,
      'orderId': orderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationTypeX.fromString(json['type'] as String),
      orderId: json['orderId'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return NotificationModel(
      id: doc.id,
      title: data['title'] as String,
      message: data['message'] as String,
      type: NotificationTypeX.fromString(data['type'] as String),
      orderId: data['orderId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
