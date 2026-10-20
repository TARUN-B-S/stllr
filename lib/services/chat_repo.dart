import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models.dart';

class ChatRepo {
  ChatRepo([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('chats');

  Stream<List<Chat>> watchFor(String uid) => _col
      .where('participants', arrayContains: uid)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Chat.fromDoc).toList());

  Stream<List<ChatMessage>> watchMessages(String chatId) => _col
      .doc(chatId)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(ChatMessage.fromDoc).toList());

  String chatId({required String requestId, required String sellerId}) =>
      '${requestId}__$sellerId';

  /// Returns the chat between the request's buyer and [sellerId], creating it
  /// if it does not exist yet.
  ///
  /// [isNew] is supplied by the caller from its live chat list and must not be
  /// replaced with a probe of the document. `firestore.rules` authorises chat
  /// reads through `resource.data.participants`, which is null for a chat that
  /// does not exist yet, so reading before creating is denied. The write is
  /// authorised by the `create` rule instead, which inspects the incoming
  /// participants.
  Future<Chat> ensureChat({
    required BuyRequest request,
    required String sellerId,
    required String sellerName,
    required bool isNew,
  }) async {
    final id = chatId(requestId: request.id, sellerId: sellerId);
    final doc = _col.doc(id);
    final greeting = 'Hello! I am interested in your request "${request.title}".';
    final participants = [request.buyerId, sellerId];

    final data = <String, Object?>{
      'requestId': request.id,
      'requestTitle': request.title,
      'buyerId': request.buyerId,
      'buyerName': request.buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'participants': participants,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    // An existing chat keeps its own last message; only a new one is greeted.
    if (isNew) data['lastMessage'] = greeting;

    await doc.set(data, SetOptions(merge: true));

    if (isNew) {
      // Written after the chat document so the inChat() rule can resolve it.
      await doc.collection('messages').add({
        'text': greeting,
        'senderId': sellerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return Chat(
      id: id,
      participants: participants,
      requestId: request.id,
      requestTitle: request.title,
      buyerId: request.buyerId,
      sellerId: sellerId,
      buyerName: request.buyerName,
      sellerName: sellerName,
      lastMessage: isNew ? greeting : '',
      updatedAt: DateTime.now(),
    );
  }

  Future<void> welcomeFromSeller({
    required String requestId,
    required String requestTitle,
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
  }) async {
    final id = chatId(requestId: requestId, sellerId: sellerId);
    final text = 'Hi! I saw your request "$requestTitle" and we can help. Chat when you are free.';
    final doc = _col.doc(id);
    await doc.set({
      'requestId': requestId,
      'requestTitle': requestTitle,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'participants': [buyerId, sellerId],
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await doc.collection('messages').add({
      'text': text,
      'senderId': sellerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendMessage(String chatId, String text, String senderId) async {
    final doc = _col.doc(chatId);
    await doc.collection('messages').add({
      'text': text,
      'senderId': senderId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await doc.set({
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
