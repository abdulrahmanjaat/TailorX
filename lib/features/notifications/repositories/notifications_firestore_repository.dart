import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../../../shared/services/secure_storage_service.dart';

class NotificationsFirestoreRepository {
  NotificationsFirestoreRepository({
    required this.firestore,
    required this.secureStorage,
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore firestore;
  final SecureStorageService secureStorage;
  final FirebaseAuth _firebaseAuth;

  /// Get the collection path for notifications (scoped to user)
  ///
  /// Returns: users/{uid}/notifications
  ///
  /// IMPORTANT: All notification data is scoped to the authenticated user's UID.
  /// This ensures:
  /// 1. Users can only see their own notifications
  /// 2. Data persists across login sessions
  /// 3. Multi-user isolation - no data leakage between users
  ///
  /// Uses Firebase Auth currentUser as primary source (required for Firestore rules)
  Future<String> _getCollectionPath() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      final userId = await secureStorage.getUserId();
      if (userId != null) {
        throw Exception(
          'Firebase Auth session expired. Please sign in again to continue.',
        );
      }
      throw Exception('User not authenticated. Please sign in to continue.');
    }
    // CRITICAL: Always use user-scoped path - never save at root level
    return 'users/${currentUser.uid}/notifications';
  }

  /// Convert NotificationModel to Firestore Map
  Map<String, dynamic> _toMap(NotificationModel notification) {
    return {
      'id': notification.id,
      'title': notification.title,
      'message': notification.message,
      'type': notification.type.value,
      'orderId': notification.orderId,
      'createdAt': Timestamp.fromDate(notification.createdAt),
      'isRead': notification.isRead,
    };
  }

  /// Create a new notification
  Future<void> createNotification(NotificationModel notification) async {
    final collectionPath = await _getCollectionPath();
    await firestore
        .collection(collectionPath)
        .doc(notification.id)
        .set(_toMap(notification));
  }

  /// Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    final collectionPath = await _getCollectionPath();
    final snapshot = await firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  /// Stream all notifications (real-time updates)
  Stream<List<NotificationModel>> streamAllNotifications() async* {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      yield <NotificationModel>[];
      return;
    }

    final collectionPath = await _getCollectionPath();
    yield* firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final collectionPath = await _getCollectionPath();
    await firestore.collection(collectionPath).doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final collectionPath = await _getCollectionPath();
    final snapshot = await firestore.collection(collectionPath).get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      if (doc.data()['isRead'] != true) {
        batch.update(doc.reference, {'isRead': true});
      }
    }

    await batch.commit();
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    final collectionPath = await _getCollectionPath();
    final snapshot = await firestore
        .collection(collectionPath)
        .where('isRead', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  /// Stream unread notifications count (real-time updates)
  Stream<int> streamUnreadCount() async* {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      yield 0;
      return;
    }

    try {
      final collectionPath = await _getCollectionPath();
      yield* firestore
          .collection(collectionPath)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      // If there's any error (permission denied, etc.), yield 0
      debugPrint('Error in streamUnreadCount: $e');
      yield 0;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final collectionPath = await _getCollectionPath();
    await firestore.collection(collectionPath).doc(notificationId).delete();
  }
}
