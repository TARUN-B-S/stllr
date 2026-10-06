import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock.dart';
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

void main() {
  runApp(const StellerApp());
}

class StellerApp extends StatelessWidget {
  const StellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MockStore(),
      child: MaterialApp(
        title: 'Steller Market',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        initialRoute: '/login',
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
