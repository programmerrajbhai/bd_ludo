import 'package:flutter/material.dart';

class PremiumButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const PremiumButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [c.withOpacity(.95), c.withOpacity(.70)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: const [BoxShadow(blurRadius: 30, offset: Offset(0, 16), color: Color(0x55000000))],
          border: Border.all(color: Colors.black.withOpacity(.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.black.withOpacity(.10),
                border: Border.all(color: Colors.black.withOpacity(.08)),
              ),
              child: Icon(icon, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: .4, color: Color(0xFF06213E))),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: const Color(0xFF06213E).withOpacity(.85), fontWeight: FontWeight.w800, fontSize: 12)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
