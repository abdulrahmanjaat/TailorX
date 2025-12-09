import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/services/session_service.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/currency_service.dart';

class AuthRepository {
  AuthRepository({
    required this.firebaseAuth,
    required this.secureStorage,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth firebaseAuth;
  final SecureStorageService secureStorage;
  final FirebaseFirestore _firestore;

  /// Update currency symbol based on detected country:
  /// 1) Provided countryCode (preferred)
  /// 2) Phone number dial code (best-effort)
  /// 3) Location service fallback
  Future<void> _updateCurrency({String? countryCode, String? phone}) async {
    try {
      String? finalCountry = countryCode;

      // If no countryCode provided, try inferring from phone
      if ((finalCountry == null || finalCountry.isEmpty) && phone != null) {
        final inferred = CurrencyService.instance.inferCountryCodeFromPhone(
          phone,
        );
        if (inferred != null && inferred.isNotEmpty) {
          finalCountry = inferred;
        }
      }

      // If still no country, try location service (may prompt permission)
      if (finalCountry == null || finalCountry.isEmpty) {
        finalCountry = await LocationService.instance.getCountryCode();
      }

      if (finalCountry != null && finalCountry.isNotEmpty) {
        await secureStorage.setCountryCode(finalCountry);
        final symbol = CurrencyService.instance.getCurrencySymbol(finalCountry);
        await secureStorage.setCurrencySymbol(symbol);
      } else {
        // As a last resort, ensure currency symbol from existing stored country
        await LocationService.instance.ensureCurrencySymbol();
      }
    } catch (e) {
      debugPrint('Currency update failed: $e');
    }
  }

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

        // CRITICAL: Clear old profile data before setting new user data
        // This prevents showing cached data from previous user when switching accounts
        final previousUserId = await secureStorage.getUserId();
        if (previousUserId != null && previousUserId != userId) {
          // Different user - clear all old profile data
          await secureStorage.clearProfileData();
        } else if (previousUserId == null) {
          // First time signup - ensure clean state
          await secureStorage.clearProfileData();
        }

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

      // Update currency symbol based on country/phone if provided
      await _updateCurrency(
        countryCode: await secureStorage.getCountryCode(),
        phone: phone,
      );

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

        // CRITICAL: Always clear old profile data when switching users
        // This prevents showing cached data from a different account
        if (storedUserId != null && storedUserId != currentUserId) {
          await secureStorage.clearProfileData();
        } else if (storedUserId == null) {
          // First time login - ensure clean state
          await secureStorage.clearProfileData();
        }

        await secureStorage.setLoggedIn(true);
        await secureStorage.setUserId(currentUserId);
        await secureStorage.setUserEmail(userCredential.user!.email ?? email);
        // Mark onboarding as seen after login
        await secureStorage.setHasSeenOnboarding(true);
        // Start new session (for first fitting time tracking)
        await SessionService.instance.startSession();

        // Fetch and sync fresh profile from Firestore after login
        // CRITICAL: Always fetch from Firestore based on current UID
        try {
          final profileDoc = await _firestore.doc('users/$currentUserId').get();
          if (profileDoc.exists) {
            final data = profileDoc.data();
            if (data != null) {
              final name = data['name'] as String? ?? '';
              final shopName = data['shopName'] as String? ?? '';
              final phone = data['phone'] as String? ?? '';
              // Always overwrite with Firestore data to ensure consistency
              await secureStorage.setUserName(name);
              await secureStorage.setShopName(shopName);
              if (phone.isNotEmpty) {
                await secureStorage.write('phone', phone);
              } else {
                // Clear phone if not in Firestore
                await secureStorage.delete('phone');
              }
            }
          } else {
            // CRITICAL: No Firestore profile exists - clear all profile data
            // This prevents showing old cached data from previous account
            await secureStorage.delete('userName');
            await secureStorage.delete('shopName');
            await secureStorage.delete('phone');
            await secureStorage.delete('user_profile');
          }
        } catch (e) {
          // Log error but don't fail login if Firestore fetch fails
          debugPrint('Error fetching profile from Firestore: $e');
          // On error, clear profile data to prevent showing stale data
          await secureStorage.delete('userName');
          await secureStorage.delete('shopName');
          await secureStorage.delete('phone');
        }

        // Update currency symbol using stored country code or phone (if present in Firestore)
        try {
          String? phoneFromProfile;
          try {
            final profileDoc = await _firestore
                .doc('users/$currentUserId')
                .get();
            if (profileDoc.exists) {
              final data = profileDoc.data();
              phoneFromProfile = data?['phone'] as String?;
            }
          } catch (_) {
            // ignore
          }
          await _updateCurrency(
            countryCode: await secureStorage.getCountryCode(),
            phone: phoneFromProfile,
          );
        } catch (_) {
          // ignore currency errors
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

      try {
        // Sign out from Google Sign-In only if currently signed in
        final isSignedIn = await googleSignIn.isSignedIn();
        if (isSignedIn) {
          await googleSignIn.signOut();
          // Some platforms throw "Failed to disconnect" — ignore and proceed
          try {
            await googleSignIn.disconnect();
          } catch (e) {
            debugPrint('Google disconnect ignored: $e');
          }
        }
      } catch (e) {
        // Swallow Google sign-out issues so Firebase sign-out still executes
        debugPrint('Google sign-out warning: $e');
      }

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
      // Validate email format first
      final trimmedEmail = email.trim().toLowerCase();
      if (trimmedEmail.isEmpty) {
        throw Exception('Email address is required.');
      }

      // Firebase Auth will send the email even if user doesn't exist (for security)
      // This prevents email enumeration attacks
      // Use default settings for better reliability
      // The email will contain a link that opens in the default browser
      await firebaseAuth.sendPasswordResetEmail(email: trimmedEmail);

      debugPrint('Password reset email sent successfully to: $trimmedEmail');
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase Auth error during password reset: ${e.code} - ${e.message}',
      );
      throw _handlePasswordResetException(e);
    } catch (e) {
      debugPrint('Unexpected error during password reset: $e');
      throw Exception(
        'Failed to send password reset email. Please try again later.',
      );
    }
  }

