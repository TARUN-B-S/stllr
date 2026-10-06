import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'result_screen.dart';

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _budget = TextEditingController();
  String _category = 'Electronics';

  static const _categories = ['Electronics', 'Printing', 'Grocery', 'Services', 'Furniture', 'Bakery'];

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<MockStore>().postRequest(
          title: _title.text.trim(),
          category: _category,
          description: _description.text.trim(),
          budget: _budget.text.trim(),
        );
    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: const ResultArgs(
        success: true,
        title: 'Request posted!',
        message: 'Sellers can now see your request and reach out. You will get a message when someone responds.',
        primaryLabel: 'Back to dashboard',
        primaryRoute: '/buyer',
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a request')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What do you need?', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Describe it once and sellers come to you.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Steller.blueGray)),
                const SizedBox(height: 22),
                AppTextField(
                  label: 'Title',
                  hint: 'e.g. 20 units wireless earbuds',
                  controller: _title,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                Text('Category', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in _categories)
                      ChoiceChip(
                        label: Text(c),
                        selected: _category == c,
                        selectedColor: Steller.deepBlue,
                        labelStyle: TextStyle(
                          color: _category == c ? Steller.onDark : Steller.deepBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setState(() => _category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Description',
                  hint: 'Quantities, timeline, must-haves…',
                  controller: _description,
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Add a little more detail' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Budget',
                  hint: 'e.g. ₹15,000 – ₹20,000',
                  controller: _budget,
                  keyboardType: TextInputType.text,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Budget is required' : null,
                ),
                const SizedBox(height: 26),
                FilledButton(onPressed: _submit, child: const Text('Post request')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
