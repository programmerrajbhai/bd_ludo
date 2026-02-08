import 'package:bd_ludo/%20game/painter.dart';
import 'package:bd_ludo/%20game/engine.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFF18191A), // Dark Theme Background
      body: SafeArea(
        child: Focus(
          focusNode: _focus,
          onKeyEvent: (_, e) {
            if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.space) {
              if (!eng.rolled && eng.winner == null) eng.rollDice();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Column(
            children: [
              // 1. Top Bar
              _buildTopBar(context, eng),
              
              // 2. Main Game Area
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 0.65, // Portrait mode aspect ratio
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boardSize = constraints.maxWidth * 0.90;
                        
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // --- The Ludo Board ---
                            SizedBox(
                              width: boardSize,
                              height: boardSize,
                              child: _buildBoard(context, eng),
                            ),

                            // --- 4 Players Corners ---
                            
                            // Player 0 (Red) - Top Left
                            if (eng.players.isNotEmpty)
                              Positioned(
                                top: 10, left: 10,
                                child: _PlayerProfile(eng: eng, index: 0),
                              ),

                            // Player 1 (Green) - Top Right
                            if (eng.players.length > 1)
                              Positioned(
                                top: 10, right: 10,
                                child: _PlayerProfile(eng: eng, index: 1),
                              ),

                            // Player 2 (Yellow) - Bottom Right
                            if (eng.players.length > 2)
                              Positioned(
                                bottom: 10, right: 10,
                                child: _PlayerProfile(eng: eng, index: 2),
                              ),

                            // Player 3 (Blue) - Bottom Left
                            if (eng.players.length > 3)
                              Positioned(
                                bottom: 10, left: 10,
                                child: _PlayerProfile(eng: eng, index: 3),
                              ),

                            // --- Winner Dialog Overlay ---
                            if (eng.winner != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.amber, width: 3),
                                  boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 20)],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
                                    const SizedBox(height: 10),
                                    Text("WINNER: ${eng.winner}", 
                                      style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold)
                                    ),
                                    const SizedBox(height: 15),
                                    ElevatedButton(
                                      onPressed: () => eng.exitGame(),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                      child: const Text("Exit Game", style: TextStyle(color: Colors.white)),
                                    )
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

              // 3. Bottom Status
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15))
                ),
                child: Text(
                  eng.winner == null ? "Turn: ${eng.cur().name}" : "Game Over",
                  style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, GameEngine eng) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => eng.exitGame(),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          Text(
            "BD LUDO",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5),
          ),
          InkWell(
            onTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => const SettingsSheet(),
            ),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
              child: const Icon(Icons.settings, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(BuildContext context, GameEngine eng) {
    final draw = <Map<String, dynamic>>[];
    
    // Loop through players to draw tokens
    for (int pi = 0; pi < eng.players.length; pi++) {
      final p = eng.players[pi];
      final col = colorOf(p.color); // Using new colorOf(int)

      for (int ti = 0; ti < 4; ti++) {
        final t = p.tokens[ti];
        if (t.finished) continue;

        Offset g;
        // Determine Grid Position
        if (t.pos == -1) {
          // Inside Home Yard
          g = homeYard[p.color]![ti]; 
        } else if (t.pos >= 0 && t.pos < 52) {
          // On Track
          g = track[t.pos];
        } else {
          // On Home Stretch
          final idx = (t.pos - 100).clamp(0, 5);
          g = homeStretch[p.color]![idx];
        }

        final glow = (eng.rolled && eng.turn == pi && eng.movable.contains(ti));
        draw.add({'color': col, 'x': g.dx, 'y': g.dy, 'glow': glow, 'pi': pi, 'ti': ti});
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Board Base
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, spreadRadius: 2)],
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

              for (final td in draw.reversed) {
                if ((td['x'] as double).round() == gx && (td['y'] as double).round() == gy) {
                  final pi = td['pi'] as int;
                  final ti = td['ti'] as int;
                  if (pi == eng.turn && eng.movable.contains(ti)) {
                    eng.moveToken(ti);
                  } else if (pi == eng.turn && eng.rolled) {
                    Toasty.show(context, "Invalid Move");
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
}

// --- Player Profile & Dice Widget ---
class _PlayerProfile extends StatelessWidget {
  final GameEngine eng;
  final int index;

  const _PlayerProfile({required this.eng, required this.index});

  @override
  Widget build(BuildContext context) {
    if (index >= eng.players.length) return const SizedBox();

    final player = eng.players[index];
    final isMyTurn = eng.turn == index;
    final color = colorOf(player.color);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile Box
        Container(
          width: 65,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isMyTurn ? color.withOpacity(0.3) : Colors.black45,
            borderRadius: BorderRadius.circular(12),
            border: isMyTurn ? Border.all(color: color, width: 2) : Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 1)),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: color,
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                player.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Dice Box
        SizedBox(
          width: 50,
          height: 50,
          child: IgnorePointer(
            ignoring: !isMyTurn || eng.moving || eng.winner != null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow Animation
                if (isMyTurn && !eng.rolled)
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: color.withOpacity(0.8), blurRadius: 15, spreadRadius: 1)],
                    ),
                  ),
                
                // The Dice
                Opacity(
                  opacity: isMyTurn ? 1.0 : 0.5,
                  child: DiceWidget(
                    value: isMyTurn ? eng.dice : (eng.turn == index ? eng.dice : 0),
                    rolling: isMyTurn && eng.isRolling,
                    onTap: () {
                       if (isMyTurn && !eng.rolled && eng.winner == null) {
                         eng.rollDice();
                       }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}