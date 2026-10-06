import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  String _query = '';
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<MockStore>();
    final user = store.user;
    final t = Theme.of(context).textTheme;
    final categories = ['All', ...{for (final r in store.requests) r.category}];
    final filtered = store.requests.where((r) {
      final matchesQuery = _query.isEmpty ||
          r.title.toLowerCase().contains(_query.toLowerCase()) ||
          r.description.toLowerCase().contains(_query.toLowerCase());
      final matchesCat = _category == 'All' || r.category == _category;
      return matchesQuery && matchesCat;
    }).toList();
    final subscribed = user?.subscribed == true;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.name ?? 'Seller'),
            Text(
              subscribed ? 'Verified seller · Premium' : 'Verification pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: subscribed ? Steller.sky : Steller.amber,
              ),
            ),
          ],
        ),
        actions: [
          if (!subscribed)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/payment'),
              child: const Text('Verify', style: TextStyle(color: Steller.amber, fontWeight: FontWeight.w700)),
            ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search requests…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                for (final c in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      selectedColor: Steller.deepBlue,
                      labelStyle: TextStyle(
                        color: _category == c ? Steller.onDark : Steller.deepBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
              ],
            ),
          ),
          const SectionTitle('Open requests'),
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.search_off,
              title: 'No matching requests',
              hint: 'Try a different keyword or pick another category above.',
            ),
          for (final r in filtered)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: RequestCard(
                request: r,
                trailing: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Steller.azureInk,
                    foregroundColor: Steller.onDark,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    store.respondTo(r);
                    final chat = store.chats.firstWhere((c) => c.peerName == r.buyerName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Response sent to ${r.buyerName}. Say hello in chat.')),
                    );
                    Navigator.pushNamed(context, '/chat', arguments: chat);
                  },
                  child: const Text('Respond'),
                ),
              ),
            ),
          const SectionTitle('My conversations'),
          if (store.buyerChats.isEmpty)
            const EmptyState(
              icon: Icons.forum_outlined,
              title: 'No conversations yet',
              hint: 'Tap Respond on a request and the buyer lands here to chat.',
            )
          else
            for (final c in store.buyerChats)
              ListTile(
                onTap: () => Navigator.pushNamed(context, '/chat', arguments: c),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: AvatarBadge(label: c.peerName.characters.first.toUpperCase()),
                title: Text(c.peerName, style: t.titleSmall),
                subtitle: Text(
                  '${c.requestTitle} · ${c.messages.isEmpty ? '' : c.messages.last.text}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall,
                ),
                trailing: const Icon(Icons.chat_bubble_outline, size: 18, color: Steller.azureInk),
              ),
        ],
      ),
    );
  }
}
