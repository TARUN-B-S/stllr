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

  /// The role dashboards are owned by `AuthGate`, which renders whichever one
  /// matches the signed-in user. Pushing them from here stacked a second
  /// dashboard above the home route, leaving a Back arrow on a screen that had
  /// nowhere sensible to go back to. Returning to the home route lets AuthGate
  /// show the dashboard without a stale stack behind it. Routes that are real
  /// pushed screens (e.g. retrying payment) still push.
  void _go(BuildContext context, String route) {
    final navigator = Navigator.of(context);
    if ((route == '/buyer' || route == '/seller') && navigator.canPop()) {
      navigator.popUntil((r) => r.isFirst);
      return;
    }
    navigator.pushReplacementNamed(route);
  }

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
                onPressed: () => _go(context, args.primaryRoute),
                child: Text(args.primaryLabel),
              ),
              if (args.secondaryLabel != null && args.secondaryRoute != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _go(context, args.secondaryRoute!),
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
