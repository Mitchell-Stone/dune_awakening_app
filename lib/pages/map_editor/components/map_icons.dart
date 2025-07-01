import 'package:flutter/material.dart';

class IconDescriptor {
  final IconData? iconData; // nullable
  final String? assetPath; // new
  final Color color;

  IconDescriptor({required this.iconData, this.assetPath, required this.color});
}

class LabeledDraggableIcon extends StatefulWidget {
  final String label;
  final IconData? iconData;
  final String? assetPath;
  final Color color;

  const LabeledDraggableIcon({
    super.key,
    required this.label,
    this.iconData,
    this.assetPath,
    required this.color,
  });

  @override
  State<LabeledDraggableIcon> createState() => _LabeledDraggableIconState();
}

class _LabeledDraggableIconState extends State<LabeledDraggableIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final descriptor = IconDescriptor(
      iconData: widget.iconData,
      assetPath: widget.assetPath,
      color: widget.color,
    );

    final iconWidget =
        widget.assetPath != null
            ? Image.asset(widget.assetPath!, height: 32)
            : Icon(widget.iconData, size: 32, color: widget.color);

    final feedbackWidget =
        widget.assetPath != null
            ? Image.asset(widget.assetPath!, height: 25)
            : Icon(widget.iconData, size: 25, color: widget.color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Row(
          children: [
            Draggable<IconDescriptor>(
              data: descriptor,
              feedback: Material(
                color: Colors.transparent,
                child: feedbackWidget,
              ),
              childWhenDragging: Opacity(opacity: 0.3, child: iconWidget),
              child: Container(
                decoration:
                    _isHovered
                        ? BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.7),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        )
                        : null,
                child: iconWidget,
              ),
            ),
            const SizedBox(width: 8),
            Text(widget.label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class DraggableIcon extends StatelessWidget {
  final IconData? iconData;
  final String? assetPath;
  final Color color;

  const DraggableIcon({
    super.key,
    this.iconData,
    this.assetPath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final descriptor = IconDescriptor(
      iconData: iconData,
      assetPath: assetPath,
      color: color,
    );

    Widget iconWidget = _buildIcon(size: 20);
    Widget feedbackWidget = _buildIcon(size: 22);
    Widget draggingWidget = Opacity(opacity: 0.3, child: _buildIcon(size: 22));

    return Draggable<IconDescriptor>(
      data: descriptor,
      feedback: Material(color: Colors.transparent, child: feedbackWidget),
      childWhenDragging: draggingWidget,
      child: Padding(padding: const EdgeInsets.all(8.0), child: iconWidget),
    );
  }

  Widget _buildIcon({required double size}) {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        height: size,
        width: size,
        errorBuilder:
            (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    } else {
      return Icon(iconData, size: size, color: color);
    }
  }
}

class PlacedIcon {
  final String id;
  final IconData? iconData;
  final String? assetPath;
  final Color color;
  Offset offset;
  int nodeCount; // New field

  PlacedIcon({
    required this.id,
    this.iconData,
    this.assetPath,
    required this.color,
    required this.offset,
    this.nodeCount = 0, // Default to 0
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iconCodePoint': iconData?.codePoint,
      'iconFontFamily': iconData?.fontFamily,
      'assetPath': assetPath,
      'color': color.toARGB32(),
      'dx': offset.dx,
      'dy': offset.dy,
      'nodeCount': nodeCount,
    };
  }

  factory PlacedIcon.fromJson(Map<String, dynamic> json) {
    return PlacedIcon(
      id: json['id'],
      iconData:
          json['iconCodePoint'] != null
              ? IconData(
                json['iconCodePoint'],
                fontFamily: json['iconFontFamily'],
              )
              : null,
      assetPath: json['assetPath'],
      color: Color(json['color']),
      offset: Offset(json['dx'], json['dy']),
      nodeCount: json['nodeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJsonNormalized(double canvasSize) {
    return {
      'id': id,
      'iconCodePoint': iconData?.codePoint,
      'iconFontFamily': iconData?.fontFamily,
      'assetPath': assetPath,
      'color': color.toARGB32(),
      'dx': offset.dx / canvasSize,
      'dy': offset.dy / canvasSize,
      'nodeCount': nodeCount,
    };
  }

  factory PlacedIcon.fromJsonNormalized(
    Map<String, dynamic> json,
    double canvasSize,
  ) {
    return PlacedIcon(
      id: json['id'],
      iconData:
          json['iconCodePoint'] != null
              ? IconData(
                json['iconCodePoint'],
                fontFamily: json['iconFontFamily'],
              )
              : null,
      assetPath: json['assetPath'],
      color: Color(json['color']),
      offset: Offset(
        (json['dx'] as double) * canvasSize,
        (json['dy'] as double) * canvasSize,
      ),
      nodeCount: json['nodeCount'] ?? 0,
    );
  }
}