  /// Handle Firebase Auth exceptions specifically for password reset
  String _handlePasswordResetException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid. Please check and try again.';
      case 'user-not-found':
        // Firebase doesn't actually throw this for password reset (security),
        // but handle it just in case
        return 'If an account exists with this email, a password reset link has been sent.';
      case 'too-many-requests':
        return 'Too many password reset requests. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'Password reset is not enabled. Please contact support at tailorxteam@gmail.com';
      case 'quota-exceeded':
        return 'Email sending quota exceeded. Please try again later or contact support.';
      default:
        debugPrint('Unhandled password reset error: ${e.code} - ${e.message}');
        return 'Failed to send password reset email. Please try again or contact support at tailorxteam@gmail.com';
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

  /// Sign in with Google and tell the UI whether we still need profile details
  ///
  /// The Firestore user document is only created after the UI collects
  /// the required profile fields (name, shopName, phone). This method
  /// only authenticates and checks what is missing.
  Future<GoogleAuthResult> signInWithGoogle() async {
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

      if (userCredential.user == null) {
        throw Exception('Google authentication failed. Please try again.');
      }

      final user = userCredential.user!;
      final userId = user.uid;
      final userEmail = user.email ?? '';
      final userName = user.displayName ?? '';
      final photoUrl = user.photoURL ?? '';
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // CRITICAL: Clear old user data before setting new user data
      // This prevents showing cached data from previous user when switching accounts
      final previousUserId = await secureStorage.getUserId();
      if (previousUserId != null && previousUserId != userId) {
        // Different user - clear all old profile data
        await secureStorage.clearProfileData();
      } else if (previousUserId == null) {
        // First time login - ensure clean state
        await secureStorage.clearProfileData();
      }

      // Persist basic auth session locally so we stay signed in while
      // collecting profile details.
      await secureStorage.setLoggedIn(true);
      await secureStorage.setUserId(userId);
      await secureStorage.setUserEmail(userEmail);

      // Check if user document exists and whether required fields are present
      final userDocRef = _firestore.doc('users/$userId');
      final userDoc = await userDocRef.get();
      final existingData = userDoc.data();

      final existingName = existingData?['name'] as String? ?? '';
      final existingShopName = existingData?['shopName'] as String? ?? '';
      final existingPhone = existingData?['phone'] as String? ?? '';

      final needsProfileCompletion =
          !userDoc.exists ||
          existingName.isEmpty ||
          existingShopName.isEmpty ||
          existingPhone.isEmpty;

      // Update currency symbol using existing phone/country if available
      try {
        await _updateCurrency(
          countryCode: await secureStorage.getCountryCode(),
          phone: existingPhone.isNotEmpty ? existingPhone : null,
        );
      } catch (_) {
        // ignore currency errors
      }

      if (!needsProfileCompletion) {
        // User has completed profile previously, sync fresh data from Firestore
        // Always overwrite with Firestore data to ensure consistency
        await secureStorage.setUserName(existingName);
        await secureStorage.setShopName(existingShopName);
        if (existingPhone.isNotEmpty) {
          await secureStorage.write('phone', existingPhone);
        }
        await secureStorage.setHasSeenOnboarding(true);
        await SessionService.instance.startSession();
      } else {
        // New user or incomplete profile - clear any stale data
        await secureStorage.delete('userName');
        await secureStorage.delete('shopName');
        await secureStorage.delete('phone');
      }

      return GoogleAuthResult(
        credential: userCredential,
        uid: userId,
        email: userEmail,
        displayName: existingName.isNotEmpty ? existingName : userName,
        photoUrl: photoUrl,
        needsProfileCompletion: needsProfileCompletion,
        existingShopName: existingShopName,
        existingPhone: existingPhone,
        isNewUser: isNewUser || !userDoc.exists,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      // Check for network/connection errors first - show simple message
      if (errorString.contains('network_error') ||
          errorString.contains('network') ||
          errorString.contains('connection') ||
          errorString.contains('internet') ||
          errorString.contains('unable to resolve') ||
          errorString.contains('failed to connect') ||
          errorString.contains('socketexception') ||
          errorString.contains('timeout')) {
        throw Exception(
          'No internet connection. Please check your network and try again.',
        );
      }

      // Check if user cancelled the sign-in
      if (errorString.contains('cancelled') ||
          errorString.contains('canceled') ||
          errorString.contains('sign_in_canceled')) {
        throw Exception('Sign in was cancelled.');
      }

      // For other PlatformException errors, show simple message
      if (errorString.contains('platformexception')) {
        if (errorString.contains('sign_in_failed') ||
            errorString.contains('apiexception')) {
          throw Exception(
            'Unable to sign in with Google. Please try again later.',
          );
        } else if (errorString.contains('google_sign_in')) {
          throw Exception(
            'Google Sign-In is not available. Please try again later.',
          );
        }
      }

      // Generic error message for anything else
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Persist Google user's required profile fields to Firestore and secure storage
  Future<void> completeGoogleProfile({
    required String uid,
    required String email,
    required String name,
    required String shopName,
    required String phone,
    String? photoUrl,
    bool isNewUser = false,
  }) async {
    try {
      final userRef = _firestore.doc('users/$uid');

      await userRef.set({
        'name': name.trim(),
        'shopName': shopName.trim(),
        'email': email.toLowerCase().trim(),
        'phone': phone.trim(),
        'uid': uid,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        if (isNewUser) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save to secure storage for quick access
      await secureStorage.setUserName(name.trim());
      await secureStorage.setShopName(shopName.trim());
      if (phone.isNotEmpty) {
        await secureStorage.write('phone', phone.trim());
      }
      await secureStorage.setHasSeenOnboarding(true);
      await SessionService.instance.startSession();

      // Update currency symbol using phone/country
      await _updateCurrency(
        countryCode: await secureStorage.getCountryCode(),
        phone: phone,
      );
    } on FirebaseException catch (e) {
      throw Exception(
        'Could not save your profile right now. Please try again. (${e.code})',
      );
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

class GoogleAuthResult {
  GoogleAuthResult({
    required this.credential,
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.needsProfileCompletion,
    required this.isNewUser,
    this.existingShopName,
    this.existingPhone,
  });

  final UserCredential credential;
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool needsProfileCompletion;
  final bool isNewUser;
  final String? existingShopName;
  final String? existingPhone;
}
