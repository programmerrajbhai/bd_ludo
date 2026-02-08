import 'package:bd_ludo/%20game/%20engine.dart';
import 'package:bd_ludo/%20game/%20models.dart';
import 'package:bd_ludo/%20game/constants.dart';
import 'package:bd_ludo/ui/widgets/%20toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SetupModal extends StatefulWidget {
  const SetupModal({super.key});

  @override
  State<SetupModal> createState() => _SetupModalState();
}

class _SetupModalState extends State<SetupModal> {
  String mode = 'PvAI 1v1';

  final nameCtrls = <String, TextEditingController>{
    'red': TextEditingController(text: 'Player 1'),
    'green': TextEditingController(text: 'Computer'),
    'yellow': TextEditingController(text: 'Player 3'),
    'blue': TextEditingController(text: 'Player 4'),
  };

  @override
  void dispose() {
    for (final c in nameCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eng = context.watch<GameEngine>();
    final cs = Theme.of(context).colorScheme;

    // ✅ Draggable + scrollable modal => overflow never happens
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFF083F7A),
              border: Border.all(color: Colors.white.withOpacity(.16)),
              boxShadow: const [
                BoxShadow(blurRadius: 55, offset: Offset(0, 18), color: Color(0x66000000))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header (fixed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Game Setup",
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: .4),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      )
                    ],
                  ),
                ),

                // Body (scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    padding: EdgeInsets.only(
                      left: 14,
                      right: 14,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _modeGrid(),
                        const SizedBox(height: 12),

                        if (mode.startsWith('PvAI')) _aiRow(eng),
                        const SizedBox(height: 8),

                        _namesSection(context),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.primary,
                                  foregroundColor: const Color(0xFF06213E),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () {
                                  final setupPlayers = _buildPlayers();
                                  if (setupPlayers.isEmpty) {
                                    Toasty.show(context, "Names ঠিক করুন (empty হতে পারবে না)");
                                    return;
                                  }
                                  context.read<GameEngine>().startGame(
                                        modeName: mode,
                                        setupPlayers: setupPlayers,
                                      );
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "START GAME",
                                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- UI blocks ----------

  Widget _modeGrid() {
    Widget choice(String title, String sub) {
      final active = mode == title;
      return InkWell(
        onTap: () => setState(() => mode = title),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: active ? const Color(0x22F7C62F) : Colors.white.withOpacity(.10),
            border: Border.all(color: active ? const Color(0x99F7C62F) : Colors.white.withOpacity(.14)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(
                    sub,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFFB8D6FF)),
                  ),
                ]),
              ),
              if (active) const Icon(Icons.check_circle, color: Color(0xFFF7C62F)),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (_, b) {
        final cols = b.maxWidth > 720 ? 3 : 2;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            choice('PvAI 1v1', '1 human vs 1 AI'),
            choice('PvAI 1v3', '1 human vs 3 AI'),
            choice('PvP 2P', '2 players hot-seat'),
            choice('3 Players', '3 players local'),
            choice('4 Players', '4 players local'),
            choice('Team 2v2', 'Red+Yellow vs Green+Blue'),
            choice('Solo 4', 'one person controls all'),
          ],
        );
      },
    );
  }

  Widget _aiRow(GameEngine eng) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: eng.settings.aiLevel,
            items: const [
              DropdownMenuItem(value: 'easy', child: Text('AI Easy')),
              DropdownMenuItem(value: 'normal', child: Text('AI Normal')),
              DropdownMenuItem(value: 'hard', child: Text('AI Hard')),
            ],
            onChanged: (v) {
              if (v == null) return;
              final s = eng.settings;
              s.aiLevel = v;
              eng.updateSettings(s);
            },
            decoration: const InputDecoration(labelText: "AI Difficulty"),
          ),
        ),
      ],
    );
  }

  Widget _namesSection(BuildContext context) {
    final colors = ['red', 'green', 'yellow', 'blue'];

    int wantPlayers = 2;
    if (mode == '3 Players') wantPlayers = 3;
    if (mode == '4 Players' || mode == 'Team 2v2' || mode == 'Solo 4' || mode == 'PvAI 1v3') wantPlayers = 4;

    return LayoutBuilder(
      builder: (_, b) {
        // ✅ responsive textfield width (prevents overflow in wrap)
        final fieldW = b.maxWidth >= 820
            ? 320.0
            : b.maxWidth >= 520
                ? (b.maxWidth / 2) - 8
                : b.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Player Names",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFB8D6FF)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(wantPlayers, (i) {
                final c = colors[i];
                return SizedBox(
                  width: fieldW,
                  child: TextField(
                    controller: nameCtrls[c],
                    decoration: InputDecoration(
                      labelText: "${c.toUpperCase()} player",
                      prefixIcon: Icon(Icons.circle, color: colorOf(c)),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  // ---------- Player build ----------

  List<Player> _buildPlayers() {
    List<String> active;

    if (mode == 'PvAI 1v1') {
      active = ['red', 'green'];
      nameCtrls['green']!.text =
          nameCtrls['green']!.text.trim().isEmpty ? "Computer" : nameCtrls['green']!.text;
    } else if (mode == 'PvAI 1v3') {
      active = ['red', 'green', 'yellow', 'blue'];
    } else if (mode == 'PvP 2P') {
      active = ['red', 'green'];
    } else if (mode == '3 Players') {
      active = ['red', 'green', 'yellow'];
    } else {
      active = ['red', 'green', 'yellow', 'blue'];
    }

    for (final c in active) {
      if (nameCtrls[c]!.text.trim().isEmpty) return [];
    }

    final list = <Player>[];
    for (final c in active) {
      final isAI = mode.startsWith('PvAI') ? (c != 'red') : false;

      list.add(Player(
        color: c,
        name: nameCtrls[c]!.text.trim(),
        isAI: isAI,
        team: mode == 'Team 2v2'
            ? (c == 'red' || c == 'yellow' ? 'A' : 'B')
            : null,
        tokens: List.generate(4, (_) => Token()),
      ));
    }

    // ✅ Solo 4 => all human
    if (mode == 'Solo 4') {
      for (final p in list) {
        p.isAI = false; // ✅ FIX: assignment, not ==
      }
    }

    // PvAI 1v3 => all except red AI
    if (mode == 'PvAI 1v3') {
      for (final p in list) {
        if (p.color != 'red') p.isAI = true;
      }
    }

    // PvAI 1v1 => green AI
    if (mode == 'PvAI 1v1') {
      for (final p in list) {
        if (p.color == 'green') p.isAI = true;
      }
    }

    return list;
  }
}
