import 'dart:math';

import 'game_models.dart';
import 'game_repository.dart';

class GameService {
  GameService(this.size, this._persistence,
      {MissionProgress? initialMissions, Random? random})
      : _random = random ?? Random(),
        _missions = initialMissions ?? MissionProgress.empty {
    _state = _createInitialState();
  }

  final BoardSize size;
  final GamePersistenceRepository _persistence;
  final Random _random;

  GameState _state = GameState(
    size: BoardSize.four,
    tiles: const [],
    score: 0,
    bestScore: 0,
    isGameOver: false,
    isWin: false,
  );

  int _nextTileId = 0;

  MissionProgress _missions;

  GameState get state => _state;
  MissionProgress get missions => _missions;

  Future<void> loadPersistentData() async {
    final bestScore = await _persistence.getBestScore(size);
    final missions = await _persistence.getMissions();
    _missions = missions;
    if (_state.tiles.isEmpty) {
      _state = _createInitialState(bestScore: bestScore);
    } else {
      _state = _state.copyWith(bestScore: bestScore);
    }
  }

  GameState _createInitialState({int? bestScore}) {
    final initial = GameState(
      size: size,
      tiles: <Tile>[],
      score: 0,
      bestScore: bestScore ?? 0,
      isGameOver: false,
      isWin: false,
    );
    _state = initial;
    _addRandomTile();
    _addRandomTile();
    return _state;
  }

  Future<void> restart() async {
    final best = await _persistence.getBestScore(size);
    _state = _createInitialState(bestScore: best);
  }

  Future<void> makeMove(MoveDirection direction) async {
    if (_state.isGameOver) return;

    final beforeTiles = _state.tiles.map((t) => t.copy()).toList();
    var scoreGained = 0;

    // Строим вспомогательную матрицу из текущих плиток.
    final dim = size.dimension;
    final grid = List.generate(dim, (_) => List<Tile?>.filled(dim, null));
    for (final tile in _state.tiles) {
      if (tile.row >= 0 &&
          tile.row < dim &&
          tile.col >= 0 &&
          tile.col < dim) {
        grid[tile.row][tile.col] = tile;
      }
    }

    late final List<Tile> newTiles;
    switch (direction) {
      case MoveDirection.left:
        newTiles = _moveLeft(grid, (delta) => scoreGained += delta);
        break;
      case MoveDirection.right:
        newTiles = _moveRight(grid, (delta) => scoreGained += delta);
        break;
      case MoveDirection.up:
        newTiles = _moveUp(grid, (delta) => scoreGained += delta);
        break;
      case MoveDirection.down:
        newTiles = _moveDown(grid, (delta) => scoreGained += delta);
        break;
    }

    final changed = !_tileListsEqual(beforeTiles, newTiles);
    if (!changed) return;

    _state = _state.copyWith(
      tiles: newTiles,
      score: _state.score + scoreGained,
    );

    _addRandomTile();

    final noMoves = !_hasMovesTiles(_state.tiles, size.dimension);
    final isWin = _state.maxTile >= 2048;

    _state = _state.copyWith(
      isGameOver: noMoves || isWin,
      isWin: isWin,
    );

    await _updatePersistentData();
  }

  MoveDirection? bestMoveHint() {
    if (_state.isGameOver) return null;
    final directions = MoveDirection.values;
    MoveDirection? bestDir;
    var bestGain = -1;

    for (final dir in directions) {
      var gain = 0;
      final tilesCopy = _state.tiles.map((t) => t.copy()).toList();
      final simulated = _simulateMove(tilesCopy, dir, (d) => gain += d);

      if (!_tileListsEqual(_state.tiles, simulated) && gain > bestGain) {
        bestGain = gain;
        bestDir = dir;
      }
    }

    return bestDir;
  }

