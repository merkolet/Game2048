import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../domain/game/game_models.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _best3 = 0;
  int _best4 = 0;
  int _best5 = 0;
  int _games = 0;
  int _wins = 0;
  MissionProgress _missions = MissionProgress.empty;
  bool _loading = true;
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      _load();
      _loadedOnce = true;
    }
  }

  Future<void> _load() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final di = AppScope.of(context).di;
    final repo = di.getGamePersistenceRepository(userId);
    final best3 = await repo.getBestScore(BoardSize.three);
    final best4 = await repo.getBestScore(BoardSize.four);
    final best5 = await repo.getBestScore(BoardSize.five);
    final games = await repo.getGamesPlayed();
    final wins = await repo.getWins();
    final missions = await repo.getMissions();
    if (!mounted) return;
    setState(() {
      _best3 = best3;
      _best4 = best4;
      _best5 = best5;
      _games = games;
      _wins = wins;
      _missions = missions;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Статистика',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEDC22E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionCard(
                    title: 'ЛУЧШИЕ РЕЗУЛЬТАТЫ',
                    child: Row(
                      children: [
                        Expanded(
                          child: _BestScoreTile(
                            label: '3 × 3',
                            value: _best3,
                            emoji: '⚡',
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _BestScoreTile(
                            label: '4 × 4',
                            value: _best4,
                            emoji: '🏆',
                            color: const Color(0xFFEDC22E),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _BestScoreTile(
                            label: '5 × 5',
                            value: _best5,
                            emoji: '🔥',
                            color: const Color(0xFFF65E3B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'СТАТИСТИКА',
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'Сыграно',
                            value: '$_games',
                            icon: Icons.sports_esports_rounded,
                            color: const Color(0xFF7986CB),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatTile(
                            label: 'Побед',
                            value: '$_wins',
                            icon: Icons.emoji_events_rounded,
                            color: const Color(0xFFEDC22E),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatTile(
                            label: 'Процент',
                            value: _games > 0
                                ? '${(_wins * 100 / _games).round()}%'
                                : '—',
                            icon: Icons.percent_rounded,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'ЗАДАНИЯ',
                    child: Column(
                      children: [
                        _MissionTile(
                          label: 'Достигни плитки 64',
                          hint: 'Собери плитку со значением 64',
                          done: _missions.reached64,
                        ),
                        const SizedBox(height: 10),
                        _MissionTile(
                          label: 'Набери счёт 1000+',
                          hint: 'Суммарный счёт за партию ≥ 1000',
                          done: _missions.scoreOver1000,
                        ),
                        const SizedBox(height: 10),
                        _MissionTile(
                          label: 'Победа на поле 5×5',
                          hint: 'Собери 2048 на поле 5×5',
                          done: _missions.winOnFive,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF776E65),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BestScoreTile extends StatelessWidget {
  const _BestScoreTile({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  final String label;
  final int value;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF776E65),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF776E65),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({
    required this.label,
    required this.hint,
    required this.done,
  });

  final String label;
  final String hint;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final doneColor = const Color(0xFF4CAF50);
    final undoneColor = const Color(0xFF555575);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: done
            ? const Color(0xFF2E7D32).withValues(alpha:0.12)
            : const Color(0xFF2A2A4A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? doneColor.withValues(alpha:0.4) : const Color(0xFF3A3A5A),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: done
                  ? doneColor.withValues(alpha:0.15)
                  : undoneColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              done ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
              color: done ? doneColor : undoneColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: done
                        ? const Color(0xFF81C784)
                        : const Color(0xFFBBADA0),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF555575),
                  ),
                ),
              ],
            ),
          ),
          if (done)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: doneColor.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Готово',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF81C784),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
