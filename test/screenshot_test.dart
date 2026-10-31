// Screenshot harness for the course report.
//
// This does NOT change app behaviour. It renders the app's real screens inside
// the real theme, backed by an in-memory Firestore (fake_cloud_firestore) and
// a mock auth session, then writes each screen to test/goldens/*.png via
// Flutter's golden-file mechanism. Run:
//
//   flutter test test/screenshot_test.dart --update-goldens
//
// The goldens are then copied into docs/screenshots/ for the written report.

import 'dart:io';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:steller_market/data/models.dart';
import 'package:steller_market/data/store.dart';
import 'package:steller_market/screens/buyer_dashboard.dart';
import 'package:steller_market/screens/chat_screen.dart';
import 'package:steller_market/screens/login_screen.dart';
import 'package:steller_market/screens/payment_screen.dart';
import 'package:steller_market/screens/post_request_screen.dart';
import 'package:steller_market/screens/profile_screen.dart';
import 'package:steller_market/screens/result_screen.dart';
import 'package:steller_market/screens/seller_dashboard.dart';
import 'package:steller_market/screens/signup_screen.dart';
import 'package:steller_market/services/auth_service.dart';
import 'package:steller_market/services/chat_repo.dart';
import 'package:steller_market/services/request_repo.dart';
import 'package:steller_market/services/user_repo.dart';
import 'package:steller_market/theme.dart';

// ---- Fonts ----------------------------------------------------------------
// `flutter test` substitutes every glyph with the `Ahem` box font, so goldens
// render text as solid rectangles. Loading the real Roboto family (which the
// Material theme resolves to) restores legible text in the screenshots.

const _fontDir =
    '/tools/App-Dev-Env/flutter/bin/cache/dart-sdk/bin/resources/devtools/assets/fonts/Roboto';

Future<void> _loadRoboto() async {
  // All faces must be added to ONE FontLoader: separate loaders for the same
  // family replace each other instead of accumulating, which leaves only the
  // last weight available. Each TTF declares its own weight, so the engine
  // matches w400/w500/w700/w800 to the right face instead of faux-bolding —
  // which smears white bold text on the dark AppBar into illegible blocks.
  const files = [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
    'Roboto-Black.ttf',
  ];
  final roboto = FontLoader('Roboto');
  for (final f in files) {
    final bytes = Uint8List.fromList(File('$_fontDir/$f').readAsBytesSync());
    roboto.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await roboto.load();

  // Material icons, otherwise every Icon() renders as the .notdef box in goldens.
  final icons = Uint8List.fromList(File(
          '/tools/App-Dev-Env/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
      .readAsBytesSync());
  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.view(icons.buffer)));
  await iconLoader.load();
}

// ---- Demo data (mirrors tool/seed.mjs) ------------------------------------

const buyerUid = 'demo-buyer';
const sellerUid = 'demo-seller';

