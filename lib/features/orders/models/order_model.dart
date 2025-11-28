import 'package:flutter/material.dart';

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
        return const Color(0xFF2B7A78);
      case OrderStatus.inProgress:
        return const Color(0xFF3AAFA9);
      case OrderStatus.completed:
        return Colors.green;
    }
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.orderType,
    required this.gender,
    required this.measurementId,
    required this.measurementMap,
    required this.deliveryDate,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    required this.advanceAmount,
    this.notes,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String orderType;
  final String gender;
  final String? measurementId;
  final Map<String, double> measurementMap;
  final DateTime deliveryDate;
  final DateTime createdAt;
  final OrderStatus status;
  final double totalAmount;
  final double advanceAmount;
  final String? notes;

  double get remainingAmount => totalAmount - advanceAmount;

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? orderType,
    String? gender,
    String? measurementId,
    Map<String, double>? measurementMap,
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
      orderType: orderType ?? this.orderType,
      gender: gender ?? this.gender,
      measurementId: measurementId ?? this.measurementId,
      measurementMap: measurementMap ?? this.measurementMap,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      notes: notes ?? this.notes,
    );
  }
}
