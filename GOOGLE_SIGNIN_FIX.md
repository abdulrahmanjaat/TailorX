# Google Sign-In Error Fix

## Current Issue
Error: `PlatformException(sign_in_failed, com.google.android.gms.common.api.Api10:, null, null)`

## Root Cause
Your `google-services.json` file only has a **web OAuth client** (client_type: 3), but Android Google Sign-In also needs an **Android OAuth client** (client_type: 1) with SHA-1 fingerprint.

## Solution

### Step 1: Get Your SHA-1 Fingerprint

**Using Android Studio:**
1. Open Android Studio
2. Open Gradle panel (right side)
3. Navigate to: `android` > `app` > `Tasks` > `android` > `signingReport`
4. Double-click `signingReport`
5. Copy the **SHA-1** fingerprint (looks like: `A1:B2:C3:D4:...`)

**Using Command Line:**
```powershell
cd android
.\gradlew signingReport
```
Look for SHA-1 in the output under "Variant: debug" or "Variant: release"

### Step 2: Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **tailorx-jaat001**
3. Click ⚙️ (gear icon) → **Project settings**
4. Scroll to **Your apps** section
5. Find your Android app: `com.abdulrahman.tailorx_app`
6. Click **Add fingerprint**
7. Paste your **SHA-1** fingerprint
8. Click **Save**

### Step 3: Download Updated google-services.json

1. In Firebase Console → Project settings
2. Scroll to **Your apps** → Android app
3. Click the **download icon** to download `google-services.json`
4. **Replace** the file at `android/app/google-services.json`

### Step 4: Verify the New File

The new `google-services.json` should have **TWO** OAuth clients:
1. **Android client** (client_type: 1) with SHA-1 fingerprint
2. **Web client** (client_type: 3)

Example:
```json
"oauth_client": [
  {
    "client_id": "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com",
    "client_type": 1,
    "android_info": {
      "package_name": "com.abdulrahman.tailorx_app",
      "certificate_hash": "YOUR_SHA1_HASH"
    }
  },
  {
    "client_id": "61258568836-593ic09mlfcc7vq3r73qs4g5akmolqtr.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

### Step 5: Clean and Rebuild

```powershell
flutter clean
flutter pub get
cd android
.\gradlew clean
cd ..
flutter run
```

## Additional Notes

- **For Release Builds:** You'll also need to add your release keystore's SHA-1 fingerprint
- **Google Play Services:** Make sure your device/emulator has Google Play Services installed and updated
- **Internet Connection:** Ensure you have an active internet connection

## Current Status

✅ Google Sign-In enabled in Firebase Authentication
✅ Web OAuth client present in google-services.json
❌ Android OAuth client missing (needs SHA-1 fingerprint)
✅ Code updated to use web client ID as serverClientId

After adding SHA-1 and downloading the new google-services.json, Google Sign-In should work!

