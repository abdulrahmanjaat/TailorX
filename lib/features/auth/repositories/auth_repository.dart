import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/services/session_service.dart';

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
    String? phone,
  }) async {
    try {
      // Create user account - Firebase Auth will automatically prevent duplicate emails
      // by throwing 'email-already-in-use' error if the email exists
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
        // Mark onboarding as seen after signup
        await secureStorage.setHasSeenOnboarding(true);

        // Save profile to Firestore with all signup data
        // Note: User is authenticated after createUserWithEmailAndPassword
        // so Firestore write should succeed. If it fails, we log but don't fail signup.
        try {
          // Ensure user is authenticated and get fresh token
          final currentUser = firebaseAuth.currentUser;
          if (currentUser != null) {
            // Force token refresh to ensure Firestore recognizes the auth
            await currentUser.getIdToken(true);

            await _firestore.doc('users/$userId').set({
              'name': userName ?? '',
              'shopName': shopName ?? '',
              'email': userEmail.toLowerCase().trim(),
              'phone': phone ?? '',
              'uid': userId,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } else {
            debugPrint(
              'Warning: User not authenticated when trying to save to Firestore',
            );
          }
        } on FirebaseException catch (e) {
          // Log Firestore errors but don't fail signup
          // The user account is already created in Firebase Auth
          debugPrint(
            'Firestore error saving profile: ${e.code} - ${e.message}',
          );
        } catch (e) {
          // Catch any other errors
          debugPrint('Error saving profile to Firestore: $e');
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
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
        // Start new session (for first fitting time tracking)
        await SessionService.instance.startSession();

        // Fetch and sync profile from Firestore after login
        try {
          final profileDoc = await _firestore.doc('users/$currentUserId').get();
          if (profileDoc.exists) {
            final data = profileDoc.data();
            if (data != null) {
              final name = data['name'] as String? ?? '';
              final shopName = data['shopName'] as String? ?? '';
              if (name.isNotEmpty) {
                await secureStorage.setUserName(name);
              }
              if (shopName.isNotEmpty) {
                await secureStorage.setShopName(shopName);
              }
            }
          }
        } catch (e) {
          // Log error but don't fail login if Firestore fetch fails
          debugPrint('Error fetching profile from Firestore: $e');
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
      // Disconnect Google Sign-In to ensure account picker shows on next login
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '61258568836-593ic09mlfcc7vq3r73qs4g5akmolqtr.apps.googleusercontent.com',
      );

      // Sign out from Google Sign-In
      await googleSignIn.signOut();
      // Disconnect to clear cached account
      await googleSignIn.disconnect();

      // Sign out from Firebase Auth
      await firebaseAuth.signOut();

      // Clear auth data from secure storage (local only)
      // NOTE: Firestore data is NOT deleted - it remains under users/{uid}/...
      // This ensures data persistence across login sessions
      await secureStorage.clearAuthData();
      // Reset onboarding flag so it shows again after logout
      await secureStorage.setHasSeenOnboarding(false);
      // Clear session data (first fitting time, etc.)
      await SessionService.instance.clearSession();
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

  /// Sign in with Google
  ///
  /// Always shows the account picker by creating a fresh GoogleSignIn instance
  /// and ensuring any previous session is cleared before signing in.
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Create a fresh GoogleSignIn instance to ensure account picker always shows
      // forceCodeForRefreshToken: true ensures account selection dialog appears
      final GoogleSignIn googleSignIn = GoogleSignIn(
        forceCodeForRefreshToken: true,
        scopes: ['email', 'profile'],
        // Use the web client ID from google-services.json
        // Client ID: 61258568836-593ic09mlfcc7vq3r73qs4g5akmolqtr.apps.googleusercontent.com
        serverClientId:
            '61258568836-593ic09mlfcc7vq3r73qs4g5akmolqtr.apps.googleusercontent.com',
      );

      // Ensure any previous Google Sign-In session is cleared
      // This ensures the account picker always shows
      await googleSignIn.signOut();

      // This will always show the account picker
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in was cancelled.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      // Save user data to secure storage and Firestore
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final userId = user.uid;
        final userEmail = user.email ?? '';
        final userName = user.displayName ?? '';
        final photoUrl = user.photoURL ?? '';

        await secureStorage.setLoggedIn(true);
        await secureStorage.setUserId(userId);
        await secureStorage.setUserEmail(userEmail);
        if (userName.isNotEmpty) {
          await secureStorage.setUserName(userName);
        }
        // Mark onboarding as seen after login
        await secureStorage.setHasSeenOnboarding(true);
        // Start new session (for first fitting time tracking)
        await SessionService.instance.startSession();

        // Check if user document exists in Firestore
        final userDoc = await _firestore.doc('users/$userId').get();

        if (!userDoc.exists) {
          // Create new user document if it doesn't exist
          await _firestore.doc('users/$userId').set({
            'name': userName,
            'shopName': '',
            'email': userEmail.toLowerCase().trim(),
            'uid': userId,
            'photoUrl': photoUrl,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          // Update existing user document
          final data = userDoc.data();
          if (data != null) {
            final name = data['name'] as String? ?? '';
            final shopName = data['shopName'] as String? ?? '';
            if (name.isNotEmpty) {
              await secureStorage.setUserName(name);
            }
            if (shopName.isNotEmpty) {
              await secureStorage.setShopName(shopName);
            }
            // Update email and photo if changed
            await _firestore.doc('users/$userId').update({
              'email': userEmail.toLowerCase().trim(),
              'photoUrl': photoUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      final errorString = e.toString();
      // Provide helpful error message for common Google Sign-In setup issues
      if (errorString.contains('PlatformException')) {
        if (errorString.contains('sign_in_failed') ||
            errorString.contains('ApiException')) {
          throw Exception(
            'Google Sign-In failed. Please ensure:\n'
            '1. Google Play Services is installed and up to date on your device\n'
            '2. You have an active internet connection\n'
            '3. SHA-1 and SHA-256 fingerprints are added to Firebase Console\n'
            '4. Android OAuth client is created in Firebase Console\n'
            'Error: $errorString',
          );
        } else if (errorString.contains('google_sign_in')) {
          throw Exception(
            'Google Sign-In is not properly configured. Please ensure:\n'
            '1. SHA-1 and SHA-256 fingerprints are added to Firebase Console\n'
            '2. Google Sign-In is enabled in Firebase Authentication\n'
            '3. A new google-services.json file is downloaded and added to android/app/\n'
            'Error: $errorString',
          );
        }
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'This email is already registered.';
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
