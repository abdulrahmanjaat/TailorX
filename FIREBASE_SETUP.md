# Firebase Authentication Setup Guide

This guide will walk you through setting up Firebase Authentication in your TailorX Flutter app.

## Prerequisites

1. **Firebase CLI installed**: If not installed, run:
   ```bash
   npm install -g firebase-tools
   ```

2. **FlutterFire CLI installed**: If not installed, run:
   ```bash
   dart pub global activate flutterfire_cli
   ```

3. **Firebase Project**: You need a Firebase project with ID `tailorx-jaat001` (or update the project ID in commands below)

## Step-by-Step Setup

### Step 1: Login to Firebase

```bash
firebase login
```

This will open a browser window for you to authenticate with your Google account.

### Step 2: Initialize Firebase in Your Project

Navigate to your project root and run:

```bash
cd d:\TailorX\tailorx_app
firebase init
```

**When prompted:**
- Select **Authentication** (use spacebar to select, then Enter)
- Select **Firestore** (use spacebar to select, then Enter)
- Select **Storage** (use spacebar to select, then Enter)
- Select your Firebase project: `tailorx-jaat001`
- For other prompts, use default options

### Step 3: Configure FlutterFire

Run the FlutterFire configuration command:

```bash
flutterfire configure --project=tailorx-jaat001 --android --web
```

**This command will:**
- Generate `lib/firebase_options.dart` with your Firebase configuration
- Configure Android and Web platforms
- Set up all necessary Firebase files

### Step 4: Enable Email/Password Authentication in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `tailorx-jaat001`
3. Navigate to **Authentication** → **Sign-in method**
4. Enable **Email/Password** provider
5. Click **Save**

### Step 5: Verify Setup

After running the commands above, verify that:

1. ✅ `lib/firebase_options.dart` exists and is properly generated
2. ✅ `android/app/google-services.json` exists (for Android)
3. ✅ `web/index.html` has Firebase SDK scripts (for Web)
4. ✅ All packages are installed: `flutter pub get`

## Project Structure

After setup, your authentication structure will be:

```
lib/
├── firebase_options.dart          # Generated Firebase config
├── features/
│   └── auth/
│       ├── repositories/
│       │   └── auth_repository.dart    # Firebase auth methods
│       ├── services/
│       │   └── auth_service.dart       # Riverpod providers
│       ├── screens/
│       │   ├── login_screen.dart       # Login with Firebase
│       │   └── signup_screen.dart      # Signup with Firebase
│       └── widgets/
│           └── forgot_password_sheet.dart  # Password reset
├── shared/
│   └── services/
│       └── secure_storage_service.dart  # Secure storage for auth flags
└── core/
    └── middleware/
        └── auth_middleware.dart         # Navigation middleware
```

## How It Works

### Authentication Flow

1. **First Launch**: User sees onboarding → Login/Signup
2. **After Signup/Login**: 
   - User credentials saved to Firebase
   - `isLoggedIn`, `userId`, `userEmail` saved to Secure Storage
   - `hasSeenOnboarding` set to `true`
   - User redirected to Home screen
3. **Subsequent Launches**: 
   - Checks `hasSeenOnboarding` → if true, skip onboarding
   - Checks `isLoggedIn` → if true, go to Home; if false, go to Login
4. **On Logout**:
   - Firebase sign out
   - Clear Secure Storage auth data
   - Reset `hasSeenOnboarding` to `false`
   - Redirect to Onboarding

### Secure Storage Keys

- `isLoggedIn`: Boolean flag (true/false)
- `userId`: Firebase user UID
- `userEmail`: User's email address
- `hasSeenOnboarding`: Boolean flag (true/false)

### Auth Repository Methods

- `signUp(email, password)`: Create new user account
- `signIn(email, password)`: Sign in existing user
- `signOut()`: Sign out current user
- `resetPassword(email)`: Send password reset email
- `authStateChanges`: Stream of auth state changes

## Testing

1. **Test Signup**:
   - Navigate to Signup screen
   - Enter email and password
   - Should create account and redirect to Home

2. **Test Login**:
   - Navigate to Login screen
   - Enter credentials
   - Should sign in and redirect to Home

3. **Test Logout**:
   - Click logout in Profile or Settings
   - Should sign out and redirect to Onboarding

4. **Test Password Reset**:
   - Click "Forgot Password?" on Login screen
   - Enter email
   - Check email for reset link

5. **Test Middleware**:
   - Close and reopen app
   - Should skip onboarding if already seen
   - Should go to Home if logged in
   - Should go to Login if not logged in

## Troubleshooting

### Error: "DefaultFirebaseOptions have not been configured"

**Solution**: Run `flutterfire configure --project=tailorx-jaat001 --android --web`

### Error: "PlatformException" or Firebase not initialized

**Solution**: 
1. Verify `firebase_options.dart` is generated
2. Check that Firebase is initialized in `main.dart`
3. Ensure all packages are installed: `flutter pub get`

### Error: "Email already in use" or "User not found"

**Solution**: These are expected Firebase errors. The app handles them with user-friendly messages.

### Onboarding shows every time

**Solution**: Check that `hasSeenOnboarding` is being saved to Secure Storage after completing onboarding.

## Next Steps

After Firebase Authentication is working:

1. ✅ Test all auth flows
2. ✅ Verify Secure Storage is working
3. ✅ Test on both Android and Web
4. ⏭️ Next: Set up Firestore for data persistence (orders, customers, measurements)
5. ⏭️ Next: Set up Storage for file uploads (profile images, receipts)

## Important Notes

- **iOS is NOT configured** - Only Android and Web are set up
- **Data is currently in memory** - Firestore integration needed for persistence
- **Email sending** - Currently uses placeholder service, needs backend integration
- **Secure Storage** - Uses `flutter_secure_storage` for encrypted local storage

## Support

If you encounter issues:

1. Check Firebase Console for authentication errors
2. Verify all CLI commands completed successfully
3. Check that `firebase_options.dart` is properly generated
4. Ensure all dependencies are installed: `flutter pub get`

