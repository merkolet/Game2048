import 'package:flutter/material.dart';

import '../../domain/game/game_models.dart';

class TileGrid extends StatelessWidget {
  const TileGrid({
    super.key,
    required this.state,
  });

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final dim = state.dimension;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final tileSize = size / dim;
        return Center(
            child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                for (var y = 0; y < dim; y++)
                  for (var x = 0; x < dim; x++)
                    Positioned(
                      left: x * tileSize,
                      top: y * tileSize,
                      width: tileSize,
                      height: tileSize,
                      child: _TileBackground(),
                    ),
                for (final tile in state.tiles)
                  AnimatedPositioned(
                    key: ValueKey(tile.id),
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    left: tile.col * tileSize,
                    top: tile.row * tileSize,
                    width: tileSize,
                    height: tileSize,
                    child: _Tile(
                      value: tile.value,
                      dimension: dim,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TileBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.dimension});

  final int value;
  final int dimension;

  @override
  Widget build(BuildContext context) {
    final colors = _TileColors.forValue(value);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 160),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$value',
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: dimension <= 3 ? 52 : dimension == 4 ? 40 : 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TileColors {
  _TileColors(this.background, this.text);

  final Color background;
  final Color text;

  static _TileColors forValue(int value) {
    switch (value) {
      case 2:
        return _TileColors(const Color(0xFF1E3A5F), const Color(0xFFB0C4DE));
      case 4:
        return _TileColors(const Color(0xFF1B4D7E), const Color(0xFFADD8E6));
      case 8:
        return _TileColors(const Color(0xFF2E6B8A), Colors.white);
      case 16:
        return _TileColors(const Color(0xFF4CAF50), Colors.white);
      case 32:
        return _TileColors(const Color(0xFF2196F3), Colors.white);
      case 64:
        return _TileColors(const Color(0xFF9C27B0), Colors.white);
      case 128:
        return _TileColors(const Color(0xFFEDC22E), Colors.white);
      case 256:
        return _TileColors(const Color(0xFFF59563), Colors.white);
      case 512:
        return _TileColors(const Color(0xFFF67C5F), Colors.white);
      case 1024:
        return _TileColors(const Color(0xFFF65E3B), Colors.white);
      case 2048:
      default:
        return _TileColors(const Color(0xFFEDC22E), Colors.white);
    }
  }
}

