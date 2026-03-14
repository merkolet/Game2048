import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/services/cloud_user_stats_service.dart';
import '../../domain/game/game_models.dart';
import '../../domain/game/game_service.dart';
import '../widgets/tile_grid.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.size});

  final BoardSize size;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameService _service;
  late final CloudUserStatsService _cloudStatsService;
  bool _loading = true;
  bool _initialized = false;
  bool _moving = false;

  double _dragDeltaX = 0;
  double _dragDeltaY = 0;
  static const double _dragThreshold = 20;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? '';
      final di = AppScope.of(context).di;
      _service = di.createGameService(widget.size, userId);
      _cloudStatsService = di.cloudUserStatsService;
      _init();
      _initialized = true;
    }
  }

  Future<void> _init() async {
    await _service.loadPersistentData();
    _cloudSyncBestScore(_service.state.bestScore);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _handleMove(MoveDirection direction) async {
    if (_moving) return;
    _moving = true;
    final beforeBest = _service.state.bestScore;
    try {
      await _service.makeMove(direction);
    } finally {
      _moving = false;
    }
    final afterBest = _service.state.bestScore;
    if (afterBest > beforeBest) {
      _cloudSyncBestScore(afterBest);
    }
    if (!mounted) return;
    setState(() {});

    if (_service.state.isGameOver) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            state: _service.state,
            missions: _service.missions,
          ),
        ),
      );
      if (result == ResultAction.restart) {
        await _service.restart();
        _cloudSyncBestScore(_service.state.bestScore);
        if (mounted) setState(() {});
      } else if (result == ResultAction.exit) {
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  Future<void> _cloudSyncBestScore(int score) async {
    try {
      await _cloudStatsService.syncBestScore(
        size: widget.size,
        score: score,
      );
    } catch (_) {

    }
  }

  void _handleHint() {
    final hint = _service.bestMoveHint();
    if (hint == null) {
      _showSnack('Ходов не осталось', isHint: false);
      return;
    }
    final arrows = {
      MoveDirection.up: '↑ Вверх',
      MoveDirection.down: '↓ Вниз',
      MoveDirection.left: '← Влево',
      MoveDirection.right: '→ Вправо',
    };
    _showSnack('Подсказка: ${arrows[hint]}', isHint: true);
  }

  void _showSnack(String text, {required bool isHint}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isHint ? Icons.lightbulb : Icons.info_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor:
            isHint ? const Color(0xFFEDC22E) : const Color(0xFF776E65),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEDC22E)),
            )
          : SafeArea(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  _dragDeltaY += details.delta.dy;
                },
                onVerticalDragEnd: (_) {
                  final dy = _dragDeltaY;
                  _dragDeltaY = 0;
                  if (dy.abs() < _dragThreshold) return;
                  if (dy < 0) {
                    _handleMove(MoveDirection.up);
                  } else {
                    _handleMove(MoveDirection.down);
                  }
                },
                onHorizontalDragUpdate: (details) {
                  _dragDeltaX += details.delta.dx;
                },
                onHorizontalDragEnd: (_) {
                  final dx = _dragDeltaX;
                  _dragDeltaX = 0;
                  if (dx.abs() < _dragThreshold) return;
                  if (dx < 0) {
                    _handleMove(MoveDirection.left);
                  } else {
                    _handleMove(MoveDirection.right);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(
                        size: widget.size,
                        score: _service.state.score,
                        bestScore: _service.state.bestScore,
                        onHint: _handleHint,
                        onRestart: () async {
                          await _service.restart();
                          if (mounted) setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      _MissionsBar(missions: _service.missions),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TileGrid(state: _service.state),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Свайпай для перемещения плиток',
                          style: TextStyle(
                            color: Color(0xFF776E65),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.size,
    required this.score,
    required this.bestScore,
    required this.onHint,
    required this.onRestart,
  });

  final BoardSize size;
  final int score;
  final int bestScore;
  final VoidCallback onHint;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          padding: EdgeInsets.zero,
        ),
        Expanded(
          child: Text(
            'Поле ${size.label}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _ScorePill(label: 'Счёт', value: score),
        const SizedBox(width: 8),
        _ScorePill(label: 'Лучший', value: bestScore),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onHint,
          tooltip: 'Подсказка',
          icon: const Icon(Icons.lightbulb_outline, color: Color(0xFFEDC22E)),
          padding: EdgeInsets.zero,
        ),
        IconButton(
          onPressed: onRestart,
          tooltip: 'Новая игра',
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFFBBADA0)),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A4A), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF776E65),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '$value',
              key: ValueKey(value),
              style: const TextStyle(
                color: Color(0xFFEDC22E),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionsBar extends StatelessWidget {
  const _MissionsBar({required this.missions});

  final MissionProgress missions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Row(
        children: [
          const Text(
            'Задания',
            style: TextStyle(
              color: Color(0xFF776E65),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _MiniMission(label: '64', done: missions.reached64),
                _MiniMission(label: '1000+', done: missions.scoreOver1000),
                _MiniMission(label: '5×5 🏆', done: missions.winOnFive),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMission extends StatelessWidget {
  const _MiniMission({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: done
            ? const Color(0xFF2E7D32).withOpacity(0.85)
            : const Color(0xFF2A2A4A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: done ? const Color(0xFF4CAF50) : const Color(0xFF3A3A5A),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 12,
            color: done ? const Color(0xFF81C784) : const Color(0xFF555575),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: done ? const Color(0xFF81C784) : const Color(0xFF555575),
            ),
          ),
        ],
      ),
    );
  }
}
