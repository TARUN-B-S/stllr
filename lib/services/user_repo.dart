import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models.dart';

class UserRepo {
  UserRepo([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('users');

  Future<void> setUser(AppUser u) => _col.doc(u.uid).set(u.toMap(), SetOptions(merge: true));

  Future<void> updateFields(String uid, Map<String, Object?> data) =>
      _col.doc(uid).set(data, SetOptions(merge: true));

  Future<AppUser?> getUser(String uid) async {
    final snap = await _col.doc(uid).get();
    return snap.exists ? AppUser.fromDoc(snap) : null;
  }

  Stream<AppUser?> watchUser(String uid) =>
      _col.doc(uid).snapshots().map((d) => d.exists ? AppUser.fromDoc(d) : null);
}