Future<void> _seed(FakeFirebaseFirestore db) async {
  await db.collection('users').doc(buyerUid).set({
    'name': 'Aarav Mehta',
    'email': 'buyer@steller.app',
    'role': 'buyer',
    'phone': '+91 98765 43210',
    'location': 'Bengaluru, Karnataka',
    'bio': 'Looking for bulk electronics and office supplies.',
    'subscribed': false,
  });
  await db.collection('users').doc(sellerUid).set({
    'name': 'Meera (Jay & Co.)',
    'email': 'seller@steller.app',
    'role': 'seller',
    'phone': '+91 98123 45678',
    'location': 'Mumbai, Maharashtra',
    'bio': 'Sourcing partner for electronics, printing and office furniture.',
    'subscribed': false,
  });

  await db.collection('requests').doc('req-earbuds').set({
    'title': '20 units wireless earbuds',
    'category': 'Electronics',
    'description':
        'Looking for TWS earbuds with ANC, bulk order for a college fest. Need delivery within 3 weeks.',
    'budget': '₹18,000 – ₹24,000',
    'buyerId': buyerUid,
    'buyerName': 'Aarav Mehta',
    'responseCount': 1,
    'createdAt': DateTime(2026, 10, 18, 9, 30),
  });
  await db.collection('requests').doc('req-chairs').set({
    'title': 'Ergonomic office chairs x12',
    'category': 'Furniture',
    'description':
        'Startup office, adjustable lumbar and headrest, warranty required.',
    'budget': '₹72,000',
    'buyerId': buyerUid,
    'buyerName': 'Aarav Mehta',
    'responseCount': 0,
    'createdAt': DateTime(2026, 10, 19, 14, 5),
  });
  await db.collection('requests').doc('req-cards').set({
    'title': 'Custom wedding invitation cards',
    'category': 'Printing',
    'description':
        '500 premium cards with foil work and matching envelopes. Design help appreciated.',
    'budget': '₹30,000',
    'buyerId': 'demo-buyer-2',
    'buyerName': 'Diya Sharma',
    'responseCount': 0,
    'createdAt': DateTime(2026, 10, 19, 20, 40),
  });
  await db.collection('requests').doc('req-cake').set({
    'title': 'Birthday cake, chocolate truffle 2kg',
    'category': 'Bakery',
    'description':
        'Eggless, sugar-free option preferred, delivery to Koramangala on Saturday.',
    'budget': '₹1,500',
    'buyerId': 'demo-buyer-2',
    'buyerName': 'Diya Sharma',
    'responseCount': 0,
    'createdAt': DateTime(2026, 10, 20, 8, 15),
  });

  final chatRef = db.collection('chats').doc('req-earbuds__demo-seller');
  await chatRef.set({
    'requestId': 'req-earbuds',
    'requestTitle': '20 units wireless earbuds',
    'buyerId': buyerUid,
    'buyerName': 'Aarav Mehta',
    'sellerId': sellerUid,
    'sellerName': 'Meera (Jay & Co.)',
    'participants': [buyerUid, sellerUid],
    'lastMessage': 'Sending the quote now.',
    'updatedAt': DateTime(2026, 10, 20, 10, 12),
  });
  final msgs = chatRef.collection('messages');
  await msgs.add({
    'text': 'Hi! I saw your request for earbuds.',
    'senderId': sellerUid,
    'createdAt': DateTime(2026, 10, 20, 10, 2),
  });
  await msgs.add({
    'text': 'Yes! Do you have ANC models in stock?',
    'senderId': buyerUid,
    'createdAt': DateTime(2026, 10, 20, 10, 5),
  });
  await msgs.add({
    'text': 'Yes, brand new with a 1-year warranty. Can we schedule a call?',
    'senderId': sellerUid,
    'createdAt': DateTime(2026, 10, 20, 10, 9),
  });
  await msgs.add({
    'text': 'Sending the quote now.',
    'senderId': sellerUid,
    'createdAt': DateTime(2026, 10, 20, 10, 12),
  });
}

AppUser _userFor(UserRole role) => role == UserRole.seller
    ? AppUser(
        uid: sellerUid,
        name: 'Meera (Jay & Co.)',
        email: 'seller@steller.app',
        role: UserRole.seller,
        phone: '+91 98123 45678',
        location: 'Mumbai, Maharashtra',
        bio: 'Sourcing partner for electronics, printing and office furniture.',
        subscribed: false,
      )
    : AppUser(
        uid: buyerUid,
        name: 'Aarav Mehta',
        email: 'buyer@steller.app',
        role: UserRole.buyer,
        phone: '+91 98765 43210',
        location: 'Bengaluru, Karnataka',
        bio: 'Looking for bulk electronics and office supplies.',
      );

Future<Chat> _chat() async {
  final db = FakeFirebaseFirestore();
  await _seed(db);
  final snap = await db.collection('chats').doc('req-earbuds__demo-seller').get();
  return Chat.fromDoc(snap);
}

/// Builds a real AppStore wired to in-memory repos, then sets its public fields
/// directly so each screenshot is deterministic and independent of auth timing.
Future<AppStore> _store(WidgetTester tester, UserRole role) async {
  final db = FakeFirebaseFirestore();
  await _seed(db);

  final mockAuth = MockFirebaseAuth(signedIn: false);
  final users = UserRepo(db);
  final store = AppStore(
    auth: AuthService(auth: mockAuth, users: users),
    users: users,
    requests: RequestRepo(db),
    chats: ChatRepo(db),
  );

  // Let the auth listener settle (it clears fields on the signed-out path),
  // then populate deterministically.
  await tester.pump(const Duration(milliseconds: 10));

  final reqs = await _allRequests(db);
  store.user = _userFor(role);
  store.requests = reqs;
  store.chats = [await _chat()];
  store.ready = true;
  return store;
}

Future<List<BuyRequest>> _allRequests(FakeFirebaseFirestore db) async {
  final snap = await db.collection('requests').get();
  return snap.docs.map(BuyRequest.fromDoc).toList();
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532); // iPhone 12 @ 3x
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// The app's component themes (AppBar title, chip label, button text, dialog /
/// snackbar text, input hint/label) build fresh TextStyles with no fontFamily.
/// In the golden renderer those resolve to the unloaded default family and
/// paint as solid `Ahem` boxes (body text is fine because ThemeData merges the
/// default Typography, which carries Roboto, under the base textTheme). On a
/// real device the platform default IS Roboto, so this is purely a harness
/// fix: pin every component text style to the Roboto we registered. App source
/// is untouched.
TextStyle _pin(TextStyle? s) =>
    (s ?? const TextStyle()).copyWith(fontFamily: 'Roboto');