  List<Tile> _simulateMove(
    List<Tile> tiles,
    MoveDirection direction,
    void Function(int) onScoreDelta,
  ) {
    final dim = size.dimension;
    final grid = List.generate(dim, (_) => List<Tile?>.filled(dim, null));
    for (final t in tiles) {
      if (t.row >= 0 && t.row < dim && t.col >= 0 && t.col < dim) {
        grid[t.row][t.col] = t;
      }
    }

    switch (direction) {
      case MoveDirection.left:
        return _moveLeft(grid, onScoreDelta);
      case MoveDirection.right:
        return _moveRight(grid, onScoreDelta);
      case MoveDirection.up:
        return _moveUp(grid, onScoreDelta);
      case MoveDirection.down:
        return _moveDown(grid, onScoreDelta);
    }
  }

  Future<void> _updatePersistentData() async {
    await _persistence.saveBestScore(size, _state.score);
    final currentBest = await _persistence.getBestScore(size);
    _state = _state.copyWith(bestScore: currentBest);

    var missions = _missions;
    if (!missions.reached64 && _state.maxTile >= 64) {
      missions = missions.copyWith(reached64: true);
    }
    if (!missions.scoreOver1000 && _state.score >= 1000) {
      missions = missions.copyWith(scoreOver1000: true);
    }
    if (!missions.winOnFive &&
        size == BoardSize.five &&
        _state.isWin == true) {
      missions = missions.copyWith(winOnFive: true);
    }
    _missions = missions;
    await _persistence.saveMissions(missions);

    if (_state.isGameOver) {
      await _persistence.increaseGamesPlayed(win: _state.isWin == true);
    }
  }

  void _addRandomTile() {
    final dim = size.dimension;
    final occupied = <Point<int>>{};
    for (final t in _state.tiles) {
      occupied.add(Point(t.col, t.row));
    }
    final emptyCells = <Point<int>>[];
    for (var y = 0; y < dim; y++) {
      for (var x = 0; x < dim; x++) {
        final p = Point(x, y);
        if (!occupied.contains(p)) {
          emptyCells.add(p);
        }
      }
    }
    if (emptyCells.isEmpty) return;
    final p = emptyCells[_random.nextInt(emptyCells.length)];
    final value = _random.nextDouble() < 0.9 ? 2 : 4;
    final newTile = Tile(
      id: _nextTileId++,
      row: p.y,
      col: p.x,
      value: value,
    );
    _state = _state.copyWith(
      tiles: [..._state.tiles, newTile],
    );
  }

  List<Tile> _moveLeft(
    List<List<Tile?>> grid,
    void Function(int) onScoreDelta,
  ) {
    final dim = grid.length;
    final newTiles = <Tile>[];

    for (var row = 0; row < dim; row++) {
      final rowTiles = <Tile>[];
      for (var col = 0; col < dim; col++) {
        final t = grid[row][col];
        if (t != null) {
          rowTiles.add(t);
        }
      }
      rowTiles.sort((a, b) => a.col.compareTo(b.col));

      var targetCol = 0;
      var i = 0;
      while (i < rowTiles.length) {
        final current = rowTiles[i];
        if (i + 1 < rowTiles.length &&
            rowTiles[i + 1].value == current.value) {
          final mergedValue = current.value * 2;
          onScoreDelta(mergedValue);
          final mergedTile = Tile(
            id: _nextTileId++,
            row: row,
            col: targetCol,
            value: mergedValue,
          );
          newTiles.add(mergedTile);
          i += 2;
        } else {
          current.row = row;
          current.col = targetCol;
          newTiles.add(current);
          i += 1;
        }
        targetCol++;
      }
    }

    return newTiles;
  }

  List<Tile> _moveRight(
    List<List<Tile?>> grid,
    void Function(int) onScoreDelta,
  ) {
    final dim = grid.length;
    final newTiles = <Tile>[];

    for (var row = 0; row < dim; row++) {
      final rowTiles = <Tile>[];
      for (var col = 0; col < dim; col++) {
        final t = grid[row][col];
        if (t != null) rowTiles.add(t);
      }
      rowTiles.sort((a, b) => b.col.compareTo(a.col));

      var targetCol = dim - 1;
      var i = 0;
      while (i < rowTiles.length) {
        final current = rowTiles[i];
        if (i + 1 < rowTiles.length &&
            rowTiles[i + 1].value == current.value) {
          final mergedValue = current.value * 2;
          onScoreDelta(mergedValue);
          final mergedTile = Tile(
            id: _nextTileId++,
            row: row,
            col: targetCol,
            value: mergedValue,
          );
          newTiles.add(mergedTile);
          i += 2;
        } else {
          current.row = row;
          current.col = targetCol;
          newTiles.add(current);
          i += 1;
        }
        targetCol--;
      }
    }

    return newTiles;
  }

