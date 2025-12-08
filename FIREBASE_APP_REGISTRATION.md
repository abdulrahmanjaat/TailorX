# Firebase App Registration Guide

## Option 1: Install Firebase CLI and Run Commands (Recommended)

### Step 1: Install Firebase CLI

**For Windows (using npm):**
```powershell
# Install Node.js first if not installed: https://nodejs.org/
# Then install Firebase CLI globally
npm install -g firebase-tools

# Verify installation
firebase --version
```

**Alternative: Install via PowerShell (if npm not available):**
```powershell
# Install via npm (requires Node.js)
npm install -g firebase-tools
```

### Step 2: Login to Firebase
```powershell
firebase login
```

### Step 3: Register Android App
```powershell
firebase apps:create ANDROID --package-name=com.abdulrahman.tailorx --project=tailorx-jaat001
```

**Expected Output:**
```
✔ Android app created successfully!
App ID: 1:61258568836:android:XXXXXXXXXXXXX
```

**Save the App ID** - You'll need it for the next steps.

### Step 4: Register Web App
```powershell
firebase apps:create WEB --project=tailorx-jaat001
```

**Expected Output:**
```
✔ Web app created successfully!
App ID: 1:61258568836:web:XXXXXXXXXXXXX
```

### Step 5: Download google-services.json
```powershell
# Replace ANDROID_APP_ID with the actual App ID from Step 3
firebase apps:sdkconfig ANDROID --project=tailorx-jaat001 --out=android/app/google-services.json
```

### Step 6: Regenerate firebase_options.dart
```powershell
flutterfire configure --project=tailorx-jaat001 --android-package-name=com.abdulrahman.tailorx --platforms=android,web --yes --overwrite-firebase-options
```

---

## Option 2: Manual Registration via Firebase Console (No CLI Required)

### Step 1: Register Android App

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **tailorx-jaat001**
3. Click the **⚙️ Settings** icon → **Project settings**
4. Scroll down to **Your apps** section
5. Click **Add app** → Select **Android** icon
6. Enter package name: `com.abdulrahman.tailorx`
7. Enter app nickname (optional): `TailorX Android`
8. Click **Register app**
9. **Download `google-services.json`**
10. Place it in: `android/app/google-services.json` (replace existing file)

### Step 2: Register Web App

1. In the same **Project settings** page
2. Click **Add app** → Select **Web** icon (</>)
3. Enter app nickname (optional): `TailorX Web`
4. Click **Register app**
5. **Copy the Firebase configuration** (you'll need this for `firebase_options.dart`)

### Step 3: Update firebase_options.dart

After registering both apps, you need to update `lib/firebase_options.dart` with the new app IDs.

**From Firebase Console:**
- Android App ID: Found in Project settings → Your apps → Android app
- Web App ID: Found in Project settings → Your apps → Web app

**Update the file:**
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: '1:61258568836:android:NEW_ANDROID_APP_ID', // ← Update this
  messagingSenderId: '61258568836',
  projectId: 'tailorx-jaat001',
  storageBucket: 'tailorx-jaat001.firebasestorage.app',
);

static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: '1:61258568836:web:NEW_WEB_APP_ID', // ← Update this
  messagingSenderId: '61258568836',
  projectId: 'tailorx-jaat001',
  authDomain: 'tailorx-jaat001.firebaseapp.com',
  storageBucket: 'tailorx-jaat001.firebasestorage.app',
  measurementId: 'G-XXXXXXXXXX',
);
```

---

## Step 4: Add SHA-1 and SHA-2 Fingerprints (For Google Sign-In)

### Get Your SHA Fingerprints:

```powershell
# For debug keystore
keytool -list -v -keystore android/app/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore (if you have one)
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

### Add to Firebase Console:

1. Go to Firebase Console → Project Settings
2. Select your Android app (`com.abdulrahman.tailorx`)
3. Scroll to **SHA certificate fingerprints**
4. Click **Add fingerprint**
5. Paste your SHA-1 and SHA-256 fingerprints
6. Click **Save**

---

## Step 5: Verify Configuration

After completing the setup:

```powershell
# Clean and rebuild
flutter clean
flutter pub get

# Test build
flutter build apk --debug
```

---

## Quick Command Reference (After Installing Firebase CLI)

```powershell
# 1. Login
firebase login

# 2. Register Android app
firebase apps:create ANDROID --package-name=com.abdulrahman.tailorx --project=tailorx-jaat001

# 3. Register Web app
firebase apps:create WEB --project=tailorx-jaat001

# 4. Download google-services.json (replace ANDROID_APP_ID)
firebase apps:sdkconfig ANDROID --project=tailorx-jaat001 --out=android/app/google-services.json

# 5. Configure FlutterFire
flutterfire configure --project=tailorx-jaat001 --android-package-name=com.abdulrahman.tailorx --platforms=android,web --yes --overwrite-firebase-options
```

---

## Troubleshooting

### Issue: "firebase command not found"
- **Solution**: Install Firebase CLI: `npm install -g firebase-tools`

### Issue: "Project not found"
- **Solution**: Make sure you're logged in: `firebase login`
- Verify project ID: `tailorx-jaat001`

### Issue: "App already exists"
- **Solution**: The app might already be registered. Check Firebase Console → Project Settings → Your apps

### Issue: Google Sign-In fails after setup
- **Solution**: 
  1. Add SHA-1 and SHA-256 fingerprints to Firebase Console
  2. Wait a few minutes for changes to propagate
  3. Rebuild the app

---

## Next Steps After Registration

1. ✅ Replace `android/app/google-services.json` with new file
2. ✅ Update `lib/firebase_options.dart` with new app IDs
3. ✅ Add SHA fingerprints for Google Sign-In
4. ✅ Run `flutter clean && flutter pub get`
5. ✅ Test build: `flutter build apk`
6. ✅ Test authentication, Firestore, Storage, and all features

---

**Status**: ⏳ **Waiting for Firebase CLI installation or manual registration**

