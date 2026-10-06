import 'package:flutter/material.dart';

import '../theme.dart';

class ResultArgs {
  const ResultArgs({
    required this.success,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.primaryRoute,
    this.secondaryLabel,
    this.secondaryRoute,
  });

  final bool success;
  final String title;
  final String message;
  final String primaryLabel;
  final String primaryRoute;
  final String? secondaryLabel;
  final String? secondaryRoute;
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.args});

  final ResultArgs args;

  @override
  Widget build(BuildContext context) {
    final color = args.success ? Steller.azure : Steller.rust;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(args.success ? Icons.check_rounded : Icons.close_rounded, size: 60, color: color),
              ),
              const SizedBox(height: 28),
              Text(args.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                args.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Steller.blueGray, fontSize: 15),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(context, args.primaryRoute),
                child: Text(args.primaryLabel),
              ),
              if (args.secondaryLabel != null && args.secondaryRoute != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, args.secondaryRoute!),
                  child: Text(args.secondaryLabel!),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