  List<Tile> _moveUp(
    List<List<Tile?>> grid,
    void Function(int) onScoreDelta,
  ) {
    final dim = grid.length;
    final newTiles = <Tile>[];

    for (var col = 0; col < dim; col++) {
      final colTiles = <Tile>[];
      for (var row = 0; row < dim; row++) {
        final t = grid[row][col];
        if (t != null) colTiles.add(t);
      }
      colTiles.sort((a, b) => a.row.compareTo(b.row));

      var targetRow = 0;
      var i = 0;
      while (i < colTiles.length) {
        final current = colTiles[i];
        if (i + 1 < colTiles.length &&
            colTiles[i + 1].value == current.value) {
          final mergedValue = current.value * 2;
          onScoreDelta(mergedValue);
          final mergedTile = Tile(
            id: _nextTileId++,
            row: targetRow,
            col: col,
            value: mergedValue,
          );
          newTiles.add(mergedTile);
          i += 2;
        } else {
          current.row = targetRow;
          current.col = col;
          newTiles.add(current);
          i += 1;
        }
        targetRow++;
      }
    }

    return newTiles;
  }

  List<Tile> _moveDown(
    List<List<Tile?>> grid,
    void Function(int) onScoreDelta,
  ) {
    final dim = grid.length;
    final newTiles = <Tile>[];

    for (var col = 0; col < dim; col++) {
      final colTiles = <Tile>[];
      for (var row = 0; row < dim; row++) {
        final t = grid[row][col];
        if (t != null) colTiles.add(t);
      }
      colTiles.sort((a, b) => b.row.compareTo(a.row));

      var targetRow = dim - 1;
      var i = 0;
      while (i < colTiles.length) {
        final current = colTiles[i];
        if (i + 1 < colTiles.length &&
            colTiles[i + 1].value == current.value) {
          final mergedValue = current.value * 2;
          onScoreDelta(mergedValue);
          final mergedTile = Tile(
            id: _nextTileId++,
            row: targetRow,
            col: col,
            value: mergedValue,
          );
          newTiles.add(mergedTile);
          i += 2;
        } else {
          current.row = targetRow;
          current.col = col;
          newTiles.add(current);
          i += 1;
        }
        targetRow--;
      }
    }

    return newTiles;
  }

  bool _hasMovesTiles(List<Tile> tiles, int dim) {
    final grid = List.generate(dim, (_) => List<int>.filled(dim, 0));
    for (final t in tiles) {
      grid[t.row][t.col] = t.value;
    }
    for (var y = 0; y < dim; y++) {
      for (var x = 0; x < dim; x++) {
        final v = grid[y][x];
        if (v == 0) return true;
        if (x + 1 < dim && grid[y][x + 1] == v) return true;
        if (y + 1 < dim && grid[y + 1][x] == v) return true;
      }
    }
    return false;
  }


  bool _tileListsEqual(List<Tile> a, List<Tile> b) {
    if (a.length != b.length) return false;
    final dim = size.dimension;
    final gridA = List.generate(dim, (_) => List<int>.filled(dim, 0));
    final gridB = List.generate(dim, (_) => List<int>.filled(dim, 0));
    for (final t in a) {
      if (t.row >= 0 && t.row < dim && t.col >= 0 && t.col < dim) {
        gridA[t.row][t.col] = t.value;
      }
    }
    for (final t in b) {
      if (t.row >= 0 && t.row < dim && t.col >= 0 && t.col < dim) {
        gridB[t.row][t.col] = t.value;
      }
    }
    for (var r = 0; r < dim; r++) {
      for (var c = 0; c < dim; c++) {
        if (gridA[r][c] != gridB[r][c]) return false;
      }
    }
    return true;
  }
}

