import 'package:bd_ludo/%20game/%20%20painter.dart';
import 'package:bd_ludo/%20game/%20engine.dart';
import 'package:bd_ludo/%20game/constants.dart';
import 'package:bd_ludo/ui/widgets/%20%20dice_widget.dart';
import 'package:bd_ludo/ui/widgets/%20toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'settings_sheet.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // keyboard space roll
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eng = context.watch<GameEngine>();
    final cur = eng.cur();

    return Scaffold(
      body: SafeArea(
        child: Focus(
          focusNode: _focus,
          onKeyEvent: (_, e) {
            if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.space) {
              eng.rollDice();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: LayoutBuilder(
                  builder: (_, box) {
                    final wide = box.maxWidth > 980;
                    return Column(
                      children: [
                        _topBar(context, eng),
                        const SizedBox(height: 12),
                        Expanded(
                          child: wide
                              ? Row(
                                  children: [
                                    Expanded(child: _boardCard(context, eng)),
                                    const SizedBox(width: 12),
                                    SizedBox(width: 360, child: _sideCard(context, eng)),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Expanded(child: _boardCard(context, eng)),
                                    const SizedBox(height: 12),
                                    _sideCard(context, eng),
                                  ],
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, GameEngine eng) {
    return Row(
      children: [
        InkWell(
          onTap: () => eng.exitGame(),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.black.withOpacity(.18),
              border: Border.all(color: Colors.white.withOpacity(.16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_rounded, size: 18),
                SizedBox(width: 6),
                Text("Back", style: TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            eng.mode,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const SettingsSheet(),
          ),
          icon: const Icon(Icons.tune_rounded),
        )
      ],
    );
  }

  Widget _boardCard(BuildContext context, GameEngine eng) {
    // Build token draw positions (grid positions)
    final draw = <Map<String, dynamic>>[];

    for (int pi = 0; pi < eng.players.length; pi++) {
      final p = eng.players[pi];
      final col = colorOf(p.color);

      for (int ti = 0; ti < 4; ti++) {
        final t = p.tokens[ti];
        if (t.finished) continue;

        // determine grid coordinate
        Offset g;
        if (t.pos == -1) {
          g = homeYard[p.color]![ti];
        } else if (t.pos >= 0 && t.pos < 52) {
          g = track[t.pos];
        } else {
          // home stretch 100..105
          final idx = (t.pos - 100).clamp(0, 5);
          g = homeStretch[p.color]![idx];
        }

        final glow = (eng.rolled && eng.turn == pi && eng.movable.contains(ti));
        draw.add({'color': col, 'x': g.dx, 'y': g.dy, 'glow': glow, 'pi': pi, 'ti': ti});
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.black.withOpacity(.18),
        border: Border.all(color: Colors.white.withOpacity(.14)),
        boxShadow: const [BoxShadow(blurRadius: 55, offset: Offset(0, 18), color: Color(0x55000000))],
      ),
      child: LayoutBuilder(
        builder: (_, box) {
          final s = box.biggest.shortestSide;
          return GestureDetector(
            onTapUp: (d) {
              if (!eng.rolled || eng.moving || eng.winner != null) return;
              final local = d.localPosition;

              final cell = s / grid;
              final gx = (local.dx / cell).floor();
              final gy = (local.dy / cell).floor();

              // find token hit
              for (final td in draw.reversed) {
                if ((td['x'] as double).round() == gx && (td['y'] as double).round() == gy) {
                  final pi = td['pi'] as int;
                  final ti = td['ti'] as int;
                  if (pi == eng.turn && eng.movable.contains(ti)) {
                    eng.moveToken(ti);
                  } else if (pi == eng.turn && eng.rolled) {
                    Toasty.show(context, "এই টোকেন move করা যাবে না");
                  }
                  return;
                }
              }
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: BoardPainter(tokenDraw: draw, safeCells: safeTrack),
                child: const SizedBox.expand(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sideCard(BuildContext context, GameEngine eng) {
    final p = eng.cur();
    final dotColor = colorOf(p.color);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.black.withOpacity(.18),
        border: Border.all(color: Colors.white.withOpacity(.14)),
        boxShadow: const [BoxShadow(blurRadius: 55, offset: Offset(0, 18), color: Color(0x55000000))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(color: dotColor, borderRadius: BorderRadius.circular(99))),
            const SizedBox(width: 10),
            Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
            if (p.team != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withOpacity(.10),
                  border: Border.all(color: Colors.white.withOpacity(.14)),
                ),
                child: Text("Team ${p.team}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFB8D6FF))),
              ),
          ]),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(.10),
                    border: Border.all(color: Colors.white.withOpacity(.14)),
                  ),
                  child: Text(
                    eng.winner != null
                        ? "WINNER: ${eng.winner}"
                        : eng.rolled
                            ? (eng.movable.isEmpty ? "No moves. Next turn…" : "Choose a token")
                            : "Tap dice to ROLL (Space)",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFB8D6FF)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              DiceWidget(
                value: eng.dice,
                rolling: eng.rolled && eng.dice == 0, // not used, but kept
                onTap: () => eng.rollDice(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: eng.winner != null ? null : () => eng.rollDice(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("ROLL", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .6)),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => eng.exitGame(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.white.withOpacity(.18)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("EXIT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .6)),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.black.withOpacity(.18),
                border: Border.all(color: Colors.white.withOpacity(.14)),
              ),
              child: Text(
                "Turn: ${eng.turn + 1}/${eng.players.length}\n"
                "Dice: ${eng.dice}\n"
                "Movable tokens: ${eng.movable.length}\n"
                "Rules: 6 to start, safe stars, capture, home stretch\n",
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, height: 1.5, color: Color(0xFFB8D6FF)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
