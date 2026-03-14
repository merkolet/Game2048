import 'package:flutter/material.dart';

import '../../domain/game/game_models.dart';
import 'game_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Выбор режима',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Выбери размер поля',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFBBADA0),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 28),
            _ModeCard(
              size: BoardSize.three,
              emoji: '⚡',
              title: '3 × 3',
              subtitle: 'Быстрая партия',
              description: 'Цель: 512. Идеально для тренировки.',
              gradient: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              onTap: () => _openGame(context, BoardSize.three),
            ),
            const SizedBox(height: 16),
            _ModeCard(
              size: BoardSize.four,
              emoji: '🏆',
              title: '4 × 4',
              subtitle: 'Классика',
              description: 'Оригинальный режим 2048.',
              gradient: const [Color(0xFFEDC22E), Color(0xFFF59563)],
              onTap: () => _openGame(context, BoardSize.four),
            ),
            const SizedBox(height: 16),
            _ModeCard(
              size: BoardSize.five,
              emoji: '🔥',
              title: '5 × 5',
              subtitle: 'Долгая партия',
              description: 'Больше пространства, больше стратегии.',
              gradient: const [Color(0xFFF65E3B), Color(0xFFB71C1C)],
              onTap: () => _openGame(context, BoardSize.five),
            ),
          ],
        ),
      ),
    );
  }

  void _openGame(BuildContext context, BoardSize size) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(size: size)),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.size,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  final BoardSize size;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 165,
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 22,
            ),
          ],
        ),
      ),
      ),
    );
  }
}
