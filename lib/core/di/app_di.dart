import '../../data/game/shared_prefs_game_persistence_repository.dart';
import '../../domain/game/game_models.dart';
import '../../domain/game/game_repository.dart';
import '../../domain/game/game_service.dart';
import '../services/cloud_user_stats_service.dart';

class AppDi {
  final CloudUserStatsService cloudUserStatsService = CloudUserStatsService();

  GameService createGameService(BoardSize size, String userId) {
    return GameService(size, getGamePersistenceRepository(userId));
  }

  GamePersistenceRepository getGamePersistenceRepository(String userId) {
    return SharedPrefsGamePersistenceRepository(userId: userId);
  }
}

