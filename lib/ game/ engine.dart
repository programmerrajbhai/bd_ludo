import 'dart:async';
import 'dart:math';
import 'package:bd_ludo/%20game/%20%20sfx.dart';
import 'package:bd_ludo/%20game/%20models.dart';
import 'package:flutter/foundation.dart';

import 'constants.dart';

import 'rules.dart';
import 'ai.dart';
import 'storage.dart';


class GameEngine extends ChangeNotifier {
  // App state
  bool inGame = false;

  // Match state
  List<Player> players = [];
  String mode = 'PvAI 1v1';

  int turn = 0;          // index in players
  int dice = 0;          // last rolled value (1..6)
  bool rolled = false;   // current turn already rolled
  bool moving = false;   // token is animating
  bool isRolling = false;

  List<int> movable = []; // token indexes (0..3) that can move
  String? winner;

  // settings + history
  SettingsModel settings = SettingsModel();
  List<MatchHistoryItem> history = [];

  final Random _rng = Random();

  // ---- Load ----
  Future<void> loadHistoryAndSettings() async {
    settings = await loadSettings();
    history = await loadHistory();
    notifyListeners();
  }

  Future<void> updateSettings(SettingsModel s) async {
    settings = s;
    await saveSettings(settings);
    notifyListeners();
  }

  // ---- Start/Exit ----
  void startGame({
    required String modeName,
    required List<Player> setupPlayers,
  }) {
    mode = modeName;

    // deep copy players & tokens
    players = setupPlayers.map((p) => p.copy()).toList();

    inGame = true;
    turn = 0;
    dice = 0;
    rolled = false;
    isRolling = false;
    moving = false;
    movable = [];
    winner = null;

    notifyListeners();
    _maybeAiTurn();
  }

  void exitGame() {
    inGame = false;
    notifyListeners();
  }

  Player cur() => players[turn];

