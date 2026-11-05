import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../data/store.dart';
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

  /// Opens the existing thread with the buyer who posted [r], or starts one.
  Future<void> _respond(BuyRequest r) async {
    final store = context.read<AppStore>();
    if (store.user?.subscribed != true) {
      await Navigator.pushNamed(context, '/payment');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final chat = await store.startChatFor(r);
      messenger.showSnackBar(
        SnackBar(content: Text('Response sent to ${r.buyerName}. Say hello in chat.')),
      );
      await navigator.pushNamed('/chat', arguments: chat);
    } catch (_) {
      // Without this the tap would fail silently and the seller would be left
      // staring at an unchanged screen.
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not start the chat. Please try again.')),
      );
    }
  }

  /// Tapping anywhere on a request previews it and offers Respond, so a card is
  /// no longer a dead end for sellers who do not aim at the small button.
  Future<void> _openRequest(BuyRequest r) async {
    final store = context.read<AppStore>();
    Chat? existing;
    for (final c in store.chats) {
      if (c.requestId == r.id && c.sellerId == store.uid) {
        existing = c;
        break;
      }
    }
    if (existing != null) {
      await Navigator.pushNamed(context, '/chat', arguments: existing);
      return;
    }

    final subscribed = store.user?.subscribed == true;
    final respond = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final t = Theme.of(sheetContext).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(label: Text(r.category)),
                    const Spacer(),
                    Text(
                      '${r.responses} ${r.responses == 1 ? 'response' : 'responses'}',
                      style: t.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(r.title, style: t.titleMedium),
                const SizedBox(height: 8),
                Text(r.description, style: t.bodySmall),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 6),
                    Text(r.buyerName, style: t.labelLarge),
                    const SizedBox(width: 16),
                    const Icon(Icons.currency_rupee, size: 16, color: Steller.azure),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        r.budget,
                        overflow: TextOverflow.ellipsis,
                        style: t.labelLarge?.copyWith(color: Steller.deepBlue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Steller.azureInk,
                      foregroundColor: Steller.onDark,
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: () => Navigator.pop(sheetContext, true),
                    child: Text(subscribed ? 'Respond' : 'Verify to respond'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (respond == true && mounted) await _respond(r);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final user = store.user;
    final t = Theme.of(context).textTheme;
    final categories = [
      'All',
      ...{for (final r in store.requests) r.category},
    ];
    final filtered = store.requests.where((r) {
      final matchesQuery =
          _query.isEmpty ||
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
              child: const Text(
                'Verify',
                style: TextStyle(color: Steller.amber, fontWeight: FontWeight.w700),
              ),
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
              decoration: const InputDecoration(hintText: 'Search requests…', prefixIcon: Icon(Icons.search)),
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
          if (store.dataError != null) DataErrorBanner(message: store.dataError!),
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
                onTap: () => _openRequest(r),
                trailing: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Steller.azureInk,
                    foregroundColor: Steller.onDark,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _respond(r),
                  child: Text(subscribed ? 'Respond' : 'Verify to respond'),
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
                leading: AvatarBadge(label: c.peerInitial(store.uid)),
                title: Text(c.peerName(store.uid), style: t.titleSmall),
                subtitle: Text(
                  '${c.requestTitle} · ${c.lastMessage}',
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
