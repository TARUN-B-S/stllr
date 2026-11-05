import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models.dart';

class ChatRepo {
  ChatRepo([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('chats');

  // Sorted client-side so the app does not depend on a composite index for
  // (participants, updatedAt) being deployed. Without this the listener failed
  // with FAILED_PRECONDITION and the dashboards silently showed "no" data,
  // which read as "no responses".
  Stream<List<Chat>> watchFor(String uid) => _col
      .where('participants', arrayContains: uid)
      .snapshots()
      .map((s) {
        final list = s.docs.map(Chat.fromDoc).toList();
        list.sort((a, b) {
          final at = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bt = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bt.compareTo(at);
        });
        return list;
      });

  Stream<List<ChatMessage>> watchMessages(String chatId) => _col
      .doc(chatId)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(ChatMessage.fromDoc).toList());

  String chatId({required String requestId, required String sellerId}) => '${requestId}__$sellerId';

  Future<Chat> createChat({required BuyRequest request, required String sellerId, required String sellerName}) async {
    final id = chatId(requestId: request.id, sellerId: sellerId);
    final doc = _col.doc(id);
    final greeting = 'Hello! I am interested in your request "${request.title}".';
    final participants = [request.buyerId, sellerId];
    final message = doc.collection('messages').doc();
    final batch = _db.batch();

    batch.set(doc, <String, Object?>{
      'requestId': request.id,
      'requestTitle': request.title,
      'buyerId': request.buyerId,
      'buyerName': request.buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'participants': participants,
      'lastMessage': greeting,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(message, {'text': greeting, 'senderId': sellerId, 'createdAt': FieldValue.serverTimestamp()});
    batch.update(_db.collection('requests').doc(request.id), {'responseCount': FieldValue.increment(1)});
    await batch.commit();

    return Chat(
      id: id,
      participants: participants,
      requestId: request.id,
      requestTitle: request.title,
      buyerId: request.buyerId,
      sellerId: sellerId,
      buyerName: request.buyerName,
      sellerName: sellerName,
      lastMessage: greeting,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> sendMessage(String chatId, String text, String senderId) async {
    final doc = _col.doc(chatId);
    final message = doc.collection('messages').doc();
    final batch = _db.batch();
    batch.set(message, {'text': text, 'senderId': senderId, 'createdAt': FieldValue.serverTimestamp()});
    batch.set(doc, {'lastMessage': text, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    await batch.commit();
  }
}
