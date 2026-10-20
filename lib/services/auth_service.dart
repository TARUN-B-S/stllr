import 'package:firebase_auth/firebase_auth.dart';

import '../data/models.dart';
import 'user_repo.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, UserRepo? users})
      : _auth = auth ?? FirebaseAuth.instance,
        _users = users ?? UserRepo();

  final FirebaseAuth _auth;
  final UserRepo _users;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final u = AppUser(
      uid: cred.user!.uid,
      name: name,
      email: email,
      role: role,
      phone: phone,
    );
    await _users.setUser(u);
    return u;
  }

  Future<User> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!;
  }

  Future<void> signOut() => _auth.signOut();
}
