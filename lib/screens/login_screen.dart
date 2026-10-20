import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// The demo accounts `tool/seed.mjs` creates, prefilled so an evaluator can
/// sign in without being told which credentials work.
const Map<UserRole, (String, String)> _demoLogins = {
  UserRole.buyer: ('buyer@steller.app', 'demo1234'),
  UserRole.seller: ('seller@steller.app', 'demo1234'),
};

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'buyer@steller.app');
  final _password = TextEditingController(text: 'demo1234');
  UserRole _role = UserRole.buyer;
  bool _obscure = true;

  /// Follows the role toggle so both seeded demo accounts stay one tap away,
  /// while never overwriting credentials the user typed themselves.
  void _selectRole(UserRole role) {
    setState(() {
      final untouched = _demoLogins.values
          .any((c) => c.$1 == _email.text.trim() && c.$2 == _password.text);
      if (untouched) {
        final (email, password) = _demoLogins[role]!;
        _email.text = email;
        _password.text = password;
      }
      _role = role;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final store = context.read<AppStore>();
    try {
      final u = await store.login(email: _email.text.trim(), password: _password.text);
      if (!mounted) return;
      if (u.role != _role) {
        await store.logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('That account is registered as a ${u.role == UserRole.seller ? 'seller' : 'buyer'}. '
              'Switch the toggle above and try again.'),
        ));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(store.error ?? 'Login failed. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AppStore>().loading;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CrestLogo(),
                const SizedBox(height: 24),
                Text('Steller Market', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 6),
                Text('Buyers post requests. Sellers respond, chat and meet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Steller.blueGray)),
                const SizedBox(height: 28),
                RoleToggle(selected: _role, onChanged: _selectRole),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _password,
                  obscure: _obscure,
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Steller.blueGray),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Steller.onDark),
                        )
                      : const Text('Log in'),
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text.rich(TextSpan(
                      text: 'New here? ',
                      style: TextStyle(color: Steller.blueGray),
                      children: [TextSpan(text: 'Create an account', style: TextStyle(color: Steller.azureInk, fontWeight: FontWeight.w600))],
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
