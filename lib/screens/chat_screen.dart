import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat});

  final Chat chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  late final Stream<List<ChatMessage>> _messages;

  @override
  void initState() {
    super.initState();
    // Built once. Calling messagesOf() inside build() would hand StreamBuilder a
    // fresh stream on every notifyListeners(), resubscribing and re-reading the
    // whole thread each time.
    _messages = context.read<AppStore>().messagesOf(widget.chat.id);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final store = context.read<AppStore>();
    _input.clear();
    store.sendMessage(widget.chat, text);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final myUid = store.uid;
    final chat = widget.chat;
    final peer = chat.peerName(myUid);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: Steller.azureInk,
              child: Text(
                chat.peerInitial(myUid),
                style: const TextStyle(color: Steller.onDark, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(peer, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
                  Text(
                    chat.requestTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w400, color: Steller.onDarkMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            tooltip: 'Voice call',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling is available in the full version.')),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messages,
              builder: (context, snapshot) {
                final messages = snapshot.data ?? const <ChatMessage>[];
                if (messages.isEmpty) {
                  return const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'Say hello',
                    hint: 'Start the conversation — say hi and share what you can offer.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => _Bubble(message: messages[i], myUid: myUid),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: const BoxDecoration(
              color: Steller.surface2,
              border: Border(top: BorderSide(color: Steller.border)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined, color: Steller.azureInk, size: 21),
                    tooltip: 'Propose a meeting',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Propose a meeting'),
                        content: const Text('A meeting slot (Sat, 11:00 AM) has been suggested to both parties.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      onSubmitted: (_) => _send(),
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(hintText: 'Type a message…', contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    button: true,
                    label: 'Send message',
                    child: Material(
                      color: Steller.deepBlue,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _send,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(11),
                          child: Icon(Icons.send_rounded, color: Steller.onDark, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.myUid});

  final ChatMessage message;
  final String myUid;

  @override
  Widget build(BuildContext context) {
    final mine = message.fromMe(myUid);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: mine ? Steller.deepBlue : Steller.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
          border: mine ? null : Border.all(color: Steller.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.35,
                color: mine ? Steller.onDark : Steller.charcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: TextStyle(fontSize: 10.5, color: mine ? const Color(0xFFAFC4E6) : Steller.blueGray),
            ),
          ],
        ),
      ),
    );
  }
}
