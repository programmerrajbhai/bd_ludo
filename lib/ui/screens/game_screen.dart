import 'dart:ui';
import 'dart:math' as math;
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
  final String bgAsset = "assets/images/ludo_bg.png";

  @override
  void initState() {
    super.initState();
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

    final idxRed = _indexByColor(eng, 'red');
    final idxGreen = _indexByColor(eng, 'green');
    final idxBlue = _indexByColor(eng, 'blue');
    final idxYellow = _indexByColor(eng, 'yellow');

    return Scaffold(
      backgroundColor: Colors.black,
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
            // বোর্ড সাইজ ৭৫% রাখা হয়েছে সেফটির জন্য
            final boardSize = minSide * 0.75;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // ---------------------------------------------------
                // 1. BACKGROUND LAYER
                // ---------------------------------------------------
                Positioned.fill(
                  child: Stack(
                    children: [
                      Image.asset(
                        bgAsset,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.3,
                                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                              ),
                            ),
                          );
                        },
                      ),
                      Container(color: Colors.black.withOpacity(0.40)),
                    ],
                  ),
                ),

                // ---------------------------------------------------
                // 2. CENTER BOARD
                // ---------------------------------------------------
                Center(
                  child: SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: _buildBoardCanvas(context, eng),
                  ),
                ),

                // ---------------------------------------------------
                // 3. CORNER PANELS (With Specific Names & Alignment)
                // ---------------------------------------------------
                
                // Top-Left: RED -> "Player 1" (Text BELOW Dice)
                if (idxRed != null)
                  Positioned(
                    top: 20, 
                    left: 20,
                    child: _CornerDicePanel(
                      eng: eng,
                      playerIndex: idxRed,
                      alignment: CrossAxisAlignment.start,
                      isTop: true, // ✅ Text will be BELOW dice
                      customName: "Player 1", // ✅ Specific Name
                    ),
                  ),

                // Top-Right: GREEN -> "Computer" (Text BELOW Dice)
                if (idxGreen != null)
                  Positioned(
                    top: 20, 
                    right: 20,
                    child: _CornerDicePanel(
                      eng: eng,
                      playerIndex: idxGreen,
                      alignment: CrossAxisAlignment.end,
                      isTop: true, // ✅ Text will be BELOW dice
                      customName: "Computer", // ✅ Specific Name
                    ),
                  ),

                // Bottom-Left: BLUE -> "Player 2" (Text ABOVE Dice - As is)
                if (idxBlue != null)
                  Positioned(
                    bottom: 20, 
                    left: 20,
                    child: _CornerDicePanel(
                      eng: eng,
                      playerIndex: idxBlue,
                      alignment: CrossAxisAlignment.start,
                      isTop: false, // ✅ Text will be ABOVE dice (default)
                      customName: "Player 2", // ✅ Specific Name
                    ),
                  ),

                // Bottom-Right: YELLOW -> "Player 3" (Text ABOVE Dice - As is)
                if (idxYellow != null)
                  Positioned(
                    bottom: 20, 
                    right: 20,
                    child: _CornerDicePanel(
                      eng: eng,
                      playerIndex: idxYellow,
                      alignment: CrossAxisAlignment.end,
                      isTop: false, // ✅ Text will be ABOVE dice (default)
                      customName: "Player 3", // ✅ Specific Name
                    ),
                  ),

                // ---------------------------------------------------
                // 4. WINNER OVERLAY
                // ---------------------------------------------------
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
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 35,
                spreadRadius: 2,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 0,
                spreadRadius: 1.5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              onTapUp: (details) => _handleBoardTap(details, constraints.maxWidth, eng),
              child: CustomPaint(
                painter: BoardPainter(
                  players: eng.players,
                  movable: eng.movable,
                  lastDice: eng.dice,
                ),
                child: const SizedBox.expand(),
              ),
            ),
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
        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
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
        int step = t.pos - 100; if (step > 5) step = 5;
        tokenPos = homeStretch[currentPlayer.color]![step];
      } else {
        tokenPos = track[t.pos];
      }
      if ((tokenPos.dx - x).abs() < 0.8 && (tokenPos.dy - y).abs() < 0.8) {
        if (eng.movable.contains(i)) {
          eng.moveToken(i); return;
        } else {
          Toasty.show(context, "Invalid Move!");
        }
      }
    }
  }
}

// -------------------------------------------------------------
// UPDATED CORNER PANEL WIDGET (Handles Name Position & Custom Text)
// -------------------------------------------------------------

class _CornerDicePanel extends StatelessWidget {
  final GameEngine eng;
  final int playerIndex;
  final CrossAxisAlignment alignment;
  final bool isTop;
  final String customName; // ✅ নতুন প্যারামিটার: কাস্টম নাম শো করার জন্য

  const _CornerDicePanel({
    required this.eng,
    required this.playerIndex,
    required this.alignment,
    required this.isTop,
    required this.customName,
  });

  @override
  Widget build(BuildContext context) {
    final player = eng.players[playerIndex];
    final isTurn = eng.turn == playerIndex;
    final color = colorOf(player.color); 
    final isRightSide = alignment == CrossAxisAlignment.end;

    // ১. ডাইস এবং এক্সট্রা আইটেম (কয়েন ইত্যাদি)
    Widget diceRow = isTurn
        ? Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: isRightSide ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDiceWithPointer(context, eng, color, isTop),
              const SizedBox(width: 8),
              _buildExtraInfoItem(),
            ],
          )
        : _buildInactivePlaceholder();

    // ২. নাম লেখার বক্স (কাস্টম নাম ব্যবহার করা হবে)
    Widget nameBox = _buildPlayerNameBox(customName, isTurn, color, isRightSide);

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: isTop
          // ✅ টপ সেকশনের জন্য: আগে ডাইস, তারপর নাম (নিচে)
          ? [
              diceRow,
              const SizedBox(height: 5),
              nameBox, // <-- Name is BELOW Dice
            ]
          // ✅ বটম সেকশনের জন্য: আগে নাম (উপরে), তারপর ডাইস
          : [
              nameBox, // <-- Name is ABOVE Dice
              const SizedBox(height: 5),
              diceRow,
            ],
    );
  }

  Widget _buildPlayerNameBox(String name, bool isTurn, Color color, bool isRightSide) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 6),
              // ✅ এখানে আপনার দেওয়া কাস্টম নাম শো হবে
              Text(
                name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.8,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiceWithPointer(BuildContext context, GameEngine eng, Color color, bool isTop) {
    return SizedBox(
      width: 70,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Glow
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 30, spreadRadius: 5)],
            ),
          ),
          // Dice
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
          // Pointer Arrow (Direction Adjusted)
          if (!eng.rolled && !eng.isRolling)
            Positioned(
              top: isTop ? null : -20,    
              bottom: isTop ? -20 : null, 
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 8),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                builder: (context, val, child) {
                  return Transform.translate(
                    offset: Offset(0, isTop ? -val : val),
                    child: Icon(
                      isTop ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: Colors.yellowAccent, 
                      size: 28, 
                      shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                    ),
                  );
                },
                onEnd: () {},
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExtraInfoItem() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
    );
  }

  Widget _buildInactivePlaceholder() {
    return Container(
      width: 55, height: 55,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.casino_outlined, color: Colors.white24, size: 26),
    );
  }
}