ThemeData _pinnedTheme() {
  final base = buildTheme();
  final fb = base.filledButtonTheme.style;
  final ob = base.outlinedButtonTheme.style;
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: _pin(base.textTheme.displaySmall),
      headlineSmall: _pin(base.textTheme.headlineSmall),
      titleLarge: _pin(base.textTheme.titleLarge),
      titleMedium: _pin(base.textTheme.titleMedium),
      titleSmall: _pin(base.textTheme.titleSmall),
      bodyLarge: _pin(base.textTheme.bodyLarge),
      bodyMedium: _pin(base.textTheme.bodyMedium),
      bodySmall: _pin(base.textTheme.bodySmall),
      labelLarge: _pin(base.textTheme.labelLarge),
      labelMedium: _pin(base.textTheme.labelMedium),
      labelSmall: _pin(base.textTheme.labelSmall),
    ),
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: _pin(base.appBarTheme.titleTextStyle),
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: _pin(base.chipTheme.labelStyle),
    ),
    dialogTheme: base.dialogTheme.copyWith(
      titleTextStyle: _pin(base.dialogTheme.titleTextStyle),
      contentTextStyle: _pin(base.dialogTheme.contentTextStyle),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(
      contentTextStyle: _pin(base.snackBarTheme.contentTextStyle),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      hintStyle: _pin(base.inputDecorationTheme.hintStyle),
      labelStyle: _pin(base.inputDecorationTheme.labelStyle),
      helperStyle: _pin(base.inputDecorationTheme.helperStyle),
      errorStyle: _pin(base.inputDecorationTheme.errorStyle),
      prefixStyle: _pin(base.inputDecorationTheme.prefixStyle),
      suffixStyle: _pin(base.inputDecorationTheme.suffixStyle),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: fb?.copyWith(
        textStyle: WidgetStatePropertyAll(
          _pin(fb.textStyle?.resolve(const <WidgetState>{})),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ob?.copyWith(
        textStyle: WidgetStatePropertyAll(
          _pin(ob.textStyle?.resolve(const <WidgetState>{})),
        ),
      ),
    ),
  );
}

Future<void> _render(
  WidgetTester tester,
  Widget home,
  AppStore store,
  String file,
) async {
  final theme = _pinnedTheme();

  await tester.pumpWidget(
    ChangeNotifierProvider<AppStore>.value(
      value: store,
      child: MaterialApp(
        theme: theme,
        debugShowCheckedModeBanner: false,
        home: home,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$file.png'),
  );
}

// ---- Screens ---------------------------------------------------------------

void main() {
  setUpAll(_loadRoboto);

  testWidgets('01 login', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.buyer);
    await _render(tester, const LoginScreen(), store, '01-login');
  });

  testWidgets('02 signup', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.buyer);
    await _render(tester, const SignupScreen(), store, '02-signup');
  });

  testWidgets('03 buyer dashboard', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.buyer);
    await _render(tester, const BuyerDashboard(), store, '03-buyer-dashboard');
  });

  testWidgets('04 seller dashboard', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.seller);
    await _render(
        tester, const SellerDashboard(), store, '04-seller-dashboard');
  });

  testWidgets('05 post request', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.buyer);
    await _render(
        tester, const PostRequestScreen(), store, '05-post-request');
  });

  testWidgets('06 chat', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.buyer);
    await _render(tester, ChatScreen(chat: await _chat()), store, '06-chat');
  });

  testWidgets('07 payment', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.seller);
    await _render(tester, const PaymentScreen(), store, '07-payment');
  });

  testWidgets('08 result success', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.buyer);
    await _render(
      tester,
      const ResultScreen(
        args: ResultArgs(
          success: true,
          title: 'Request posted!',
          message:
              'Sellers can now see your request and reach out. You will get a message when someone responds.',
          primaryLabel: 'Back to dashboard',
          primaryRoute: '/buyer',
        ),
      ),
      store,
      '08-result-success',
    );
  });

  testWidgets('09 result failure', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.seller);
    await _render(
      tester,
      const ResultScreen(
        args: ResultArgs(
          success: false,
          title: 'Payment failed',
          message:
              'Your card was declined. No amount was deducted. Please try another card.',
          primaryLabel: 'Try again',
          primaryRoute: '/payment',
          secondaryLabel: 'Back to dashboard',
          secondaryRoute: '/seller',
        ),
      ),
      store,
      '09-result-failure',
    );
  });

  testWidgets('10 profile buyer', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.buyer);
    await _render(tester, const ProfileScreen(), store, '10-profile-buyer');
  });

  testWidgets('11 profile seller', (tester) async {
    _phone(tester);
    final store = await _store(tester, UserRole.seller);
    await _render(tester, const ProfileScreen(), store, '11-profile-seller');
  });
}
