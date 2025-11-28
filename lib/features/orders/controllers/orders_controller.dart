import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';

class OrdersController extends StateNotifier<List<OrderModel>> {
  OrdersController() : super(_initialOrders);

  static final _initialOrders = <OrderModel>[
    OrderModel(
      id: 'ord-1',
      customerId: 'cus-1',
      customerName: 'Ahmed Ali',
      orderType: 'Pant Coat',
      gender: 'Male',
      measurementId: 'mea-1',
      measurementMap: const {
        'chest': 42,
        'shoulder': 18,
        'sleeve': 25,
        'waist': 36,
        'hip': 40,
        'pantLength': 40,
      },
      deliveryDate: DateTime.now().add(const Duration(days: 10)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.newOrder,
      totalAmount: 35000,
      advanceAmount: 15000,
      notes: 'Golden embroidery, classic fit',
    ),
    OrderModel(
      id: 'ord-2',
      customerId: 'cus-2',
      customerName: 'Fatima Khan',
      orderType: 'Shalwar Kameez',
      gender: 'Female',
      measurementId: 'mea-2',
      measurementMap: const {
        'chest': 36,
        'shoulder': 15,
        'sleeve': 22,
        'waist': 30,
        'hip': 38,
        'pantLength': 38,
      },
      deliveryDate: DateTime.now().add(const Duration(days: 20)),
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      status: OrderStatus.inProgress,
      totalAmount: 80000,
      advanceAmount: 30000,
      notes: 'Lightweight fabric, pastel tones',
    ),
    OrderModel(
      id: 'ord-3',
      customerId: 'cus-3',
      customerName: 'Hassan Raza',
      orderType: 'Kurta',
      gender: 'Male',
      measurementId: 'mea-3',
      measurementMap: const {
        'chest': 44,
        'shoulder': 19,
        'sleeve': 26,
        'waist': 38,
        'hip': 42,
        'pantLength': 41,
      },
      deliveryDate: DateTime.now().add(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      status: OrderStatus.completed,
      totalAmount: 25000,
      advanceAmount: 25000,
      notes: 'Deliver with premium packaging',
    ),
  ];

  void addOrder(OrderModel order) {
    state = [...state, order];
  }

  void updateOrder(OrderModel order) {
    state = state.map((item) => item.id == order.id ? order : item).toList();
  }

  void deleteOrder(String id) {
    state = state.where((order) => order.id != id).toList();
  }

  void updateStatus(String id, OrderStatus status) {
    state = state
        .map((order) => order.id == id ? order.copyWith(status: status) : order)
        .toList();
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersController, List<OrderModel>>(
      (ref) => OrdersController(),
    );