  // ---- Dice ----
  Future<void> rollDice() async {
    if (!inGame) return;
    if (winner != null) return;
    if (moving) return;
    if (rolled) return;          // already rolled this turn
    if (isRolling) return;

    isRolling = true;
    notifyListeners();

    await Sfx.dice(settings.soundOn);

    // rolling animation delay based on speed
    final ms = settings.diceSpeed == 'fast'
        ? 280
        : settings.diceSpeed == 'slow'
            ? 720
            : 450;

    await Future.delayed(Duration(milliseconds: ms));

    dice = 1 + _rng.nextInt(6);
    rolled = true;
    isRolling = false;

    // compute movable
    movable = listMovableTokens(cur(), dice, settings);

    // no possible move -> auto pass turn (still counts 6 extra? no, because no move)
    if (movable.isEmpty) {
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 350));
      _nextTurn();
      return;
    }

    // auto-move if only one choice and human + setting enabled
    if (settings.autoMove && movable.length == 1 && !cur().isAI) {
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 180));
      await moveToken(movable.first);
      return;
    }

    notifyListeners();
    _maybeAiTurn();
  }

  // ---- Move ----
  Future<void> moveToken(int tokenIndex) async {
    if (!inGame) return;
    if (winner != null) return;
    if (moving) return;
    if (!rolled) return;
    if (!movable.contains(tokenIndex)) return;

    moving = true;
    notifyListeners();

    final p = cur();
    final t = p.tokens[tokenIndex];

    // STEP animation speed
    final stepDelay = settings.diceSpeed == 'fast'
        ? 45
        : settings.diceSpeed == 'slow'
            ? 110
            : 70;

    // helper: tick + delay
    Future<void> stepTick() async {
      await Sfx.move(settings.soundOn);
      notifyListeners();
      await Future.delayed(Duration(milliseconds: stepDelay));
    }

    // ----------- Perform movement (step-by-step) -----------
    if (t.pos == -1) {
      // bring out with 6
      t.pos = startIndex[p.color]!;
      await stepTick();
    } else if (t.pos >= 0 && t.pos < 52) {
      final entry = entryIndex[p.color]!;
      final distToEntry = (entry - t.pos + 52) % 52;

      if (dice <= distToEntry) {
        // stay on track
        for (int k = 0; k < dice; k++) {
          t.pos = (t.pos + 1) % 52;
          await stepTick();
        }
      } else {
        // move to entry and go into home stretch
        for (int k = 0; k < distToEntry; k++) {
          t.pos = (t.pos + 1) % 52;
          await stepTick();
        }

        final into = dice - distToEntry - 1; // 0 means first stretch cell (100)
        int targetStretch = into;

        if (settings.exactRoll) {
          // exact roll needed to finish at 105
          if (targetStretch > 5) {
            // cannot move (should not happen due to rules guard)
            moving = false;
            notifyListeners();
            return;
          }
        } else {
          // clamp beyond finish
          if (targetStretch > 5) targetStretch = 5;
        }

        // enter stretch step-by-step
        for (int s = 0; s <= targetStretch; s++) {
          t.pos = 100 + s;
          await stepTick();
        }

        if (t.pos == 105) t.finished = true;
      }
    } else if (t.pos >= 100 && t.pos <= 105) {
      // already in home stretch
      final curStep = t.pos - 100;
      int target = curStep + dice;

      if (settings.exactRoll) {
        if (target > 5) {
          // illegal (guarded earlier)
          moving = false;
          notifyListeners();
          return;
        }
      } else {
        if (target > 5) target = 5;
      }

      for (int s = curStep + 1; s <= target; s++) {
        t.pos = 100 + s;
        await stepTick();
      }

      if (t.pos == 105) t.finished = true;
    }

    // ----------- Capture logic -----------
    // capture only if on track and not safe
    if (t.pos >= 0 && t.pos < 52 && !safeTrack.contains(t.pos)) {
      for (int opi = 0; opi < players.length; opi++) {
        if (opi == turn) continue;
        final op = players[opi];

        for (final ot in op.tokens) {
          if (!ot.finished && ot.pos == t.pos) {
            ot.pos = -1;
            await Sfx.capture(settings.soundOn);
          }
        }
      }
    }

    // ----------- Win check -----------
    _checkWinAndSaveIfNeeded();

    moving = false;

    if (winner != null) {
      // freeze turn, game end
      rolled = false;
      movable = [];
      notifyListeners();
      return;
    }

    // ----------- Extra turn on 6 -----------
    if (dice == 6) {
      // reset turn state but keep same player
      rolled = false;
      dice = 0;
      movable = [];
      notifyListeners();
      _maybeAiTurn();
      return;
    }

    // next player
    _nextTurn();
  }

  // ---- Turn control ----
  void _nextTurn() {
    rolled = false;
    isRolling = false;
    dice = 0;
    movable = [];
    turn = (turn + 1) % players.length;
    notifyListeners();
    _maybeAiTurn();
  }

  // ---- Win logic ----
  void _checkWinAndSaveIfNeeded() {
    // Team mode if team field exists
    final hasTeam = players.any((p) => p.team != null);

    if (hasTeam) {
      final teamA = players.where((p) => p.team == 'A').toList();
      final teamB = players.where((p) => p.team == 'B').toList();

      final aDone = teamA.isNotEmpty && teamA.every((p) => p!.tokens.every((t) => t.finished));
      final bDone = teamB.isNotEmpty && teamB.every((p) => p.tokens.every((t) => t.finished));

      if (aDone) winner = "Team A (Red+Yellow)";
      if (bDone) winner = "Team B (Green+Blue)";
    } else {
      for (final p in players) {
        if (p.tokens.every((t) => t.finished)) {
          winner = p.name;
          break;
        }
      }
    }

    if (winner != null) {
      Sfx.win(settings.soundOn);
      _saveHistory();
    }
  }

  Future<void> _saveHistory() async {
    final item = MatchHistoryItem(
      dateIso: DateTime.now().toIso8601String(),
      mode: mode,
      players: players.map((p) => "${p.name}(${p.color})").toList(),
      winner: winner ?? '',
    );
    history = [item, ...history].take(10).toList();
    await saveHistory(history);
    notifyListeners();
  }

  // ---- AI ----
  void _maybeAiTurn() {
    if (!inGame) return;
    if (winner != null) return;
    if (moving || isRolling) return;

    final p = cur();
    if (!p.isAI) return;

    // Delay so it feels natural
    Future.delayed(const Duration(milliseconds: 420), () async {
      if (!inGame) return;
      if (winner != null) return;
      if (moving || isRolling) return;

      // roll if not rolled
      if (!rolled) {
        await rollDice();
        return; // rollDice will re-call maybeAiTurn if needed
      }

      if (winner != null) return;
      if (moving) return;

      // if no moves -> pass turn (already handled by rollDice, but safe)
      if (movable.isEmpty) {
        _nextTurn();
        return;
      }

      final ti = pickAiMove(
        players: players,
        curIndex: turn,
        dice: dice,
        settings: settings,
      );

      if (ti < 0) {
        _nextTurn();
        return;
      }

      await Future.delayed(const Duration(milliseconds: 260));
      await moveToken(ti);
    });
  }
}
