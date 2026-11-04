import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steller_market/data/models.dart';
import 'package:steller_market/services/chat_repo.dart';

void main() {
  test('creating a chat writes its greeting and increments responses', () async {
    final database = FakeFirebaseFirestore();
    final request = BuyRequest(
      id: 'request-1',
      title: 'Office chairs',
      category: 'Furniture',
      description: 'Need twelve chairs',
      budget: '₹72,000',
      buyerId: 'buyer-1',
      buyerName: 'Aarav',
    );
    await database.collection('requests').doc(request.id).set(request.toMap());
    final repository = ChatRepo(database);

    final chat = await repository.createChat(request: request, sellerId: 'seller-1', sellerName: 'Meera');

    final chatSnapshot = await database.collection('chats').doc(chat.id).get();
    final messageSnapshot = await chatSnapshot.reference.collection('messages').get();
    final requestSnapshot = await database.collection('requests').doc(request.id).get();
    expect(chatSnapshot.data()?['participants'], ['buyer-1', 'seller-1']);
    expect(messageSnapshot.docs.single.data()['senderId'], 'seller-1');
    expect(requestSnapshot.data()?['responseCount'], 1);
  });

  test('sending a message updates the thread and its preview', () async {
    final database = FakeFirebaseFirestore();
    final chat = database.collection('chats').doc('chat-1');
    await chat.set({
      'participants': ['buyer-1', 'seller-1'],
      'lastMessage': '',
    });
    final repository = ChatRepo(database);

    await repository.sendMessage('chat-1', 'Hello', 'buyer-1');

    final chatSnapshot = await chat.get();
    final messageSnapshot = await chat.collection('messages').get();
    expect(chatSnapshot.data()?['lastMessage'], 'Hello');
    expect(messageSnapshot.docs.single.data()['text'], 'Hello');
  });
}
