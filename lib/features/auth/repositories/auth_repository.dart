import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/services/secure_storage_service.dart';

class AuthRepository {
  AuthRepository({
    required this.firebaseAuth,
    required this.secureStorage,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth firebaseAuth;
  final SecureStorageService secureStorage;
  final FirebaseFirestore _firestore;

  /// Get current user
  User? get currentUser => firebaseAuth.currentUser;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? userName,
    String? shopName,
    String? phoneNumber,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to secure storage and Firestore
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final userId = user.uid;
        final userEmail = user.email ?? email;

        await secureStorage.setLoggedIn(true);
        await secureStorage.setUserId(userId);
        await secureStorage.setUserEmail(userEmail);
        if (userName != null && userName.isNotEmpty) {
          await secureStorage.setUserName(userName);
        }
        if (shopName != null && shopName.isNotEmpty) {
          await secureStorage.setShopName(shopName);
        }
        // Store phone number for profile and login mapping
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          await secureStorage.write('phone', phoneNumber);
          await secureStorage.write('phone_$phoneNumber', email);
        }
        // Mark onboarding as seen after signup
        await secureStorage.setHasSeenOnboarding(true);

        // Save profile to Firestore with all signup data
        try {
          await _firestore.doc('users/$userId').set({
            'name': userName ?? '',
            'shopName': shopName ?? '',
            'phone': phoneNumber ?? '',
            'email': userEmail,
            'uid': userId,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          // Log error but don't fail signup if Firestore save fails
          print('Error saving profile to Firestore: $e');
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Sign in with email and password (or phone number)
  Future<UserCredential> signIn({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      // Check if input is phone number (starts with + or is all digits)
      String email = emailOrPhone;
      if (!emailOrPhone.contains('@')) {
        // Likely a phone number, try to find associated email
        final storedEmail = await secureStorage.read('phone_$emailOrPhone');
        if (storedEmail != null && storedEmail.isNotEmpty) {
          email = storedEmail;
        } else {
          // If phone not found, try as email anyway (will fail with proper error)
          email = emailOrPhone;
        }
      }

      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to secure storage
      if (userCredential.user != null) {
        final currentUserId = userCredential.user!.uid;
        final storedUserId = await secureStorage.getUserId();

        // If logging in with a different user, clear old user's profile data
        if (storedUserId != null && storedUserId != currentUserId) {
          await secureStorage.delete('userName');
          await secureStorage.delete('shopName');
        }

        await secureStorage.setLoggedIn(true);
        await secureStorage.setUserId(currentUserId);
        await secureStorage.setUserEmail(userCredential.user!.email ?? email);
        // Mark onboarding as seen after login
        await secureStorage.setHasSeenOnboarding(true);

        // Fetch and sync profile from Firestore after login
        try {
          final profileDoc = await _firestore.doc('users/$currentUserId').get();
          if (profileDoc.exists) {
            final data = profileDoc.data();
            if (data != null) {
              final name = data['name'] as String? ?? '';
              final shopName = data['shopName'] as String? ?? '';
              final phone = data['phone'] as String? ?? '';
              if (name.isNotEmpty) {
                await secureStorage.setUserName(name);
              }
              if (shopName.isNotEmpty) {
                await secureStorage.setShopName(shopName);
              }
              if (phone.isNotEmpty) {
                await secureStorage.write('phone', phone);
              }
            }
          }
        } catch (e) {
          // Log error but don't fail login if Firestore fetch fails
          print('Error fetching profile from Firestore: $e');
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Sign out
  ///
  /// IMPORTANT: This method only clears local secure storage and Firebase Auth session.
  /// It does NOT delete Firestore data. All customer, order, and measurement data
  /// remains in Firestore under the user's UID path (users/{uid}/...).
  /// When the user logs back in, they will see their same data because it's scoped
  /// to their UID. This is the correct behavior for data persistence.
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
      // Clear auth data from secure storage (local only)
      // NOTE: Firestore data is NOT deleted - it remains under users/{uid}/...
      // This ensures data persistence across login sessions
      await secureStorage.clearAuthData();
      // Reset onboarding flag so it shows again after logout
      await secureStorage.setHasSeenOnboarding(false);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Re-authenticate user with email and password (required for sensitive operations)
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Create credential for re-authentication
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Re-authenticate the user
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Re-authentication failed: $e');
    }
  }

  /// Delete user account permanently (requires re-authentication first)
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // First, re-authenticate the user
      await reauthenticate(email: email, password: password);

      // Then delete the Firebase user account
      await user.delete();

      // Clear all user data from secure storage (including profile data)
      await secureStorage.clearAllUserData();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please enter the correct password.';
      case 'invalid-credential':
      case 'invalid-email':
        // Check if it's a password error by checking the message
        if (e.message?.toLowerCase().contains('password') == true ||
            e.message?.toLowerCase().contains('credential') == true) {
          return 'Incorrect password. Please enter the correct password.';
        }
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        // Check message for password-related errors
        final message = e.message?.toLowerCase() ?? '';
        if (message.contains('password') ||
            message.contains('credential') ||
            message.contains('incorrect') ||
            message.contains('wrong')) {
          return 'Incorrect password. Please enter the correct password.';
        }
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
