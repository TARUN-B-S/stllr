import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _location;
  late final TextEditingController _bio;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<MockStore>().user;
    _name = TextEditingController(text: u?.name ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
    _location = TextEditingController(text: u?.location ?? '');
    _bio = TextEditingController(text: u?.bio ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    context.read<MockStore>().updateProfile(
          name: _name.text,
          phone: _phone.text,
          location: _location.text,
          bio: _bio.text,
        );
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<MockStore>();
    final u = store.user;
    if (u == null) return const Scaffold(body: Center(child: Text('Not logged in')));
    final isSeller = u.role == UserRole.seller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () => _editing ? _save() : setState(() => _editing = true),
            child: Text(_editing ? 'Save' : 'Edit',
                style: const TextStyle(color: Steller.sky, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              AvatarBadge(label: u.initials, radius: 34, color: isSeller ? Steller.deepBlue : Steller.azureInk),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSeller ? 'Seller account' : 'Buyer account',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Steller.deepBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isSeller) _SubscriptionCard(subscribed: u.subscribed),
          const SizedBox(height: 20),
          AppTextField(label: 'Full name', controller: _name, readOnly: !_editing),
          const SizedBox(height: 16),
          AppTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, readOnly: !_editing),
          const SizedBox(height: 16),
          AppTextField(label: 'Phone', controller: _phone, keyboardType: TextInputType.phone, readOnly: !_editing),
          const SizedBox(height: 16),
          AppTextField(label: 'Location', hint: 'City, State', controller: _location, readOnly: !_editing),
          const SizedBox(height: 16),
          AppTextField(label: 'About', hint: 'What do you offer / looking for?', controller: _bio, maxLines: 3, readOnly: !_editing),
          const SizedBox(height: 24),
          if (_editing)
            FilledButton(onPressed: _save, child: const Text('Save changes'))
          else
            OutlinedButton(
              onPressed: () => setState(() => _editing = true),
              child: const Text('Edit profile'),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              store.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            child: const Text('Log out', style: TextStyle(color: Steller.rust, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.subscribed});

  final bool subscribed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: subscribed ? Steller.surface2 : const Color(0xFFFFF6EA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subscribed ? Steller.border : Steller.amber),
      ),
      child: Row(
        children: [
          Icon(subscribed ? Icons.verified_rounded : Icons.workspace_premium_outlined,
              color: subscribed ? Steller.deepBlue : Steller.amberInk, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subscribed ? 'Premium seller' : 'Verification required',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Steller.charcoal)),
                const SizedBox(height: 2),
                Text(
                  subscribed ? 'Active plan · renewal in 30 days' : 'Complete one-time verification to respond to requests.',
                  style: const TextStyle(fontSize: 13, color: Steller.blueGray),
                ),
              ],
            ),
          ),
          if (!subscribed)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Steller.amber,
                foregroundColor: Steller.charcoal,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pushNamed(context, '/payment'),
              child: const Text('Pay now'),
            ),
        ],
      ),
    );
  }
}
