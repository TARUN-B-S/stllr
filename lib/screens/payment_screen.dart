import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'result_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _card = TextEditingController();
  final _holder = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _card.dispose();
    _holder.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _processing = false);

    final declined = _card.text.replaceAll(' ', '').startsWith('4000');
    if (declined) {
      Navigator.pushReplacementNamed(
        context,
        '/result',
        arguments: const ResultArgs(
          success: false,
          title: 'Payment failed',
          message: 'Your card was declined. No amount was deducted. Please try another card.',
          primaryLabel: 'Try again',
          primaryRoute: '/payment',
          secondaryLabel: 'Back to dashboard',
          secondaryRoute: '/seller',
        ),
      );
    } else {
      context.read<MockStore>().completePayment();
      Navigator.pushReplacementNamed(
        context,
        '/result',
        arguments: const ResultArgs(
          success: true,
          title: 'Payment successful!',
          message: 'Your seller verification is complete. You can now respond to buyer requests.',
          primaryLabel: 'Go to dashboard',
          primaryRoute: '/seller',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller verification')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Steller.charcoal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.workspace_premium_outlined, color: Steller.amber, size: 30),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('One-time verification',
                                style: TextStyle(color: Steller.onDark, fontWeight: FontWeight.w700, fontSize: 16)),
                            SizedBox(height: 2),
                            Text('Unlimited responses · verified badge',
                                style: TextStyle(color: Steller.onDarkMuted, fontSize: 13)),
                          ],
                        ),
                      ),
                      Text('₹499',
                          style: TextStyle(color: Steller.amber, fontWeight: FontWeight.w800, fontSize: 22)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Card number',
                  hint: '1234 5678 9012 3456',
                  controller: _card,
                  keyboardType: TextInputType.number,
                  suffixIcon: const Icon(Icons.credit_card, color: Steller.blueGray),
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    return digits.length < 16 ? 'Enter a 16-digit card number' : null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Name on card',
                  controller: _holder,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Expiry',
                        hint: 'MM/YY',
                        controller: _expiry,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || !v.contains('/')) ? 'MM/YY' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        label: 'CVV',
                        hint: '123',
                        controller: _cvv,
                        keyboardType: TextInputType.number,
                        obscure: true,
                        validator: (v) => (v == null || v.length < 3) ? '3 digits' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Demo mode: any card works. Use 4000 0000 0000 0002 to simulate a declined card.',
                        style: TextStyle(fontSize: 12.5, color: Steller.blueGray),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _processing ? null : _pay,
                  style: FilledButton.styleFrom(
                    backgroundColor: Steller.amber,
                    foregroundColor: Steller.charcoal,
                    disabledBackgroundColor: Steller.disabled,
                    disabledForegroundColor: Steller.onDisabled,
                  ),
                  child: _processing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Steller.charcoal),
                        )
                      : const Text('Pay ₹499'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
