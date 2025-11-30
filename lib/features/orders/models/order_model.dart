import 'package:flutter/material.dart';

import 'order_item_model.dart';

enum OrderStatus { newOrder, inProgress, completed }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.newOrder:
        return 'New';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.newOrder:
        return Colors.green;
      case OrderStatus.inProgress:
        return Colors.black;
      case OrderStatus.completed:
        return Colors.red;
    }
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.gender,
    required this.deliveryDate,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    required this.advanceAmount,
    this.notes,
    // Legacy fields for backward compatibility
    String? orderType,
    String? measurementId,
    Map<String, double>? measurementMap,
  }) : _orderType = orderType,
       _measurementId = measurementId,
       _measurementMap = measurementMap;

  final String id;
  final String customerId;
  final String customerName;
  final List<OrderItem> items;
  final String gender;
  final DateTime deliveryDate;
  final DateTime createdAt;
  final OrderStatus status;
  final double totalAmount;
  final double advanceAmount;
  final String? notes;

  // Legacy fields for backward compatibility
  final String? _orderType;
  final String? _measurementId;
  final Map<String, double>? _measurementMap;

  // Legacy getters for backward compatibility
  String get orderType =>
      items.isNotEmpty ? items.first.orderType : (_orderType ?? '');
  String? get measurementId =>
      items.isNotEmpty ? items.first.measurementId : _measurementId;
  Map<String, double> get measurementMap =>
      items.isNotEmpty ? items.first.measurementMap : (_measurementMap ?? {});

  double get remainingAmount => totalAmount - advanceAmount;

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    List<OrderItem>? items,
    String? gender,
    DateTime? deliveryDate,
    DateTime? createdAt,
    OrderStatus? status,
    double? totalAmount,
    double? advanceAmount,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      gender: gender ?? this.gender,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      notes: notes ?? this.notes,
    );
  }
}
