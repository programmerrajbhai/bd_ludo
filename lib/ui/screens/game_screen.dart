import 'dart:ui'; // Required for BackdropFilter
import 'package:bd_ludo/%20game/constants.dart';
import 'package:bd_ludo/%20game/engine.dart';
import 'package:bd_ludo/%20game/painter.dart';
import 'package:bd_ludo/ui/widgets/%20%20dice_widget.dart';
import 'package:bd_ludo/ui/widgets/%20toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _focus = FocusNode();

  // Background Image Asset
  final String bgAsset = "assets/images/ludo_bg.png";

  @override
  void initState() {
    super.initState();
    // Full screen immersive mode (Hide Status Bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _focus.dispose();
    super.dispose();
  }

  int? _indexByColor(GameEngine eng, String color) {
    final i = eng.players.indexWhere((p) => (p.color ?? '').toString().toLowerCase() == color);
    return i < 0 ? null : i;
  }

  @override
  Widget build(BuildContext context) {
    final eng = context.watch<GameEngine>();

    // Mapping Players to Colors
    final idxRed = _indexByColor(eng, 'red');
    final idxGreen = _indexByColor(eng, 'green');
    final idxBlue = _indexByColor(eng, 'blue');
    final idxYellow = _indexByColor(eng, 'yellow');

    return Scaffold(
      backgroundColor: Colors.black, // Fallback color
      resizeToAvoidBottomInset: false,
      body: Focus(
        focusNode: _focus,
        onKeyEvent: (_, e) {
          if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.space) {
            if (!eng.rolled && eng.winner == null) eng.rollDice();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final minSide = size.shortestSide;
            
            // Adjust board size (85-90% width usually good for mobile)
            final boardSize = minSide * 0.90;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Full Bleed Background
                Positioned.fill(
                  child: Stack(
                    children: [
                      Image.asset(
                        bgAsset,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) {
                          // Luxurious Dark Gradient Fallback
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.2,
                                colors: [
                                  Color(0xFF0F2027),
                                  Color(0xFF203A43),
                                  Color(0xFF2C5364),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Dark Overlay for better contrast
                      Container(color: Colors.black.withOpacity(0.35)),
                    ],
                  ),
                ),

                // 2. Centered Board
                Center(
                  child: SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: _buildBoardCanvas(context, eng),
                  ),
                ),

                // 3. Four Corner Dice Panels (Glassmorphic + Pointer + Name)
                
                // Top-Left: RED
                if (idxRed != null)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: _CornerDicePanel(
                      eng: eng,
                      playerIndex: idxRed,
                      alignment: CrossAxisAlignment.start,
                    ),
                  ),

                // Top-Right: GREEN
                if (idxGreen != null)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _CornerDicePanel(
                      eng: eng,
                      playerIndex: idxGreen,
                      alignment: CrossAxisAlignment.end,
                    ),
                  ),

                // Bottom-Left: BLUE
                if (idxBlue != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: _CornerDicePanel(
                      eng: eng,
                      playerIndex: idxBlue,
                      alignment: CrossAxisAlignment.start,
                    ),
                  ),

                // Bottom-Right: YELLOW
                if (idxYellow != null)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: _CornerDicePanel(
                      eng: eng,
                      playerIndex: idxYellow,
                      alignment: CrossAxisAlignment.end,
                    ),
                  ),

                // 4. Winner Dialog Overlay
                if (eng.winner != null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.85),
                      alignment: Alignment.center,
                      child: _buildWinnerDialog(eng),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBoardCanvas(BuildContext context, GameEngine eng) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return GestureDetector(
          onTapUp: (details) => _handleBoardTap(details, constraints.maxWidth, eng),
          child: CustomPaint(
            painter: BoardPainter(
              players: eng.players,
              movable: eng.movable,
              lastDice: eng.dice,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  Widget _buildWinnerDialog(GameEngine eng) {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 70),
          const SizedBox(height: 15),
          Text(
            "${eng.winner} Wins!",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () => eng.exitGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text("Exit Game", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _handleBoardTap(TapUpDetails details, double boardWidth, GameEngine eng) {
    if (!eng.rolled || eng.moving || eng.winner != null) return;

    final double cellSize = boardWidth / 15.0;
    final int x = (details.localPosition.dx / cellSize).floor();
    final int y = (details.localPosition.dy / cellSize).floor();

    final currentPlayer = eng.cur();

    for (int i = 0; i < currentPlayer.tokens.length; i++) {
      final t = currentPlayer.tokens[i];
      if (t.finished) continue;

      Offset tokenPos;

      if (t.pos == -1) {
        tokenPos = homeYard[currentPlayer.color]![i];
      } else if (t.pos >= 100) {
        int step = t.pos - 100;
        if (step > 5) step = 5;
        tokenPos = homeStretch[currentPlayer.color]![step];
      } else {
        tokenPos = track[t.pos];
      }

      if ((tokenPos.dx - x).abs() < 0.8 && (tokenPos.dy - y).abs() < 0.8) {
        if (eng.movable.contains(i)) {
          eng.moveToken(i);
          return;
        } else {
          Toasty.show(context, "Invalid Move!");
        }
      }
    }
  }
}

// ✅ 100% Realistic Glassmorphic Corner Panel with Name & Pointer
class _CornerDicePanel extends StatelessWidget {
  final GameEngine eng;
  final int playerIndex;
  final CrossAxisAlignment alignment;

  const _CornerDicePanel({
    required this.eng,
    required this.playerIndex,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final player = eng.players[playerIndex];
    final isTurn = eng.turn == playerIndex;
    final color = colorOf(player.color); // Using colorOf from constants.dart
    final isRightSide = alignment == CrossAxisAlignment.end;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        // 1. Player Info Box (Glass + Name)
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isTurn ? color.withOpacity(0.3) : Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isTurn ? color : Colors.white10,
                  width: isTurn ? 1.5 : 1,
                ),
                boxShadow: isTurn
                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 1)]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: isRightSide ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  // Avatar Circle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white30, width: 1),
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  // ✅ Player Name
                  Text(
                    player.name.length > 8 ? "${player.name.substring(0,6)}.." : player.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.8,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 2. Dice Area (Active Only on Turn) with POINTER
        if (isTurn)
          SizedBox(
            width: 75,
            height: 85, // Height increased for pointer space
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Dice Glow Background
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.6),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                // Actual Dice
                DiceWidget(
                  value: eng.dice,
                  rolling: eng.isRolling,
                  onTap: () {
                    if (!eng.rolled && eng.winner == null) {
                      eng.rollDice();
                    } else if (eng.rolled) {
                      Toasty.show(context, "Already rolled! Move token.");
                    }
                  },
                ),
                // ✅ Animated Pointer (Arrow)
                if (!eng.rolled && !eng.isRolling)
                  Positioned(
                    top: -15, // Positioned above the dice
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 8),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOut,
                      builder: (context, val, child) {
                        return Transform.translate(
                          offset: Offset(0, val), // Up and down movement
                          child: Icon(
                            Icons.arrow_downward_rounded, 
                            color: Colors.yellowAccent, 
                            size: 32,
                            shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                          ),
                        );
                      },
                      onEnd: () {}, 
                    ),
                  ),
              ],
            ),
          )
        else
          // Inactive Placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.casino_outlined, color: Colors.white24, size: 28),
          ),
      ],
    );
  }
}