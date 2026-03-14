import 'package:flutter/material.dart';

import '../../domain/game/game_models.dart';

enum ResultAction { restart, exit }

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.state,
    required this.missions,
  });

  final GameState state;
  final MissionProgress missions;

  @override
  Widget build(BuildContext context) {
    final win = state.isWin;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Результат',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _ResultHeader(win: win),
            const SizedBox(height: 28),
            _StatsCard(state: state),
            const SizedBox(height: 20),
            _MissionsCard(missions: missions),
            const SizedBox(height: 32),
            _ActionButton(
              label: 'Играть ещё раз',
              icon: Icons.replay_rounded,
              primary: true,
              onTap: () => Navigator.of(context).pop(ResultAction.restart),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Выйти в меню',
              icon: Icons.home_rounded,
              primary: false,
              onTap: () => Navigator.of(context).pop(ResultAction.exit),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.win});

  final bool win;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: win
              ? [const Color(0xFFEDC22E), const Color(0xFFF59563)]
              : [const Color(0xFF2A2A4A), const Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: win
            ? [
                BoxShadow(
                  color: const Color(0xFFEDC22E).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            win ? '🏆' : '🎮',
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 12),
          Text(
            win ? 'Победа!' : 'Игра окончена',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: win ? Colors.white : const Color(0xFFBBADA0),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            win
                ? 'Ты собрал плитку 2048!'
                : 'Ходов больше нет. Попробуй ещё раз.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: win
                  ? Colors.white.withOpacity(0.85)
                  : const Color(0xFF776E65),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'РЕЗУЛЬТАТЫ',
            style: TextStyle(
              color: Color(0xFF776E65),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Счёт',
                  value: '${state.score}',
                  icon: Icons.star_rounded,
                  color: const Color(0xFFEDC22E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Лучший',
                  value: '${state.bestScore}',
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFF59563),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Макс. плитка',
                  value: '${state.maxTile}',
                  icon: Icons.grid_view_rounded,
                  color: const Color(0xFFF65E3B),
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
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
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF776E65),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionsCard extends StatelessWidget {
  const _MissionsCard({required this.missions});

  final MissionProgress missions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ЗАДАНИЯ',
            style: TextStyle(
              color: Color(0xFF776E65),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          _MissionRow(
            label: 'Достигни плитки 64',
            done: missions.reached64,
          ),
          const SizedBox(height: 8),
          _MissionRow(
            label: 'Набери счёт 1000+',
            done: missions.scoreOver1000,
          ),
          const SizedBox(height: 8),
          _MissionRow(
            label: 'Победа на поле 5×5',
            done: missions.winOnFive,
          ),
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: done
            ? const Color(0xFF2E7D32).withOpacity(0.15)
            : const Color(0xFF2A2A4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done
              ? const Color(0xFF4CAF50).withOpacity(0.5)
              : const Color(0xFF3A3A5A),
        ),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: done ? const Color(0xFF4CAF50) : const Color(0xFF555575),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: done ? const Color(0xFF81C784) : const Color(0xFF776E65),
              ),
            ),
          ),
          if (done)
            const Text('✓', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 14)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(
                  colors: [Color(0xFFEDC22E), Color(0xFFF59563)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: primary ? null : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: primary
              ? null
              : Border.all(color: const Color(0xFF776E65), width: 1.5),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: const Color(0xFFEDC22E).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primary ? Colors.white : const Color(0xFFBBADA0),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: primary ? Colors.white : const Color(0xFFBBADA0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
