import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationItem {
  const NotificationItem({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.icon,
  });

  final String title;
  final String body;
  final String timestamp;
  final IconData icon;
}

final notificationListProvider = Provider<List<NotificationItem>>(
  (ref) => const [
    NotificationItem(
      title: 'Fitting confirmed',
      body: 'Alina Ross confirmed her couture fitting for Friday 10AM.',
      timestamp: '5m ago',
      icon: Icons.event_available,
    ),
    NotificationItem(
      title: 'Goal milestone unlocked',
      body: 'Bridal pipeline reached 60%. Keep momentum for next review.',
      timestamp: '32m ago',
      icon: Icons.flag_circle,
    ),
    NotificationItem(
      title: 'Payment cleared',
      body: 'Maison Perle cleared invoice #AT-932. Production can begin.',
      timestamp: '1h ago',
      icon: Icons.payments,
    ),
  ],
);
