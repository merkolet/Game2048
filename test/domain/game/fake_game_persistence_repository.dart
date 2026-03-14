import 'package:game_2048/domain/game/game_models.dart';
import 'package:game_2048/domain/game/game_repository.dart';

/// In-memory fake для тестов GameService.
class FakeGamePersistenceRepository implements GamePersistenceRepository {
  final Map<String, int> _bestScores = {};
  MissionProgress _missions = MissionProgress.empty;
  int _gamesPlayed = 0;
  int _wins = 0;

  String _key(BoardSize size) {
    switch (size) {
      case BoardSize.three:
        return '3';
      case BoardSize.four:
        return '4';
      case BoardSize.five:
        return '5';
    }
  }

  @override
  Future<int> getBestScore(BoardSize size) async =>
      _bestScores[_key(size)] ?? 0;

  @override
  Future<void> saveBestScore(BoardSize size, int score) async {
    final current = _bestScores[_key(size)] ?? 0;
    if (score > current) _bestScores[_key(size)] = score;
  }

  @override
  Future<MissionProgress> getMissions() async => _missions;

  @override
  Future<void> saveMissions(MissionProgress missions) async {
    _missions = missions;
  }

  @override
  Future<int> getGamesPlayed() async => _gamesPlayed;

  @override
  Future<int> getWins() async => _wins;

  @override
  Future<void> increaseGamesPlayed({required bool win}) async {
    _gamesPlayed++;
    if (win) _wins++;
  }
}
