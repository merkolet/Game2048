import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/domain/game/game_models.dart';
import 'package:game_2048/presentation/widgets/tile_grid.dart';

void main() {
  group('TileGrid', () {
    testWidgets('renders grid with tiles', (tester) async {
      final state = GameState(
        size: BoardSize.four,
        tiles: [
          Tile(id: 0, row: 0, col: 0, value: 2),
          Tile(id: 1, row: 0, col: 1, value: 4),
        ],
        score: 0,
        bestScore: 0,
        isGameOver: false,
        isWin: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TileGrid(state: state),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TileGrid), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('renders empty grid for 3x3', (tester) async {
      final state = GameState(
        size: BoardSize.three,
        tiles: const [],
        score: 0,
        bestScore: 0,
        isGameOver: false,
        isWin: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TileGrid(state: state),
          ),
        ),
      );

      expect(find.byType(TileGrid), findsOneWidget);
    });
  });
}
