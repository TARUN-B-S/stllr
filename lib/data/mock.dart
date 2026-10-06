import 'package:flutter/material.dart';

enum UserRole { buyer, seller }

class AppUser {
  AppUser({
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.location = '',
    this.bio = '',
    this.subscribed = false,
  });

  final String name;
  final String email;
  final UserRole role;
  String phone;
  String location;
  String bio;
  bool subscribed;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1 || parts.first.isEmpty) {
      return parts.first.isEmpty ? '?' : parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class BuyRequest {
  BuyRequest({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.budget,
    required this.buyerName,
    this.responses = 0,
  });

  final int id;
  final String title;
  final String category;
  final String description;
  final String budget;
  final String buyerName;
  int responses;
}

class ChatMessage {
  ChatMessage({required this.text, required this.fromMe, required this.time});

  final String text;
  final bool fromMe;
  final String time;
}

class Chat {
  Chat({
    required this.id,
    required this.peerName,
    required this.requestTitle,
    this.peerIsSeller = false,
  });

  final int id;
  final String peerName;
  final String requestTitle;
  final bool peerIsSeller;
  final List<ChatMessage> messages = [];
}

class MockStore extends ChangeNotifier {
  MockStore() {
    requests.addAll(_seedRequests);
    chats.addAll(_seedChats);
  }

  AppUser? user;

  final List<BuyRequest> requests = [];
  final List<Chat> chats = [];

  static final _seedRequests = [
    BuyRequest(
      id: 1,
      title: '20 units wireless earbuds',
      category: 'Electronics',
      description: 'Looking for TWS earbuds with ANC, bulk order for a college fest. Need delivery within 3 weeks.',
      budget: '₹18,000 – ₹24,000',
      buyerName: 'Aarav Mehta',
      responses: 3,
    ),
    BuyRequest(
      id: 2,
      title: 'Custom wedding invitation cards',
      category: 'Printing',
      description: '500 premium cards with foil work and matching envelopes. Design help appreciated.',
      budget: '₹30,000',
      buyerName: 'Diya Sharma',
      responses: 5,
    ),
    BuyRequest(
      id: 3,
      title: 'Organic cold-pressed oil, monthly supply',
      category: 'Grocery',
      description: 'Cafe needs 40L/month of groundnut and coconut oil with FSSAI certification.',
      budget: '₹12,000 / month',
      buyerName: 'Rohan Iyer',
      responses: 1,
    ),
    BuyRequest(
      id: 4,
      title: 'Website redesign for a dental clinic',
      category: 'Services',
      description: '3-page site with online appointment booking, mobile-first, 2-week timeline.',
      budget: '₹45,000 – ₹60,000',
      buyerName: 'Dr. Neha Kulkarni',
      responses: 4,
    ),
    BuyRequest(
      id: 5,
      title: 'Ergonomic office chairs x12',
      category: 'Furniture',
      description: 'Startup office, adjustable lumbar and headrest, warranty required.',
      budget: '₹72,000',
      buyerName: 'Kabir Singh',
      responses: 2,
    ),
    BuyRequest(
      id: 6,
      title: 'Birthday cake, chocolate truffle 2kg',
      category: 'Bakery',
      description: 'Eggless, sugar-free option preferred, delivery to Koramangala on Saturday.',
      budget: '₹1,500',
      buyerName: 'Ananya Rao',
      responses: 6,
    ),
  ];

  static final _seedChats = [
    Chat(id: 1, peerName: 'Aarav Mehta', requestTitle: '20 units wireless earbuds')
      ..messages.addAll([
        ChatMessage(text: 'Hi! I saw your request for earbuds.', fromMe: true, time: '10:02'),
        ChatMessage(text: 'Yes! Do you have ANC models in stock?', fromMe: false, time: '10:04'),
        ChatMessage(text: 'Yes, brand new with a 1-year warranty. Can we schedule a call?', fromMe: true, time: '10:05'),
      ]),
    Chat(id: 2, peerName: 'Diya Sharma', requestTitle: 'Custom wedding invitation cards')
      ..messages.addAll([
        ChatMessage(text: 'Sharing our foil-work catalogue shortly.', fromMe: true, time: 'Yesterday'),
        ChatMessage(text: 'Please share sample pricing too.', fromMe: false, time: 'Yesterday'),
      ]),
    Chat(id: 3, peerName: 'Vikram (Nova Traders)', requestTitle: 'Ergonomic office chairs x12', peerIsSeller: true)
      ..messages.addAll([
        ChatMessage(text: 'Hello! We supply ergonomic chairs with 3-year warranty.', fromMe: false, time: '09:15'),
        ChatMessage(text: 'Great, can you share the catalogue?', fromMe: true, time: '09:20'),
        ChatMessage(text: 'Sending it over. Free installation included.', fromMe: false, time: '09:22'),
      ]),
    Chat(id: 4, peerName: 'Meera (Jay & Co.)', requestTitle: 'Birthday cake, chocolate truffle 2kg', peerIsSeller: true)
      ..messages.addAll([
        ChatMessage(text: 'Hi! Eggless truffle cake available for Saturday.', fromMe: false, time: 'Yesterday'),
        ChatMessage(text: 'Perfect, what is the price for 2kg?', fromMe: true, time: 'Yesterday'),
      ]),
  ];

  List<Chat> get sellerChats => chats.where((c) => c.peerIsSeller).toList();
  List<Chat> get buyerChats => chats.where((c) => !c.peerIsSeller).toList();

  void login(String name, String email, UserRole role) {
    user = AppUser(name: name, email: email, role: role);
    notifyListeners();
  }

  void logout() {
    user = null;
    notifyListeners();
  }

  void updateProfile({String? name, String? phone, String? location, String? bio}) {
    final u = user;
    if (u == null) return;
    if (name != null && name.trim().isNotEmpty) {
      user = AppUser(
        name: name.trim(),
        email: u.email,
        role: u.role,
        phone: u.phone,
        location: u.location,
        bio: u.bio,
        subscribed: u.subscribed,
      );
    }
    final nu = user!;
    if (phone != null) nu.phone = phone;
    if (location != null) nu.location = location;
    if (bio != null) nu.bio = bio;
    notifyListeners();
  }

  void completePayment() {
    user?.subscribed = true;
    notifyListeners();
  }

  void postRequest({required String title, required String category, required String description, required String budget}) {
    requests.insert(
      0,
      BuyRequest(
        id: requests.length + 100,
        title: title,
        category: category,
        description: description,
        budget: budget,
        buyerName: user?.name ?? 'You',
      ),
    );
    chats.insert(
      0,
      Chat(
        id: chats.length + 100,
        peerName: 'Meera (Jay & Co.)',
        requestTitle: title,
        peerIsSeller: true,
      )..messages.add(ChatMessage(
          text: 'Hi! I saw your request "$title" and we can help. Chat when you are free.',
          fromMe: false,
          time: 'Now',
        )),
    );
    notifyListeners();
  }

  void respondTo(BuyRequest request) {
    request.responses += 1;
    final existing = chats.where((c) => c.peerName == request.buyerName);
    if (existing.isEmpty) {
      chats.insert(
        0,
        Chat(id: chats.length + 100, peerName: request.buyerName, requestTitle: request.title)
          ..messages.add(ChatMessage(
            text: 'Hello! I am interested in your request "${request.title}".',
            fromMe: true,
            time: 'Now',
          )),
      );
    }
    notifyListeners();
  }

  Chat openChatWithBuyer(BuyRequest request) {
    respondTo(request);
    return chats.firstWhere((c) => c.peerName == request.buyerName);
  }

  void sendMessage(Chat chat, String text) {
    chat.messages.add(ChatMessage(text: text, fromMe: true, time: 'Now'));
    notifyListeners();
  }

  void receiveReply(Chat chat, String text) {
    chat.messages.add(ChatMessage(text: text, fromMe: false, time: 'Now'));
    notifyListeners();
  }
}

const mockReplies = [
  'Sounds good, tell me more.',
  'Can you share a quote with delivery time?',
  'Great. What payment terms do you offer?',
  'Let me check and get back to you.',
  'Could we meet briefly to finalize?',
];
