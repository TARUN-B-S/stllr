import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'result_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.buyer;
  bool _obscure = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final store = context.read<AppStore>();
    try {
      final u = await store.signup(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phone: _phone.text.trim(),
        role: _role,
      );
      if (!mounted) return;

      if (_role == UserRole.seller && !u.subscribed) {
        Navigator.pushReplacementNamed(
          context,
          '/result',
          arguments: ResultArgs(
            success: true,
            title: 'Account created!',
            message: 'Complete your seller verification with a one-time payment to start receiving requests.',
            primaryLabel: 'Continue to payment',
            primaryRoute: '/payment',
            secondaryRoute: '/seller',
            secondaryLabel: 'Maybe later',
          ),
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/result',
          arguments: ResultArgs(
            success: true,
            title: 'Welcome aboard!',
            message: 'Your account is ready. Start posting requests and sellers will respond.',
            primaryLabel: 'Go to dashboard',
            primaryRoute: _role == UserRole.buyer ? '/buyer' : '/seller',
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(store.error ?? 'Sign up failed. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AppStore>().loading;
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Join Steller Market', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Choose how you want to use the platform.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Steller.blueGray)),
                const SizedBox(height: 20),
                RoleToggle(selected: _role, onChanged: (r) => setState(() => _role = r)),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Full name',
                  hint: 'Your name',
                  controller: _name,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Phone',
                  hint: '+91 98765 43210',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().length < 8) ? 'Enter a valid phone number' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: 'Minimum 6 characters',
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
                      : Text(_role == UserRole.seller ? 'Sign up & verify' : 'Sign up'),
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text.rich(TextSpan(
                      text: 'Already registered? ',
                      style: TextStyle(color: Steller.blueGray),
                      children: [TextSpan(text: 'Log in', style: TextStyle(color: Steller.azureInk, fontWeight: FontWeight.w600))],
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
