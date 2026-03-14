import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/data/game/shared_prefs_game_persistence_repository.dart';
import 'package:game_2048/domain/game/game_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPrefsGamePersistenceRepository', () {
    late SharedPrefsGamePersistenceRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = SharedPrefsGamePersistenceRepository(userId: 'test_user_1');
    });

    test('getBestScore returns 0 initially', () async {
      expect(await repo.getBestScore(BoardSize.three), 0);
      expect(await repo.getBestScore(BoardSize.four), 0);
      expect(await repo.getBestScore(BoardSize.five), 0);
    });

    test('saveBestScore and getBestScore round-trip', () async {
      await repo.saveBestScore(BoardSize.four, 512);
      expect(await repo.getBestScore(BoardSize.four), 512);
    });

    test('saveBestScore only updates when score is higher', () async {
      await repo.saveBestScore(BoardSize.four, 512);
      await repo.saveBestScore(BoardSize.four, 256);
      expect(await repo.getBestScore(BoardSize.four), 512);
      await repo.saveBestScore(BoardSize.four, 1024);
      expect(await repo.getBestScore(BoardSize.four), 1024);
    });

    test('missions round-trip', () async {
      const missions = MissionProgress(
        reached64: true,
        scoreOver1000: true,
        winOnFive: false,
      );
      await repo.saveMissions(missions);
      final loaded = await repo.getMissions();
      expect(loaded.reached64, true);
      expect(loaded.scoreOver1000, true);
      expect(loaded.winOnFive, false);
    });

    test('different userId stores separately', () async {
      await repo.saveBestScore(BoardSize.four, 100);
      final repo2 =
          SharedPrefsGamePersistenceRepository(userId: 'test_user_2');
      expect(await repo2.getBestScore(BoardSize.four), 0);
      expect(await repo.getBestScore(BoardSize.four), 100);
    });
  });
}
