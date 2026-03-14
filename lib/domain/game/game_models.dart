import 'dart:math';

enum BoardSize { three, four, five }

extension BoardSizeX on BoardSize {
  int get dimension {
    switch (this) {
      case BoardSize.three:
        return 3;
      case BoardSize.four:
        return 4;
      case BoardSize.five:
        return 5;
    }
  }

  String get label {
    switch (this) {
      case BoardSize.three:
        return '3 × 3';
      case BoardSize.four:
        return '4 × 4';
      case BoardSize.five:
        return '5 × 5';
    }
  }
}

enum MoveDirection { up, down, left, right }

class Tile {
  Tile({
    required this.id,
    required this.row,
    required this.col,
    required this.value,
  });

  final int id;
  int row;
  int col;
  int value;

  Tile copy() => Tile(id: id, row: row, col: col, value: value);
}

class GameState {
  GameState({
    required this.size,
    required this.tiles,
    required this.score,
    required this.bestScore,
    required this.isGameOver,
    required this.isWin,
  });

  final BoardSize size;
  final List<Tile> tiles;
  final int score;
  final int bestScore;
  final bool isGameOver;
  final bool isWin;

  int get dimension => size.dimension;

  int get maxTile {
    var maxValue = 0;
    for (final t in tiles) {
      maxValue = max(maxValue, t.value);
    }
    return maxValue;
  }

  GameState copyWith({
    List<Tile>? tiles,
    int? score,
    int? bestScore,
    bool? isGameOver,
    bool? isWin,
  }) {
    return GameState(
      size: size,
      tiles: tiles != null ? tiles.map((t) => t.copy()).toList() : this.tiles.map((t) => t.copy()).toList(),
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      isGameOver: isGameOver ?? this.isGameOver,
      isWin: isWin ?? this.isWin,
    );
  }
}

class MissionProgress {
  const MissionProgress({
    required this.reached64,
    required this.scoreOver1000,
    required this.winOnFive,
  });

  final bool reached64;
  final bool scoreOver1000;
  final bool winOnFive;

  MissionProgress copyWith({
    bool? reached64,
    bool? scoreOver1000,
    bool? winOnFive,
  }) {
    return MissionProgress(
      reached64: reached64 ?? this.reached64,
      scoreOver1000: scoreOver1000 ?? this.scoreOver1000,
      winOnFive: winOnFive ?? this.winOnFive,
    );
  }

  Map<String, dynamic> toJson() => {
        'reached64': reached64,
        'scoreOver1000': scoreOver1000,
        'winOnFive': winOnFive,
      };

  factory MissionProgress.fromJson(Map<String, dynamic> json) {
    return MissionProgress(
      reached64: json['reached64'] as bool? ?? false,
      scoreOver1000: json['scoreOver1000'] as bool? ?? false,
      winOnFive: json['winOnFive'] as bool? ?? false,
    );
  }

  static const empty = MissionProgress(
    reached64: false,
    scoreOver1000: false,
    winOnFive: false,
  );
}

