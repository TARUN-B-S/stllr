import 'package:flutter/material.dart';

import '../data/mock.dart';
import '../theme.dart';

/// Steller's jay crest mark: three ascending feather peaks with the eye spark.
class CrestLogo extends StatelessWidget {
  const CrestLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Steller.charcoal,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: const [BoxShadow(color: Color(0x331C396B), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: CustomPaint(painter: _CrestPainter(), size: Size.square(size)),
    );
  }
}

class _CrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(x * w, y * h);

    final crest = Path()
      ..moveTo(p(0.16, 0.74).dx, p(0.16, 0.74).dy)
      ..lineTo(p(0.33, 0.26).dx, p(0.33, 0.26).dy)
      ..lineTo(p(0.44, 0.54).dx, p(0.44, 0.54).dy)
      ..lineTo(p(0.57, 0.20).dx, p(0.57, 0.20).dy)
      ..lineTo(p(0.67, 0.48).dx, p(0.67, 0.48).dy)
      ..lineTo(p(0.80, 0.30).dx, p(0.80, 0.30).dy)
      ..lineTo(p(0.86, 0.74).dx, p(0.86, 0.74).dy)
      ..close();

    canvas.drawPath(crest, Paint()..color = Steller.sky);
    canvas.drawCircle(p(0.27, 0.64), 0.055 * w, Paint()..color = Steller.amber);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
    this.suffixIcon,
    this.validator,
    this.readOnly = false,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final int maxLines;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          maxLines: maxLines,
          readOnly: readOnly,
          validator: validator,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({super.key, required this.label, this.radius = 22, this.color = Steller.deepBlue});

  final String label;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        label,
        style: TextStyle(
          color: Steller.onDark,
          fontWeight: FontWeight.w700,
          fontSize: (radius * 0.72).clamp(11.0, 24.0),
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.request, this.trailing, this.onTap});

  final BuyRequest request;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(label: Text(request.category)),
                  const Spacer(),
                  Text('${request.responses} responses', style: t.labelMedium),
                ],
              ),
              const SizedBox(height: 10),
              Text(request.title, style: t.titleMedium),
              const SizedBox(height: 6),
              Text(request.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodySmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 15),
                  const SizedBox(width: 4),
                  Text(request.buyerName, style: t.labelMedium),
                  const SizedBox(width: 14),
                  const Icon(Icons.currency_rupee, size: 15, color: Steller.azure),
                  Expanded(
                    child: Text(
                      request.budget,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelLarge?.copyWith(color: Steller.deepBlue),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelSmall)),
          ?action,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.hint});

  final IconData icon;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(color: Steller.surface2, shape: BoxShape.circle),
            child: Icon(icon, color: Steller.azureInk, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: t.titleSmall, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(hint, style: t.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class RoleToggle extends StatelessWidget {
  const RoleToggle({super.key, required this.selected, required this.onChanged});

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Steller.surface2, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          for (final role in UserRole.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(role),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected == role ? Steller.deepBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    role == UserRole.buyer ? 'I am a Buyer' : 'I am a Seller',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: selected == role ? Steller.onDark : Steller.deepBlue,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
