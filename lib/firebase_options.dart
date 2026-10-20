// Firebase options for the stllr-db5e4 project (Android).
// Values mirror android/app/google-services.json.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for Android. '
          'Run `flutterfire configure` to add other platforms.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0fnZIoU18mIXciKEudTE8rqsfIW2BUDs',
    appId: '1:597202134408:android:1687a542cbc4de4c50c63d',
    messagingSenderId: '597202134408',
    projectId: 'stllr-db5e4',
    storageBucket: 'stllr-db5e4.firebasestorage.app',
  );
}
