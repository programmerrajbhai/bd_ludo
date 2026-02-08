class Token {
  int pos; // -1 home yard, 0..51 track, 100..105 home stretch
  bool finished;
  Token({this.pos = -1, this.finished = false});

  Token copy() => Token(pos: pos, finished: finished);
}

class Player {
  final String color;     // red/green/yellow/blue
  String name;
  bool isAI;
  String? team;           // 'A'/'B' for team mode
  final List<Token> tokens;

  Player({
    required this.color,
    required this.name,
    required this.isAI,
    required this.tokens,
    this.team,
  });

  Player copy() => Player(
    color: color,
    name: name,
    isAI: isAI,
    team: team,
    tokens: tokens.map((t) => t.copy()).toList(),
  );
}

class SettingsModel {
  bool soundOn;
  bool exactRoll;
  bool autoMove;
  bool showHints;
  String diceSpeed; // slow/normal/fast
  String aiLevel;   // easy/normal/hard

  SettingsModel({
    this.soundOn = true,
    this.exactRoll = true,
    this.autoMove = true,
    this.showHints = true,
    this.diceSpeed = 'normal',
    this.aiLevel = 'normal',
  });

  Map<String, dynamic> toJson() => {
    'soundOn': soundOn,
    'exactRoll': exactRoll,
    'autoMove': autoMove,
    'showHints': showHints,
    'diceSpeed': diceSpeed,
    'aiLevel': aiLevel,
  };

  static SettingsModel fromJson(Map<String, dynamic> j) => SettingsModel(
    soundOn: (j['soundOn'] ?? true) as bool,
    exactRoll: (j['exactRoll'] ?? true) as bool,
    autoMove: (j['autoMove'] ?? true) as bool,
    showHints: (j['showHints'] ?? true) as bool,
    diceSpeed: (j['diceSpeed'] ?? 'normal') as String,
    aiLevel: (j['aiLevel'] ?? 'normal') as String,
  );
}

class MatchHistoryItem {
  final String dateIso;
  final String mode;
  final List<String> players;
  final String winner;

  MatchHistoryItem({
    required this.dateIso,
    required this.mode,
    required this.players,
    required this.winner,
  });

  Map<String, dynamic> toJson() => {
    'dateIso': dateIso,
    'mode': mode,
    'players': players,
    'winner': winner,
  };

  static MatchHistoryItem fromJson(Map<String, dynamic> j) => MatchHistoryItem(
    dateIso: (j['dateIso'] ?? '') as String,
    mode: (j['mode'] ?? '') as String,
    players: List<String>.from((j['players'] ?? const []) as List),
    winner: (j['winner'] ?? '') as String,
  );
}
