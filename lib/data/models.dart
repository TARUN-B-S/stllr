import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { buyer, seller }

UserRole userRoleFrom(Object? v) => v == 'seller' ? UserRole.seller : UserRole.buyer;

String roleToName(UserRole r) => r == UserRole.seller ? 'seller' : 'buyer';

DateTime _ts(Object? v) =>
    v is Timestamp ? v.toDate() : (v is DateTime ? v : DateTime.now());

String _two(int n) => n.toString().padLeft(2, '0');

class AppUser {
  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.location = '',
    this.bio = '',
    this.subscribed = false,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final String location;
  final String bio;
  final bool subscribed;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return AppUser(
      uid: d.id,
      name: (m['name'] as String?) ?? '',
      email: (m['email'] as String?) ?? '',
      role: userRoleFrom(m['role']),
      phone: (m['phone'] as String?) ?? '',
      location: (m['location'] as String?) ?? '',
      bio: (m['bio'] as String?) ?? '',
      subscribed: (m['subscribed'] as bool?) ?? false,
    );
  }

  Map<String, Object?> toMap() => {
        'name': name,
        'email': email,
        'role': roleToName(role),
        'phone': phone,
        'location': location,
        'bio': bio,
        'subscribed': subscribed,
      };

  AppUser copyWith({
    String? name,
    String? phone,
    String? location,
    String? bio,
    bool? subscribed,
  }) =>
      AppUser(
        uid: uid,
        name: name ?? this.name,
        email: email,
        role: role,
        phone: phone ?? this.phone,
        location: location ?? this.location,
        bio: bio ?? this.bio,
        subscribed: subscribed ?? this.subscribed,
      );

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
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
    required this.buyerId,
    required this.buyerName,
    this.responses = 0,
    this.createdAt,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String budget;
  final String buyerId;
  final String buyerName;
  final int responses;
  final DateTime? createdAt;

  factory BuyRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return BuyRequest(
      id: d.id,
      title: (m['title'] as String?) ?? '',
      category: (m['category'] as String?) ?? 'Other',
      description: (m['description'] as String?) ?? '',
      budget: (m['budget'] as String?) ?? '',
      buyerId: (m['buyerId'] as String?) ?? '',
      buyerName: (m['buyerName'] as String?) ?? '',
      responses: (m['responseCount'] as num?)?.toInt() ?? 0,
      createdAt: m['createdAt'] == null ? null : _ts(m['createdAt']),
    );
  }

  Map<String, Object?> toMap() => {
        'title': title,
        'category': category,
        'description': description,
        'budget': budget,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'responseCount': responses,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class ChatMessage {
  ChatMessage({required this.text, required this.senderId, required this.createdAt});

  final String text;
  final String senderId;
  final DateTime createdAt;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return ChatMessage(
      text: (m['text'] as String?) ?? '',
      senderId: (m['senderId'] as String?) ?? '',
      createdAt: _ts(m['createdAt']),
    );
  }

  bool fromMe(String uid) => senderId == uid;

  String get time {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays <= 0) return '${_two(createdAt.hour)}:${_two(createdAt.minute)}';
    if (diff.inDays == 1) return 'Yesterday';
    return '${createdAt.day}/${createdAt.month}';
  }
}

class Chat {
  Chat({
    required this.id,
    required this.participants,
    required this.requestId,
    required this.requestTitle,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    this.lastMessage = '',
    this.updatedAt,
  });

  final String id;
  final List<String> participants;
  final String requestId;
  final String requestTitle;
  final String buyerId;
  final String sellerId;
  final String buyerName;
  final String sellerName;
  final String lastMessage;
  final DateTime? updatedAt;

  String peerName(String uid) => uid == buyerId ? sellerName : buyerName;

  String peerInitial(String uid) {
    final n = peerName(uid);
    return n.isEmpty ? '?' : n.substring(0, 1).toUpperCase();
  }

  factory Chat.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Chat(
      id: d.id,
      participants: ((m['participants'] as List?) ?? const []).map((e) => e.toString()).toList(),
      requestId: (m['requestId'] as String?) ?? '',
      requestTitle: (m['requestTitle'] as String?) ?? '',
      buyerId: (m['buyerId'] as String?) ?? '',
      sellerId: (m['sellerId'] as String?) ?? '',
      buyerName: (m['buyerName'] as String?) ?? '',
      sellerName: (m['sellerName'] as String?) ?? '',
      lastMessage: (m['lastMessage'] as String?) ?? '',
      updatedAt: m['updatedAt'] == null ? null : _ts(m['updatedAt']),
    );
  }
}
