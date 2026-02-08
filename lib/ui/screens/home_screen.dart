import 'package:bd_ludo/%20game/%20engine.dart';
import 'package:bd_ludo/ui/screens/game_screen.dart';
import 'package:bd_ludo/ui/screens/settings_sheet.dart';
import 'package:bd_ludo/ui/widgets/%20premium_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'setup_modal.dart';
import 'howto_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameEngine>(
      builder: (_, eng, __) {
        if (eng.inGame) return const GameScreen();

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _topBar(context),
                      const SizedBox(height: 10),
                      _hero(),
                      const SizedBox(height: 14),

                      Expanded(
                        child: LayoutBuilder(
                          builder: (_, box) {
                            final isWide = box.maxWidth > 900;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: PremiumButton(
                                        title: "Play Now",
                                        subtitle: "Guest mode • Play offline",
                                        icon: Icons.sports_esports_rounded,
                                        onTap: () => showSetup(context),
                                      ),
                                    ),
                                    if (isWide) const SizedBox(width: 12),
                                    if (isWide)
                                      Expanded(
                                        child: PremiumButton(
                                          title: "How to Play",
                                          subtitle: "Rules • Safe stars • Home stretch",
                                          icon: Icons.menu_book_rounded,
                                          color: Theme.of(context).colorScheme.secondary,
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToScreen())),
                                        ),
                                      ),
                                    if (isWide) const SizedBox(width: 12),
                                    if (isWide)
                                      Expanded(
                                        child: PremiumButton(
                                          title: "History",
                                          subtitle: "Last 10 matches (local)",
                                          icon: Icons.history_rounded,
                                          color: Colors.white.withOpacity(.18),
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (!isWide)
                                      Expanded(
                                        child: PremiumButton(
                                          title: "How to Play",
                                          subtitle: "Rules • Safe stars • Home stretch",
                                          icon: Icons.menu_book_rounded,
                                          color: Theme.of(context).colorScheme.secondary,
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToScreen())),
                                        ),
                                      ),
                                    if (!isWide) const SizedBox(width: 12),
                                    Expanded(
                                      child: PremiumButton(
                                        title: "Settings",
                                        subtitle: "Sound • Exact roll • Auto move",
                                        icon: Icons.tune_rounded,
                                        color: Colors.white.withOpacity(.18),
                                        onTap: () => showSettings(context),
                                      ),
                                    ),
                                    if (!isWide) const SizedBox(width: 12),
                                    if (!isWide)
                                      Expanded(
                                        child: PremiumButton(
                                          title: "History",
                                          subtitle: "Last 10 matches (local)",
                                          icon: Icons.history_rounded,
                                          color: Colors.white.withOpacity(.18),
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      color: Colors.black.withOpacity(.18),
                                      border: Border.all(color: Colors.white.withOpacity(.14)),
                                      boxShadow: const [BoxShadow(blurRadius: 55, offset: Offset(0, 18), color: Color(0x55000000))],
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: const _BanglaFooter(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(.10),
            border: Border.all(color: Colors.white.withOpacity(.16)),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Bangladeshi Ludo", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: .3)),
            SizedBox(height: 2),
            Text("Offline • Web + Mobile", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFFB8D6FF))),
          ]),
        ),
        Row(
          children: [
            _pill("Space", "ROLL"),
          ],
        )
      ],
    );
  }

  Widget _pill(String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.black.withOpacity(.18),
        border: Border.all(color: Colors.white.withOpacity(.16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(.12),
              border: Border.all(color: Colors.white.withOpacity(.14)),
            ),
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
          ),
          const SizedBox(width: 8),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFB8D6FF))),
        ],
      ),
    );
  }

  Widget _hero() {
    return Column(
      children: const [
        Text("BANGLADESHI LUDO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 34, letterSpacing: .6)),
        SizedBox(height: 6),
        Text("Jamdani vibe • Smooth animations • Correct rules", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFB8D6FF))),
      ],
    );
  }

  void showSetup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SetupModal(),
    );
  }

  void showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }
}

class _BanglaFooter extends StatelessWidget {
  const _BanglaFooter();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Practice Build Notes", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: .3)),
        SizedBox(height: 10),
        Text("• ৬ ছাড়া ঘর থেকে বের হবে না\n• ৬ পেলে extra turn\n• Safe star cell এ capture হবে না\n• Home stretch color-specific\n• Exact roll toggle settings এ",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFB8D6FF), height: 1.5)),
        SizedBox(height: 12),
        Text("Ready to expand: Undo, stronger AI, avatars, real sound assets.",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFFB8D6FF))),
      ],
    );
  }
}
