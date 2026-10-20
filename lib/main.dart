import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/models.dart';
import 'data/store.dart';
import 'firebase_options.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/post_request_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/result_screen.dart';
import 'screens/seller_dashboard.dart';
import 'screens/buyer_dashboard.dart';
import 'screens/signup_screen.dart';
import 'theme.dart';
import 'widgets/common.dart';

/// Build with `--dart-define=USE_FIREBASE_EMULATOR=true` to point Auth and
/// Firestore at the local Firebase Emulator Suite instead of the hosted
/// project. Off by default, so release builds are unaffected.
const bool useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

/// `10.0.2.2` is how the Android emulator reaches the developer machine.
const String firebaseEmulatorHost =
    String.fromEnvironment('FIREBASE_EMULATOR_HOST', defaultValue: '10.0.2.2');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (useFirebaseEmulator) {
    FirebaseAuth.instance.useAuthEmulator(firebaseEmulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(firebaseEmulatorHost, 8080);
  }
  runApp(const StellerApp());
}

class StellerApp extends StatelessWidget {
  const StellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStore(),
      child: MaterialApp(
        title: 'Steller Market',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const AuthGate(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/signup':
              return MaterialPageRoute(builder: (_) => const SignupScreen());
            case '/buyer':
              return MaterialPageRoute(builder: (_) => const BuyerDashboard());
            case '/seller':
              return MaterialPageRoute(builder: (_) => const SellerDashboard());
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());
            case '/payment':
              return MaterialPageRoute(builder: (_) => const PaymentScreen());
            case '/post':
              return MaterialPageRoute(builder: (_) => const PostRequestScreen());
            case '/chat':
              return MaterialPageRoute(builder: (_) => ChatScreen(chat: settings.arguments as Chat));
            case '/result':
              final args = settings.arguments as ResultArgs;
              return MaterialPageRoute(builder: (_) => ResultScreen(args: args));
            default:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
        },
      ),
    );
  }
}

/// Decides the first screen from the live auth state, so a signed-in user
/// lands on their role dashboard after a restart.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    if (!store.ready) {
      return const Scaffold(
        body: Center(child: CrestLogo()),
      );
    }
    final user = store.user;
    if (user == null) return const LoginScreen();
    return user.role == UserRole.seller ? const SellerDashboard() : const BuyerDashboard();
  }
}
