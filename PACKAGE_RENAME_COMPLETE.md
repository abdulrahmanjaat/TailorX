# Package Rename Complete: com.abdulrahman.tailorx_app → com.abdulrahman.tailorx

## ✅ Changes Applied

### 1. Android Package Name Updates

#### Files Modified:
- ✅ `android/app/build.gradle.kts`
  - `namespace`: `com.abdulrahman.tailorx_app` → `com.abdulrahman.tailorx`
  - `applicationId`: `com.abdulrahman.tailorx_app` → `com.abdulrahman.tailorx`

- ✅ `android/app/src/main/kotlin/com/abdulrahman/tailorx/MainActivity.kt` (moved and updated)
  - Package declaration: `package com.abdulrahman.tailorx`
  - Method channel: `com.abdulrahman.tailorx/gallery`
  - Old file deleted: `android/app/src/main/kotlin/com/abdulrahman/tailorx_app/MainActivity.kt`

- ✅ `lib/features/orders/screens/order_receipt_screen.dart`
  - Method channel references updated to `com.abdulrahman.tailorx/gallery`

#### Files Verified (No Changes Needed):
- ✅ `android/app/src/main/AndroidManifest.xml` - No package references
- ✅ `android/app/src/debug/AndroidManifest.xml` - No package references
- ✅ `android/app/src/profile/AndroidManifest.xml` - No package references

### 2. iOS Bundle Identifier
- ⚠️ iOS folder not found - No iOS configuration exists in this project

---

## 🔥 Firebase Setup Commands

### Step 1: Register Android App in Firebase

```bash
# Make sure you're in the project root directory
cd /path/to/tailorx_app

# Register Android app with the new package name
firebase apps:create ANDROID \
  --package-name=com.abdulrahman.tailorx \
  --project=tailorx-jaat001
```

**Expected Output:**
```
✔ Android app created successfully!
App ID: 1:61258568836:android:XXXXXXXXXXXXX
```

**Save the App ID** - You'll need it for the next steps.

### Step 2: Register Web App in Firebase

```bash
# Register Web app
firebase apps:create WEB \
  --project=tailorx-jaat001
```

**Expected Output:**
```
✔ Web app created successfully!
App ID: 1:61258568836:web:XXXXXXXXXXXXX
```

### Step 3: Download google-services.json

```bash
# Download the new google-services.json for Android
firebase apps:sdkconfig ANDROID \
  --project=tailorx-jaat001 \
  --out=android/app/google-services.json
```

**OR** manually download from Firebase Console:
1. Go to Firebase Console → Project Settings
2. Select the Android app with package name `com.abdulrahman.tailorx`
3. Download `google-services.json`
4. Replace `android/app/google-services.json`

### Step 4: Update Firebase Options (Dart)

```bash
# Regenerate firebase_options.dart with new app IDs
flutterfire configure \
  --project=tailorx-jaat001 \
  --platforms=android,web \
  --out=lib/firebase_options.dart
```

**OR** manually update `lib/firebase_options.dart`:
- Update Android `appId` with the new Android app ID from Step 1
- Update Web `appId` with the new Web app ID from Step 2

### Step 5: Update firebase.json (if exists)

Update `firebase.json` with new app IDs:

```json
{
  "flutter": {
    "platforms": {
      "android": {
        "default": {
          "projectId": "tailorx-jaat001",
          "appId": "1:61258568836:android:NEW_ANDROID_APP_ID",
          "fileOutput": "android/app/google-services.json"
        }
      },
      "dart": {
        "lib/firebase_options.dart": {
          "projectId": "tailorx-jaat001",
          "configurations": {
            "android": "1:61258568836:android:NEW_ANDROID_APP_ID",
            "web": "1:61258568836:web:NEW_WEB_APP_ID"
          }
        }
      }
    }
  }
}
```

---

## 🧹 Clean and Rebuild

After all Firebase setup is complete, run:

```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Build APK to verify everything works
flutter build apk

# For debug build
flutter build apk --debug
```

---

## ✅ Verification Checklist

After completing the setup, verify:

- [ ] **Login/Signup Works**
  - Test email/password authentication
  - Test Google Sign-In
  - Verify user data saves to Firestore

- [ ] **Firestore Operations**
  - Create a customer → Verify it saves
  - Create an order → Verify it saves
  - Create a measurement → Verify it saves
  - Fetch data → Verify it loads correctly

- [ ] **Firebase Storage**
  - Upload an image → Verify upload succeeds
  - Download an image → Verify download works

- [ ] **Notifications (FCM)**
  - Send a test notification → Verify it receives

- [ ] **Web Version** (if applicable)
  - Load the web app → Verify it works
  - Test authentication on web

- [ ] **Method Channel**
  - Save receipt to gallery → Verify it works
  - Check Android version → Verify it returns correctly

---

## 📝 Important Notes

1. **SHA-1/SHA-256 Fingerprints**: 
   - You may need to add new SHA-1 and SHA-256 fingerprints to Firebase Console for Google Sign-In
   - Get fingerprints: `keytool -list -v -keystore android/app/debug.keystore -alias androiddebugkey -storepass android -keypass android`

2. **OAuth Client IDs**:
   - The new Android app will have new OAuth client IDs
   - Update `google-services.json` after downloading
   - Update `firebase_options.dart` with new app IDs

3. **Firebase Rules**:
   - All existing Firestore and Storage rules remain intact
   - No changes needed to security rules

4. **Data Migration**:
   - All existing data in Firestore remains under the same project
   - Users will need to sign up again (or you can migrate user accounts)
   - Customer, Order, and Measurement data structure remains the same

---

## 🚨 Troubleshooting

### Issue: "App not found" error
- **Solution**: Make sure you've created the Android app in Firebase Console first

### Issue: Google Sign-In fails
- **Solution**: 
  1. Add SHA-1 and SHA-256 fingerprints to Firebase Console
  2. Download new `google-services.json`
  3. Update OAuth client ID in code if hardcoded

### Issue: Build fails with package name error
- **Solution**: 
  1. Run `flutter clean`
  2. Delete `android/.gradle` folder
  3. Run `flutter pub get`
  4. Try building again

### Issue: Method channel not working
- **Solution**: 
  1. Verify MainActivity.kt is in correct package folder
  2. Verify method channel name matches in Dart code
  3. Rebuild the app completely

---

## 📋 Modified Files Summary

1. `android/app/build.gradle.kts` - Updated namespace and applicationId
2. `android/app/src/main/kotlin/com/abdulrahman/tailorx/MainActivity.kt` - Created with new package
3. `android/app/src/main/kotlin/com/abdulrahman/tailorx_app/MainActivity.kt` - Deleted (old)
4. `lib/features/orders/screens/order_receipt_screen.dart` - Updated method channel references

---

## 🎯 Next Steps

1. Run Firebase CLI commands above
2. Download new `google-services.json`
3. Update `firebase_options.dart`
4. Run `flutter clean && flutter pub get && flutter build apk`
5. Test all features thoroughly
6. Deploy to Play Store with new package name

---

**Package Rename Status**: ✅ **COMPLETE**

All Android package name references have been updated from `com.abdulrahman.tailorx_app` to `com.abdulrahman.tailorx`.

