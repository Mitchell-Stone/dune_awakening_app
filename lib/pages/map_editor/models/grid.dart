class Grid {
  final int gridCount;
  final int gridSize;

  late final double cellHeight;
  late final double cellWidth;

  List<List<GridCell>> gridCells = [];

  Grid({required this.gridCount, required this.gridSize}) {
    cellHeight = gridSize / gridCount;
    cellWidth = gridSize / gridCount;

    _initializeEmptyGrid();
  }

  _initializeEmptyGrid() {
    gridCells.clear();

    for (int row = 0; row < gridCount; row++) {
      List<GridCell> gRow = [];
      for (int col = 0; col < gridCount; col++) {
        final letter = String.fromCharCode(65 + (gridCount - 1) - row);
        final id = '$letter${col + 1}';
        gRow.add(GridCell(id: id, coordinates: [col, row]));
      }
      gridCells.add(gRow);
    }
  }
}

class GridCell {
  final String id;
  final List<int> coordinates;

  GridCell({required this.id, required this.coordinates});
}