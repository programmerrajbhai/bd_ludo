import 'package:flutter/material.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("How to Play"), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.black.withOpacity(.18),
              border: Border.all(color: Colors.white.withOpacity(.14)),
            ),
            child: const Text(
              "✅ Basic Rules\n"
              "• ৬ ছাড়া টোকেন ঘর থেকে বের হবে না\n"
              "• ৬ পেলে extra turn\n"
              "• Capture করলে opponent টোকেন home এ ফিরে যাবে\n"
              "• Star/Safe cell এ capture হবে না\n"
              "• Home stretch color-specific\n"
              "• Exact roll (settings থেকে ON/OFF)\n\n"
              "🎮 Tips\n"
              "• Dice roll করার পর যে টোকেনগুলো move করতে পারবে সেগুলো glow করবে\n"
              "• Space চাপলেও dice roll হবে (web)\n",
              style: TextStyle(fontWeight: FontWeight.w800, height: 1.55, color: Color(0xFFB8D6FF)),
            ),
          ),
        ),
      ),
    );
  }
}
