import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models.dart';

class RequestRepo {
  RequestRepo([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('requests');

  Stream<List<BuyRequest>> watchAll() =>
      _col.orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map(BuyRequest.fromDoc).toList());

  Future<String> create(BuyRequest r) async {
    final ref = await _col.add(r.toMap());
    return ref.id;
  }
}
