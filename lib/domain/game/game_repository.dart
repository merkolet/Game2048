import 'game_models.dart';

abstract class GamePersistenceRepository {
  Future<int> getBestScore(BoardSize size);

  Future<void> saveBestScore(BoardSize size, int score);

  Future<MissionProgress> getMissions();

  Future<void> saveMissions(MissionProgress missions);

  Future<int> getGamesPlayed();

  Future<int> getWins();

  Future<void> increaseGamesPlayed({required bool win});
}

