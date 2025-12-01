# Web Configuration Instructions

The `firebase_options.dart` file has been created with Android configuration, but the Web configuration needs to be added manually.

## How to Get Web Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **tailorx-jaat001**
3. Click the gear icon ⚙️ next to "Project Overview"
4. Select **Project settings**
5. Scroll down to **Your apps** section
6. Find the **Web app** (it should be named "tailorx_app (web)")
7. Click on it to see the configuration
8. You'll see something like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "tailorx-jaat001.firebaseapp.com",
  projectId: "tailorx-jaat001",
  storageBucket: "tailorx-jaat001.firebasestorage.app",
  messagingSenderId: "61258568836",
  appId: "1:61258568836:web:xxxxx"
};
```

## Update firebase_options.dart

Open `lib/firebase_options.dart` and replace the `web` configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'PASTE_YOUR_API_KEY_HERE',        // From firebaseConfig.apiKey
  appId: 'PASTE_YOUR_APP_ID_HERE',          // From firebaseConfig.appId
  messagingSenderId: '61258568836',         // Already correct
  projectId: 'tailorx-jaat001',             // Already correct
  authDomain: 'tailorx-jaat001.firebaseapp.com', // Already correct
  storageBucket: 'tailorx-jaat001.firebasestorage.app', // Already correct
);
```

## Alternative: Use Android Config for Testing

If you only need to test on Android for now, you can temporarily use the Android config for web:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyCdyJT3lyS9lNwJNUZAj1I-mT5NKTVGjAY',
  appId: '1:61258568836:web:xxxxx',  // Get this from Firebase Console
  messagingSenderId: '61258568836',
  projectId: 'tailorx-jaat001',
  authDomain: 'tailorx-jaat001.firebaseapp.com',
  storageBucket: 'tailorx-jaat001.firebasestorage.app',
);
```

**Note:** The `appId` for web will be different from Android. Make sure to get the correct web app ID from Firebase Console.

## After Updating

1. Save the file
2. Run `flutter pub get`
3. Test your app - Firebase should now initialize correctly!

