import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/domain/game/game_models.dart';

void main() {
  group('BoardSize', () {
    test('dimension returns correct grid size', () {
      expect(BoardSize.three.dimension, 3);
      expect(BoardSize.four.dimension, 4);
      expect(BoardSize.five.dimension, 5);
    });

    test('label returns human-readable string', () {
      expect(BoardSize.three.label, '3 × 3');
      expect(BoardSize.four.label, '4 × 4');
      expect(BoardSize.five.label, '5 × 5');
    });
  });

  group('Tile', () {
    test('copy creates independent copy', () {
      final t = Tile(id: 1, row: 0, col: 1, value: 4);
      final c = t.copy();
      expect(c.id, 1);
      expect(c.row, 0);
      expect(c.col, 1);
      expect(c.value, 4);
      c.row = 2;
      expect(t.row, 0);
    });
  });

  group('GameState', () {
    test('maxTile returns highest tile value', () {
      final state = GameState(
        size: BoardSize.four,
        tiles: [
          Tile(id: 0, row: 0, col: 0, value: 2),
          Tile(id: 1, row: 0, col: 1, value: 64),
          Tile(id: 2, row: 1, col: 0, value: 8),
        ],
        score: 0,
        bestScore: 0,
        isGameOver: false,
        isWin: false,
      );
      expect(state.maxTile, 64);
    });

    test('maxTile returns 0 for empty tiles', () {
      final state = GameState(
        size: BoardSize.four,
        tiles: const [],
        score: 0,
        bestScore: 0,
        isGameOver: false,
        isWin: false,
      );
      expect(state.maxTile, 0);
    });

    test('copyWith preserves unchanged fields', () {
      final state = GameState(
        size: BoardSize.four,
        tiles: [Tile(id: 0, row: 0, col: 0, value: 2)],
        score: 100,
        bestScore: 200,
        isGameOver: false,
        isWin: false,
      );
      final updated = state.copyWith(score: 150);
      expect(updated.score, 150);
      expect(updated.bestScore, 200);
      expect(updated.tiles.length, 1);
    });
  });

  group('MissionProgress', () {
    test('empty has all false', () {
      expect(MissionProgress.empty.reached64, false);
      expect(MissionProgress.empty.scoreOver1000, false);
      expect(MissionProgress.empty.winOnFive, false);
    });

    test('fromJson parses correctly', () {
      final m = MissionProgress.fromJson({
        'reached64': true,
        'scoreOver1000': false,
        'winOnFive': true,
      });
      expect(m.reached64, true);
      expect(m.scoreOver1000, false);
      expect(m.winOnFive, true);
    });

    test('toJson round-trip', () {
      const m = MissionProgress(
        reached64: true,
        scoreOver1000: true,
        winOnFive: false,
      );
      final json = m.toJson();
      final restored = MissionProgress.fromJson(json);
      expect(restored.reached64, m.reached64);
      expect(restored.scoreOver1000, m.scoreOver1000);
      expect(restored.winOnFive, m.winOnFive);
    });
  });
}
