import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/chat_repo.dart';
import '../services/request_repo.dart';
import '../services/user_repo.dart';
import 'models.dart';

class AppStore extends ChangeNotifier {
  AppStore({AuthService? auth, UserRepo? users, RequestRepo? requests, ChatRepo? chats})
    : _auth = auth ?? AuthService(),
      _users = users ?? UserRepo(),
      _requests = requests ?? RequestRepo(),
      _chats = chats ?? ChatRepo() {
    _init();
  }

  final AuthService _auth;
  final UserRepo _users;
  final RequestRepo _requests;
  final ChatRepo _chats;

  AppUser? user;
  bool ready = false;
  bool loading = false;
  String? error;

  List<BuyRequest> requests = [];
  List<Chat> chats = [];

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _userSub;
  StreamSubscription<List<BuyRequest>>? _reqSub;
  StreamSubscription<List<Chat>>? _chatSub;

  String get uid => user?.uid ?? '';

  List<BuyRequest> get myRequests => requests.where((r) => r.buyerId == uid).toList();

  List<BuyRequest> get otherRequests => requests.where((r) => r.buyerId != uid).toList();

  /// Chats where the current user is the buyer (the peer is a seller).
  List<Chat> get sellerChats => chats.where((c) => c.buyerId == uid).toList();

  /// Chats where the current user is the seller (the peer is a buyer).
  List<Chat> get buyerChats => chats.where((c) => c.sellerId == uid).toList();

  /// Seller conversations opened on a single request, so the buyer can jump
  /// straight into a response instead of hunting through their message list.
  List<Chat> chatsForRequest(String requestId) =>
      chats.where((c) => c.requestId == requestId).toList();

  void _init() {
    _authSub = _auth.authStateChanges.listen(_onAuthChanged);
  }

  void _onAuthChanged(User? fbUser) {
    _userSub?.cancel();
    _reqSub?.cancel();
    _chatSub?.cancel();
    _dataAttached = false;
    _requestsError = null;
    _chatsError = null;
    user = null;
    requests = [];
    chats = [];

    if (fbUser == null) {
      // Also reached by a token expiry or revocation, not just logout(), so the
      // data subscriptions must be re-armed here or the next login would never
      // reattach them.
      ready = true;
      notifyListeners();
      return;
    }

    ready = false;
    notifyListeners();
    _userSub = _users.watchUser(fbUser.uid).listen((u) {
      user = u;
      ready = true;
      notifyListeners();
      if (u != null) _attachData(u.uid);
    });
  }

  bool _dataAttached = false;
  String? _requestsError;
  String? _chatsError;

  /// Non-null when a live listener failed (rules, index, network). Shown in the
  /// dashboards so a broken read never masquerades as an empty marketplace.
  String? get dataError => _chatsError ?? _requestsError;

  void _attachData(String uid) {
    if (_dataAttached) return;
    _dataAttached = true;
    _reqSub = _requests.watchAll().listen(
      (list) {
        requests = list;
        _requestsError = null;
        notifyListeners();
      },
      onError: (Object e) => _onDataError(e, chats: false),
    );
    _chatSub = _chats.watchFor(uid).listen(
      (list) {
        chats = list;
        _chatsError = null;
        notifyListeners();
      },
      onError: (Object e) => _onDataError(e, chats: true),
    );
  }

  void _onDataError(Object e, {required bool chats}) {
    const message = 'Could not load your marketplace data. Check the connection and the Firestore rules.';
    debugPrint('Firestore listener failed: $e');
    if (chats) {
      _chatsError = message;
    } else {
      _requestsError = message;
    }
    notifyListeners();
  }

  Future<AppUser> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final fbUser = await _auth.signIn(email: email, password: password);
      final u = await _users.getUser(fbUser.uid);
      if (u == null) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'missing-profile',
          message: 'This account has no marketplace profile. Please create a new account.',
        );
      }
      user = u;
      ready = true;
      notifyListeners();
      return u;
    } catch (e) {
      error = _friendly(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<AppUser> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    _setLoading(true);
    try {
      final u = await _auth.signUp(name: name, email: email, password: password, phone: phone, role: role);
      user = u;
      ready = true;
      notifyListeners();
      return u;
    } catch (e) {
      error = _friendly(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _dataAttached = false;
    await _auth.signOut();
  }

  Future<void> updateProfile({String? name, String? phone, String? location, String? bio}) async {
    final u = user;
    if (u == null) return;
    final data = <String, Object?>{
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      ?phone: phone,
      ?location: location,
      ?bio: bio,
    };
    await _users.updateFields(u.uid, data);
    user = u.copyWith(
      name: (name != null && name.trim().isNotEmpty) ? name.trim() : null,
      phone: phone,
      location: location,
      bio: bio,
    );
    notifyListeners();
  }

  Future<void> completePayment() async {
    final u = user;
    if (u == null) return;
    await _users.updateFields(u.uid, {'subscribed': true});
    user = u.copyWith(subscribed: true);
    notifyListeners();
  }

  Future<void> postRequest({
    required String title,
    required String category,
    required String description,
    required String budget,
  }) async {
    final me = user!;
    final request = BuyRequest(
      id: '',
      title: title,
      category: category,
      description: description,
      budget: budget,
      buyerId: me.uid,
      buyerName: me.name,
    );
    await _requests.create(request);
  }

  Future<Chat> startChatFor(BuyRequest r) async {
    final me = user!;
    final id = _chats.chatId(requestId: r.id, sellerId: me.uid);
    for (final chat in chats) {
      if (chat.id == id) return chat;
    }
    return _chats.createChat(request: r, sellerId: me.uid, sellerName: me.name);
  }

  Future<void> sendMessage(Chat chat, String text) => _chats.sendMessage(chat.id, text, uid);

  Stream<List<ChatMessage>> messagesOf(String chatId) => _chats.watchMessages(chatId);

  void _setLoading(bool v) {
    loading = v;
    if (v) error = null;
    notifyListeners();
  }

  String _friendly(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'That email address is not valid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'Choose a stronger password (6+ characters).';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        case 'missing-profile':
          return e.message ?? 'This account has no marketplace profile.';
        case 'operation-not-allowed':
        case 'internal-error':
          // Surfaced when Email/Password sign-in is disabled for the project.
          // The raw SDK message is a stack-trace fragment, so replace it.
          return 'Sign-in is not available right now. If you are the developer, '
              'check that Email/Password sign-in is enabled in the Firebase console.';
      }
      return e.message ?? 'Something went wrong. Please try again.';
    }
    return e.toString();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userSub?.cancel();
    _reqSub?.cancel();
    _chatSub?.cancel();
    super.dispose();
  }
}
