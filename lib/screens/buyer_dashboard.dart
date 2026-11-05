import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  /// A request card is the buyer's entry point into the replies: one response
  /// opens that chat directly, several ask which seller to read.
  Future<void> _openResponses(BuildContext context, AppStore store, BuyRequest r) async {
    final threads = store.chatsForRequest(r.id);
    if (threads.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No responses to "${r.title}" yet.')),
      );
      return;
    }
    if (threads.length == 1) {
      await Navigator.pushNamed(context, '/chat', arguments: threads.single);
      return;
    }
    final picked = await showModalBottomSheet<Chat>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                '${threads.length} sellers responded to "${r.title}"',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final c in threads)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: AvatarBadge(label: c.peerInitial(store.uid)),
                title: Text(c.peerName(store.uid)),
                subtitle: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.pop(sheetContext, c),
              ),
          ],
        ),
      ),
    );
    if (picked != null && context.mounted) {
      await Navigator.pushNamed(context, '/chat', arguments: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final user = store.user;
    final mine = store.myRequests;
    final others = store.otherRequests;
    final chats = store.sellerChats;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, ${user?.name ?? 'Buyer'}'),
            Text(
              '${mine.length} posted · ${chats.length} active chats',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Steller.onDarkMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Steller.azureInk,
        foregroundColor: Steller.onDark,
        onPressed: () => Navigator.pushNamed(context, '/post'),
        icon: const Icon(Icons.add),
        label: const Text('Post request'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          if (store.dataError != null) DataErrorBanner(message: store.dataError!),
          if (mine.isNotEmpty) ...[
            const SectionTitle('My requests'),
            for (final r in mine)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: RequestCard(
                  request: r,
                  trailing: Icon(
                    r.responses > 0 ? Icons.forum_outlined : Icons.chevron_right,
                  ),
                  onTap: () => _openResponses(context, store, r),
                ),
              ),
          ],
          const SectionTitle('Seller messages'),
          if (chats.isEmpty)
            const EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No messages yet',
              hint: 'Post a request and sellers who can help will write to you here.',
            )
          else
            for (final c in chats)
              ListTile(
                onTap: () => Navigator.pushNamed(context, '/chat', arguments: c),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: AvatarBadge(label: c.peerInitial(store.uid)),
                title: Text(c.peerName(store.uid), style: t.titleSmall),
                subtitle: Text(
                  c.lastMessage.isEmpty ? c.requestTitle : c.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall,
                ),
                trailing: const Icon(Icons.chat_bubble_outline, size: 18, color: Steller.azureInk),
              ),
          const SectionTitle('Trending requests'),
          if (others.isEmpty)
            const EmptyState(
              icon: Icons.grid_view_outlined,
              title: 'No other requests right now',
              hint: 'New buyer requests show up here as the marketplace fills up.',
            ),
          for (final r in others)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: RequestCard(request: r),
            ),
        ],
      ),
    );
  }
}
