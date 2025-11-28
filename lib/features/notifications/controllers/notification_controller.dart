import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.icon,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String timestamp;
  final IconData icon;
  final bool isRead;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      icon: icon,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationController extends StateNotifier<List<NotificationItem>> {
  NotificationController()
    : super(const [
        NotificationItem(
          id: 'n1',
          title: 'Fitting confirmed',
          body: 'Alina Ross confirmed her couture fitting for Friday 10AM.',
          timestamp: '5m ago',
          icon: Icons.event_available,
          isRead: false,
        ),
        NotificationItem(
          id: 'n2',
          title: 'Goal milestone unlocked',
          body: 'Bridal pipeline reached 60%. Keep momentum for next review.',
          timestamp: '32m ago',
          icon: Icons.flag_circle,
          isRead: true,
        ),
        NotificationItem(
          id: 'n3',
          title: 'Payment cleared',
          body: 'Maison Perle cleared invoice #AT-932. Production can begin.',
          timestamp: '1h ago',
          icon: Icons.payments,
          isRead: false,
        ),
        NotificationItem(
          id: 'n4',
          title: 'Fabric delivery delayed',
          body: 'Silk batch for Maison Perle will arrive tomorrow 2PM.',
          timestamp: 'Yesterday',
          icon: Icons.warning_amber,
          isRead: true,
        ),
      ]);

  void markAllRead() {
    state = [for (final item in state) item.copyWith(isRead: true)];
  }

  void markAsRead(String id) {
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

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final notificationListProvider =
    StateNotifierProvider<NotificationController, List<NotificationItem>>(
      (ref) => NotificationController(),
    );
