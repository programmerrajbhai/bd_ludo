import 'package:flutter/material.dart';

class Toasty {
  static void show(BuildContext context, String msg) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 18,
        right: 18,
        bottom: 18,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(.12)),
              boxShadow: const [BoxShadow(blurRadius: 30, offset: Offset(0, 18), color: Color(0x66000000))],
            ),
            child: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1400), entry.remove);
  }
}
