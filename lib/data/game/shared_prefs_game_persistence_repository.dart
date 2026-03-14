import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/game/game_models.dart';
import '../../domain/game/game_repository.dart';

class SharedPrefsGamePersistenceRepository implements GamePersistenceRepository {
  SharedPrefsGamePersistenceRepository({required this.userId});

  final String userId;

  String _key(String base) => '${base}_$userId';

  @override
  Future<int> getBestScore(BoardSize size) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(_scoreKey(size));
    return prefs.getInt(key) ?? 0;
  }

  @override
  Future<void> saveBestScore(BoardSize size, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(_scoreKey(size));
    final current = prefs.getInt(key) ?? 0;
    if (score > current) {
      await prefs.setInt(key, score);
    }
  }

  @override
  Future<MissionProgress> getMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key('missions'));
    if (raw == null) return MissionProgress.empty;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return MissionProgress.fromJson(map);
    } catch (_) {
      return MissionProgress.empty;
    }
  }

  @override
  Future<void> saveMissions(MissionProgress missions) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(missions.toJson());
    await prefs.setString(_key('missions'), json);
  }

  @override
  Future<int> getGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key('gamesPlayed')) ?? 0;
  }

  @override
  Future<int> getWins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key('wins')) ?? 0;
  }

  @override
  Future<void> increaseGamesPlayed({required bool win}) async {
    final prefs = await SharedPreferences.getInstance();
    final games = (prefs.getInt(_key('gamesPlayed')) ?? 0) + 1;
    final wins = (prefs.getInt(_key('wins')) ?? 0) + (win ? 1 : 0);
    await prefs.setInt(_key('gamesPlayed'), games);
    await prefs.setInt(_key('wins'), wins);
  }

  String _scoreKey(BoardSize size) {
    switch (size) {
      case BoardSize.three:
        return 'bestScore3';
      case BoardSize.four:
        return 'bestScore4';
      case BoardSize.five:
        return 'bestScore5';
    }
  }
}

