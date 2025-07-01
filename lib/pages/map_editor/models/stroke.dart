import 'dart:ui';

class Stroke {
  final String id;
  final List<Offset> points;
  final Color color;

  Stroke({required this.points, required this.color, required this.id});

  Map<String, dynamic> toJsonNormalized(double canvasSize) {
    return {
      'id': id,
      'color': color.toARGB32(),
      'points':
          points
              .map((p) => {'dx': p.dx / canvasSize, 'dy': p.dy / canvasSize})
              .toList(),
    };
  }

  factory Stroke.fromJsonNormalized(
    Map<String, dynamic> json,
    double canvasSize,
  ) {
    return Stroke(
      id: json['id'],
      color: Color(json['color']),
      points:
          (json['points'] as List<dynamic>)
              .map(
                (p) => Offset(
                  (p['dx'] as double) * canvasSize,
                  (p['dy'] as double) * canvasSize,
                ),
              )
              .toList(),
    );
  }
}
