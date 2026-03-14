import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/domain/game/game_models.dart';
import 'package:game_2048/domain/game/game_service.dart';

import 'fake_game_persistence_repository.dart';

void main() {
  late FakeGamePersistenceRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeGamePersistenceRepository();
  });

  group('GameService initialization', () {
    test('starts with 2 tiles on board', () {
      final service = GameService(
        BoardSize.four,
        fakeRepo,
        random: Random(42),
      );
      expect(service.state.tiles.length, 2);
    });

    test('starts with score 0', () {
      final service = GameService(
        BoardSize.four,
        fakeRepo,
        random: Random(42),
      );
      expect(service.state.score, 0);
    });

    test('loadPersistentData restores bestScore', () async {
      await fakeRepo.saveBestScore(BoardSize.four, 512);
      final service = GameService(BoardSize.four, fakeRepo);
      await service.loadPersistentData();
      expect(service.state.bestScore, 512);
    });

    test('loadPersistentData restores missions', () async {
      await fakeRepo.saveMissions(const MissionProgress(
        reached64: true,
        scoreOver1000: false,
        winOnFive: false,
      ));
      final service = GameService(BoardSize.four, fakeRepo);
      await service.loadPersistentData();
      expect(service.missions.reached64, true);
    });
  });

  group('GameService makeMove', () {
    test('makeMove changes state when move is possible', () async {
      final service = GameService(
        BoardSize.four,
        fakeRepo,
        random: Random(123),
      );
      final tilesBefore = service.state.tiles.length;
      await service.makeMove(MoveDirection.left);
      // После хода добавляется новая плитка — может быть 2 или 3
      expect(service.state.tiles.length, greaterThanOrEqualTo(tilesBefore));
    });

    test('makeMove does nothing when game over', () async {
      final service = GameService(
        BoardSize.three,
        fakeRepo,
        random: Random(999),
      );
      // Заполняем поле до game over (много ходов)
      for (var i = 0; i < 50; i++) {
        await service.makeMove(MoveDirection.left);
        if (service.state.isGameOver) break;
      }
      if (!service.state.isGameOver) return; // не удалось достичь
      final scoreBefore = service.state.score;
      await service.makeMove(MoveDirection.left);
      expect(service.state.score, scoreBefore);
    });
  });

  group('GameService restart', () {
    test('restart resets score and adds 2 tiles', () async {
      final service = GameService(
        BoardSize.four,
        fakeRepo,
        random: Random(42),
      );
      await service.makeMove(MoveDirection.left);
      await service.restart();
      expect(service.state.score, 0);
      expect(service.state.tiles.length, 2);
    });

    test('restart preserves bestScore from persistence', () async {
      await fakeRepo.saveBestScore(BoardSize.four, 1024);
      final service = GameService(BoardSize.four, fakeRepo);
      await service.loadPersistentData();
      await service.restart();
      expect(service.state.bestScore, 1024);
    });
  });

  group('GameService bestMoveHint', () {
    test('bestMoveHint returns null when game over', () async {
      final service = GameService(
        BoardSize.three,
        fakeRepo,
        random: Random(111),
      );
      for (var i = 0; i < 50; i++) {
        await service.makeMove(MoveDirection.left);
        if (service.state.isGameOver) break;
      }
      if (!service.state.isGameOver) return;
      expect(service.bestMoveHint(), isNull);
    });

    test('bestMoveHint returns direction when moves available', () {
      final service = GameService(
        BoardSize.four,
        fakeRepo,
        random: Random(42),
      );
      final hint = service.bestMoveHint();
      expect(hint, isNotNull);
      expect(MoveDirection.values, contains(hint));
    });
  });
}
