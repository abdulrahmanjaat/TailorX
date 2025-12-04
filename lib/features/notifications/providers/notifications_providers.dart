import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../repositories/notifications_firestore_repository.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../../../shared/services/secure_storage_service.dart';

/// Provider for NotificationsFirestoreRepository
final notificationsFirestoreRepositoryProvider =
    Provider<NotificationsFirestoreRepository>((ref) {
      return NotificationsFirestoreRepository(
        firestore: FirebaseFirestore.instance,
        secureStorage: SecureStorageService.instance,
      );
    });

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repository = ref.watch(notificationsFirestoreRepositoryProvider);
  return NotificationService(repository: repository);
});

/// Stream provider for real-time notifications
///
/// This provider streams notifications from Firestore in real-time.
/// It automatically refreshes when auth state changes (login/logout).
/// For new users with no notifications, it returns an empty list.
final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((
  ref,
) async* {
  // Watch auth state to automatically refresh when user logs in/out
  ref.watch(authStateProvider);

  // Check if user is authenticated
  final currentUser = FirebaseAuth.instance.currentUser;

  // If user is not authenticated, return empty list
  if (currentUser == null) {
    yield <NotificationModel>[];
    return;
  }

  // User is authenticated, start streaming notifications
  final repository = ref.watch(notificationsFirestoreRepositoryProvider);
  try {
    yield* repository.streamAllNotifications();
  } catch (e) {
    // If there's any error, yield empty list instead of propagating error
    debugPrint('Error in notificationsStreamProvider: $e');
    yield <NotificationModel>[];
  }
});

/// Stream provider for unread notifications count (real-time)
///
/// This provider streams the count of unread notifications in real-time.
/// It automatically refreshes when auth state changes (login/logout).
final unreadCountProvider = StreamProvider<int>((ref) async* {
  // Watch auth state to automatically refresh when user logs in/out
  ref.watch(authStateProvider);

  // Check if user is authenticated
  final currentUser = FirebaseAuth.instance.currentUser;

  // If user is not authenticated, return 0
  if (currentUser == null) {
    yield 0;
    return;
  }

  // User is authenticated, start streaming unread count
  final repository = ref.watch(notificationsFirestoreRepositoryProvider);
  try {
    yield* repository.streamUnreadCount();
  } catch (e) {
    // If there's any error, yield 0 instead of propagating error
    debugPrint('Error in unreadCountProvider: $e');
    yield 0;
  }
});
