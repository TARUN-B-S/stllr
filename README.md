# Steller Market

Steller Market is a Flutter and Firebase reverse-marketplace prototype. Buyers
post requests, verified sellers respond, and both parties continue in a private
chat. Seller verification uses a deliberately mocked payment flow for the
course demonstration.

## Requirements

- Flutter with Dart 3.13.4 or newer
- A Firebase project with Email/Password authentication and Firestore enabled
- Firebase CLI when deploying rules or using the local emulator suite
- Node.js when running the optional demo-data seed

## Setup

1. Install dependencies:

   ```sh
   flutter pub get
   ```

2. Replace `lib/firebase_options.dart` and
   `android/app/google-services.json` if you are not using the included Firebase
   project. The checked-in Firebase app supports Android and the local web demo;
   run `flutterfire configure` before shipping another platform.

3. Deploy the Firestore rules and index:

   ```sh
   firebase deploy --only firestore
   ```

4. Run the app:

   ```sh
   flutter run
   ```

To use Firebase emulators, start the suite and run Flutter with matching host
settings:

```sh
firebase emulators:start
flutter run --dart-define=USE_FIREBASE_EMULATOR=true \
  --dart-define=FIREBASE_EMULATOR_HOST=127.0.0.1
```

Android emulators should omit the host override so the app uses its `10.0.2.2`
default.

## Checks

```sh
flutter analyze
flutter test
```

Golden screenshots can be regenerated with:

```sh
flutter test test/screenshot_test.dart --update-goldens
```

## Demo Data

The optional `tool/seed.mjs` script creates the evaluator accounts and sample
marketplace records. Follow the setup instructions at the top of that file and
keep the downloaded service-account JSON outside version control.

The payment screen is not connected to a payment processor. Production use
requires server-side payment verification before setting `subscribed`.
