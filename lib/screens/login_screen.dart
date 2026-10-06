import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock.dart';
import '../theme.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'demo@steller.app');
  final _password = TextEditingController(text: 'demo123');
  UserRole _role = UserRole.buyer;
  bool _obscure = true;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final store = context.read<MockStore>();
    store.login(_role == UserRole.buyer ? 'Demo Buyer' : 'Demo Seller', _email.text.trim(), _role);
    Navigator.pushReplacementNamed(context, _role == UserRole.buyer ? '/buyer' : '/seller');
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                RoleToggle(selected: _role, onChanged: (r) => setState(() => _role = r)),
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
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Steller.blueGray),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _submit, child: const Text('Log in')),
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
