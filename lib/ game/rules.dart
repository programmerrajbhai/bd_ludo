import 'package:bd_ludo/%20game/models.dart';

import 'constants.dart';


bool tokenCanMove(Player p, int ti, int dice, SettingsModel settings) {
  final t = p.tokens[ti];
  if (t.finished) return false;

  if (t.pos == -1) return dice == 6;

  // track
  if (t.pos >= 0 && t.pos < 52) {
    final entry = entryIndex[p.color]!;
    final distToEntry = (entry - t.pos + 52) % 52;

    if (dice <= distToEntry) return true;

    final into = dice - distToEntry - 1;
    if (into < 0) return true;

    if (into >= 6) {
      if (settings.exactRoll) return (into == 5);
      return true;
    }
    return true;
  }

  // home stretch
  if (t.pos >= 100 && t.pos <= 105) {
    final step = t.pos - 100;
    final target = step + dice;
    if (target > 5) return !settings.exactRoll;
    return true;
  }

  return false;
}

List<int> listMovableTokens(Player p, int dice, SettingsModel settings) {
  final out = <int>[];
  for (var i = 0; i < 4; i++) {
    if (tokenCanMove(p, i, dice, settings)) out.add(i);
  }
  return out;
}
