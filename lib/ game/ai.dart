import 'package:bd_ludo/%20game/models.dart';

import 'constants.dart';

import 'rules.dart';

int pickAiMove({
  required List<Player> players,
  required int curIndex,
  required int dice,
  required SettingsModel settings,
}) {
  final p = players[curIndex];
  final movable = listMovableTokens(p, dice, settings);
  if (movable.isEmpty) return -1;

  double bestScore = -1e9;
  int bestTi = movable.first;

  for (final ti in movable) {
    final s = scoreMove(players, curIndex, ti, dice, settings);
    if (s > bestScore) {
      bestScore = s;
      bestTi = ti;
    }
  }
  return bestTi;
}

double scoreMove(List<Player> players, int pi, int ti, int dice, SettingsModel settings) {
  final p = players[pi];
  final t = p.tokens[ti];

  double score = 0;

  // bring out
  if (t.pos == -1) {
    score += 35;
    return score;
  }

  // landing approx (only for track landing)
  int? landing;
  if (t.pos >= 0 && t.pos < 52) {
    final entry = entryIndex[p.color]!;
    final distToEntry = (entry - t.pos + 52) % 52;
    if (dice <= distToEntry) {
      landing = (t.pos + dice) % 52;
      score += dice * 2;
    } else {
      // into home stretch
      score += 40;
    }
  } else if (t.pos >= 100 && t.pos <= 105) {
    score += 60;
  }

  // capture preference
  if (landing != null && !safeTrack.contains(landing)) {
    for (var opi = 0; opi < players.length; opi++) {
      if (opi == pi) continue;
      for (final ot in players[opi].tokens) {
        if (!ot.finished && ot.pos == landing) score += 90;
      }
    }
  }

  // safe square preference
  if (landing != null && safeTrack.contains(landing)) score += 12;

  // risky square (hard)
  if (landing != null && settings.aiLevel == 'hard') {
    double risk = 0;
    for (var opi = 0; opi < players.length; opi++) {
      if (opi == pi) continue;
      for (final ot in players[opi].tokens) {
        if (ot.pos >= 0 && ot.pos < 52) {
          final dist = (landing - ot.pos + 52) % 52;
          if (dist >= 1 && dist <= 6) risk += 10;
        }
      }
    }
    score -= risk;
  }

  return score;
}
