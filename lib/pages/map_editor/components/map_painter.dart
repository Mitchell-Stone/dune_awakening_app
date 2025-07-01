import 'package:deep_desert/pages/map_editor/models/grid.dart';
import 'package:deep_desert/pages/map_editor/models/stroke.dart';
import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;

  DrawingPainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [
      ...strokes,
      if (currentStroke != null) currentStroke!,
    ]) {
      final paint =
          Paint()
            ..color = stroke.color
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



class CombinedPainter extends CustomPainter {
  final Grid grid;
  final Map<List<int>, Color> overlay;
  CombinedPainter(this.grid, this.overlay);

  @override
  void paint(Canvas canvas, Size size) {
    final dangerPaint =
        Paint()
          ..color = const Color.fromARGB(
            30,
            225,
            31,
            31,
          ) // Semi-transparent red
          ..style = PaintingStyle.fill;

    final safePaint =
        Paint()
          ..color = const Color.fromARGB(
            30,
            15,
            213,
            15,
          ) // Semi-transparent green
          ..style = PaintingStyle.fill;

    // Full grid dimensions
    final gridPixelSize = grid.gridSize.toDouble();

    // Draw top half (danger zone)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gridPixelSize, gridPixelSize / 2),
      dangerPaint,
    );

    // Draw bottom half (safe zone)
    canvas.drawRect(
      Rect.fromLTWH(0, gridPixelSize / 2, gridPixelSize, gridPixelSize / 2),
      safePaint,
    );
    final pBoundary =
        Paint()
          ..color = Colors.grey[700]!
          ..strokeWidth = 0.3
          ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (int i = 0; i <= grid.gridCount; i++) {
      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * grid.cellHeight),
        Offset(gridPixelSize, i * grid.cellHeight),
        pBoundary,
      );
      // Vertical lines
      canvas.drawLine(
        Offset(i * grid.cellWidth, 0),
        Offset(i * grid.cellWidth, gridPixelSize),
        pBoundary,
      );
    }

    // Optionally, fill overlay cells if needed
    for (int ry = 0; ry < grid.gridCount; ry++) {
      for (int rx = 0; rx < grid.gridCount; rx++) {
        final sx = rx * grid.cellWidth;
        final sy = ry * grid.cellHeight;
        final cellKey = [rx, ry];
        if (overlay.containsKey(cellKey)) {
          canvas.drawRect(
            Rect.fromLTWH(sx, sy, grid.cellWidth, grid.cellHeight),
            Paint()
              ..color = overlay[cellKey]!
              ..style = PaintingStyle.fill,
          );
        }
        final tp = TextPainter(
          text: TextSpan(
            text: grid.gridCells[ry][rx].id,
            style: TextStyle(
              fontSize: grid.cellHeight * 0.2, // Use a fraction of cell size
              color: const Color.fromARGB(30, 0, 0, 0),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(
            sx + (grid.cellWidth - tp.width) / 2,
            sy + (grid.cellHeight - tp.height) / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CombinedPainter old) => true;
}
