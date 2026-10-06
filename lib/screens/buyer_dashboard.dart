import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock.dart';
import '../theme.dart';
import '../widgets/common.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<MockStore>();
    final user = store.user;
    final mine = store.requests.where((r) => r.buyerName == user?.name).toList();
    final others = store.requests.where((r) => r.buyerName != user?.name).toList();
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
          if (mine.isNotEmpty) ...[
            const SectionTitle('My requests'),
            for (final r in mine)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: RequestCard(
                  request: r,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${r.responses} sellers responded to ${r.title}')),
                  ),
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
                leading: AvatarBadge(label: c.peerName.characters.first.toUpperCase()),
                title: Text(c.peerName, style: t.titleSmall),
                subtitle: Text(
                  c.messages.isEmpty ? c.requestTitle : c.messages.last.text,
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
