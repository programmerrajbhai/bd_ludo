import 'package:bd_ludo/%20game/constants.dart';
import 'package:bd_ludo/%20game/engine.dart';
import 'package:bd_ludo/%20game/painter.dart';
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
      backgroundColor: const Color(0xFF18191A), // ডার্ক ব্যাকগ্রাউন্ড
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
              // ১. টপ বার
              _buildTopBar(context, eng),
              
              // ২. বোর্ড এবং প্লেয়ার
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    final boardSize = size.shortestSide * 0.95;
                    
                    return Center(
                      child: SizedBox(
                        width: boardSize,
                        height: boardSize,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            
                            // --- বোর্ড ক্যানভাস ---
                            Positioned.fill(
                              child: _buildBoardCanvas(context, eng),
                            ),

                            // --- ৪টি প্লেয়ার প্রোফাইল ---
                            
                            // Red (Top-Left)
                            if (eng.players.isNotEmpty)
                              Positioned(
                                top: 0, left: 0,
                                child: _PlayerProfile(
                                  eng: eng, 
                                  playerIndex: 0, 
                                  alignment: CrossAxisAlignment.start
                                ),
                              ),

                            // Green (Top-Right)
                            if (eng.players.length > 1)
                              Positioned(
                                top: 0, right: 0,
                                child: _PlayerProfile(
                                  eng: eng, 
                                  playerIndex: 1, 
                                  alignment: CrossAxisAlignment.end
                                ),
                              ),

                            // Yellow (Bottom-Right)
                            if (eng.players.length > 2)
                              Positioned(
                                bottom: 0, right: 0,
                                child: _PlayerProfile(
                                  eng: eng, 
                                  playerIndex: 2, 
                                  alignment: CrossAxisAlignment.end
                                ),
                              ),

                            // Blue (Bottom-Left)
                            if (eng.players.length > 3)
                              Positioned(
                                bottom: 0, left: 0,
                                child: _PlayerProfile(
                                  eng: eng, 
                                  playerIndex: 3, 
                                  alignment: CrossAxisAlignment.start
                                ),
                              ),

                            // --- উইনার ডায়ালগ ---
                            if (eng.winner != null)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.amber, width: 2),
                                ),
                                padding: const EdgeInsets.all(30),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 60),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${eng.winner} Wins!", 
                                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () => eng.exitGame(),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                      child: const Text("Exit Game", style: TextStyle(color: Colors.white)),
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ৩. বটম স্ট্যাটাস
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF242526),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15))
                ),
                child: Text(
                  eng.winner == null 
                    ? "Current Turn: ${eng.cur().name.toUpperCase()}" 
                    : "GAME OVER",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2
                  ),
                ),
              ),
            ],
          ),
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
            // [FIXED] এখানে 'tokenDraw' প্যারামিটারটি মুছে ফেলা হয়েছে কারণ নতুন Painter এ এটি নেই
            painter: BoardPainter(
              players: eng.players,
              movable: eng.movable,
              lastDice: eng.dice,
            ),
            child: Container(),
          ),
        );
      },
    );
  }

  void _handleBoardTap(TapUpDetails details, double boardWidth, GameEngine eng) {
    if (!eng.rolled || eng.moving || eng.winner != null) return;

    final double cellSize = boardWidth / 15.0;
    final int x = (details.localPosition.dx / cellSize).floor();
    final int y = (details.localPosition.dy / cellSize).floor();

    final currentPlayer = eng.cur();
    
    // Check all tokens of current player
    for (int i = 0; i < currentPlayer.tokens.length; i++) {
      final t = currentPlayer.tokens[i];
      if (t.finished) continue;

      Offset tokenPos;
      
      // Determine position
      if (t.pos == -1) {
        tokenPos = homeYard[currentPlayer.color]![i]; 
      } else if (t.pos >= 100) {
        int step = t.pos - 100;
        if(step > 5) step = 5;
        tokenPos = homeStretch[currentPlayer.color]![step];
      } else {
        tokenPos = track[t.pos];
      }

      // Hit detection
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

  Widget _buildTopBar(BuildContext context, GameEngine eng) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => eng.exitGame(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
          ),
          const Text(
            "LUDO PRO",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 2),
          ),
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => const SettingsSheet(),
            ),
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
          ),
        ],
      ),
    );
  }
}

class _PlayerProfile extends StatelessWidget {
  final GameEngine eng;
  final int playerIndex;
  final CrossAxisAlignment alignment;

  const _PlayerProfile({
    required this.eng,
    required this.playerIndex,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final player = eng.players[playerIndex];
    final isTurn = eng.turn == playerIndex;
    final color = colorOf(player.color);

    return Padding(
      padding: const EdgeInsets.all(12.0), 
      child: Column(
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isTurn ? color.withOpacity(0.9) : Colors.black54,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isTurn ? Colors.white : Colors.transparent, width: 2),
              boxShadow: isTurn ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 10)] : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, color: Colors.white, size: 16),
                const SizedBox(width: 5),
                Text(
                  player.name.length > 6 ? "${player.name.substring(0,6)}.." : player.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),

          // Dice Area
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isTurn ? 1.0 : 0.3,
            child: SizedBox(
              width: 55,
              height: 55,
              child: Stack(
                children: [
                  DiceWidget(
                    value: isTurn ? eng.dice : (eng.turn == playerIndex ? eng.dice : 0),
                    rolling: isTurn && eng.isRolling,
                    onTap: () {
                      if (isTurn && !eng.rolled && eng.winner == null) {
                        eng.rollDice();
                      }
                    },
                  ),
                  if(isTurn && !eng.rolled)
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.touch_app, size: 12, color: Colors.black),
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}