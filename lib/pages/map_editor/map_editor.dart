import 'dart:convert';
import 'dart:io';
import 'package:deep_desert/pages/map_editor/components/map_icons.dart';
import 'package:deep_desert/pages/map_editor/components/map_painter.dart';
import 'package:deep_desert/pages/map_editor/models/grid.dart';
import 'package:deep_desert/pages/map_editor/models/stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapEditor extends StatefulWidget {
  const MapEditor({super.key});

  @override
  State<MapEditor> createState() => _MapEditorState();
}

class _MapEditorState extends State<MapEditor> with WidgetsBindingObserver {
  final List<PlacedIcon> placedIcons = [];
  final List<Stroke> strokes = [];
  Stroke? _currentStroke;
  Color _selectedStrokeColor = Colors.black;
  final GlobalKey _canvasKey = GlobalKey();
  late Grid grid;
  final Map<List<int>, Color> _overlay = {};
  double _canvasSize = 1.0;
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    // Load any existing icon layout
    loadLayout();
    WidgetsBinding.instance.addObserver(this);
    _lastSize =
        WidgetsBinding.instance.platformDispatcher.implicitView!.physicalSize /
        WidgetsBinding
            .instance
            .platformDispatcher
            .implicitView!
            .devicePixelRatio;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final newSize =
        View.of(context).physicalSize / View.of(context).devicePixelRatio;

    if (_lastSize != newSize) {
      _lastSize = newSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dynamic canvas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Find the smaller of width or height to maintain a square
                final newCanvasSize = constraints.biggest.shortestSide;

                if (newCanvasSize != _canvasSize) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _canvasSize = newCanvasSize;
                      grid = Grid(gridCount: 9, gridSize: _canvasSize.toInt());
                      // Need to look at normailizing the layout again instead of loading from file every time which will improve performance
                      loadLayout();
                    });
                  });
                }
                grid = Grid(gridCount: 9, gridSize: _canvasSize.toInt());
                return Center(
                  child: Container(
                    key: _canvasKey,
                    width: _canvasSize,
                    height: _canvasSize,
                    color: Colors.grey.shade200,
                    child: Stack(
                      children: [
                        // Drawing area
                        Positioned.fill(
                          child: GestureDetector(
                            onSecondaryTapDown: (details) {
                              _showDeleteMenu(context, details);
                            },
                            onPanStart:
                                (details) =>
                                    _startStroke(details.localPosition),
                            onPanUpdate:
                                (details) =>
                                    _addPointToStroke(details.localPosition),
                            onPanEnd: (_) => _endStroke(),
                            behavior: HitTestBehavior.translucent,
                            child: CustomPaint(
                              painter: DrawingPainter(
                                currentStroke: _currentStroke,
                                strokes: strokes,
                              ),
                            ),
                          ),
                        ),
                        // Draw the grid and overlay
                        CustomPaint(painter: CombinedPainter(grid, _overlay)),
                        // Drop zone
                        DragTarget<Object>(
                          onAcceptWithDetails: (details) {
                            final RenderBox canvasBox =
                                _canvasKey.currentContext!.findRenderObject()
                                    as RenderBox;
                            final localPosition = canvasBox.globalToLocal(
                              details.offset,
                            );

                            setState(() {
                              if (details.data is IconDescriptor) {
                                final desc = details.data as IconDescriptor;
                                placedIcons.add(
                                  PlacedIcon(
                                    id: UniqueKey().toString(),
                                    iconData: desc.iconData,
                                    assetPath: desc.assetPath,
                                    offset: localPosition,
                                    color: desc.color,
                                  ),
                                );
                                saveLayout();
                              } else if (details.data is PlacedIcon) {
                                final draggedIcon = details.data as PlacedIcon;
                                final index = placedIcons.indexWhere(
                                  (icon) => icon.id == draggedIcon.id,
                                );
                                if (index != -1) {
                                  placedIcons[index].offset = localPosition;
                                }
                              }
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return const SizedBox.expand(); // Full 1000x1000 coverage
                          },
                        ),
                        // Placed icons
                        ...placedIcons.map((poi) {
                          return Positioned(
                            left: poi.offset.dx,
                            top: poi.offset.dy,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onSecondaryTapDown: (details) {
                                    _showDeleteMenu(context, details);
                                  },
                                  child: Draggable<PlacedIcon>(
                                    data: poi,
                                    feedback:
                                        poi.assetPath != null
                                            ? Image.asset(
                                              poi.assetPath!,
                                              height: 25,
                                            )
                                            : Icon(
                                              poi.iconData,
                                              size: 25,
                                              color: poi.color,
                                            ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child:
                                          poi.assetPath != null
                                              ? Image.asset(
                                                poi.assetPath!,
                                                height: 25,
                                              )
                                              : Icon(
                                                poi.iconData,
                                                size: 25,
                                                color: poi.color,
                                              ),
                                    ),
                                    child:
                                        poi.assetPath != null
                                            ? Image.asset(
                                              poi.assetPath!,
                                              height: 25,
                                            )
                                            : Icon(
                                              poi.iconData,
                                              size: 25,
                                              color: poi.color,
                                            ),
                                  ),
                                ),
                                if (poi.nodeCount > 0)
                                  Text(
                                    'x${poi.nodeCount}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Icon selection sidebar
        DefaultTabController(
          length: 2,
          child: SizedBox(
            width: 250,
            height: double.infinity,
            child: Column(
              children: [
                // Styled card container
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, width: 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: [Tab(text: 'Tools'), Tab(text: 'Houses')],
                      ),
                    ],
                  ),
                ),

                // Tab content area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 0.3,
                      ),
                    ),
                    child: TabBarView(
                      children: [
                        _buildToolsTab(), // Extracted widgets or columns
                        _buildHousesTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sidebarActions() {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text("Copy Share Code"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: _copyShareCode,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text("Paste Share Code"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: _pasteShareCode,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 24, thickness: 1),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit_off),
            label: const Text("Clear Strokes"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: _confirmClearStrokes,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text("Reset Map"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: _confirmResetMap,
          ),
        ),
      ],
    );
  }

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stroke Colours'),
          const SizedBox(height: 8),
          Row(
            children: [
              _colorButton(Colors.red),
              _colorButton(Colors.green),
              _colorButton(Colors.purple),
              _colorButton(Colors.blueGrey),
              _colorButton(const Color.fromARGB(255, 17, 101, 20)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Map Icons'),
          ...[
            LabeledDraggableIcon(
              label: "Home Base",
              assetPath: "assets/icons/HomeBase.png",
              iconData: Icons.home,
              color: Colors.blue,
            ),
            LabeledDraggableIcon(
              label: "Authorized Base",
              assetPath: "assets/icons/AuthorizedBase.png",
              iconData: Icons.home,
              color: Colors.red,
            ),
            LabeledDraggableIcon(
              label: "Cave",
              assetPath: "assets/icons/Cave.png",
              iconData: Icons.home,
              color: Colors.orange.shade700,
            ),
            LabeledDraggableIcon(
              label: "Large Spice Field",
              assetPath: "assets/icons/Spice.png",
              iconData: Icons.circle,
              color: Colors.purple,
            ),
            LabeledDraggableIcon(
              label: "Titanium",
              assetPath: "assets/icons/Titanium.png",
              iconData: Icons.hexagon,
              color: Colors.blueGrey,
            ),
            LabeledDraggableIcon(
              label: "Stravinium",
              assetPath: "assets/icons/Stravidium.png",
              iconData: Icons.square,
              color: const Color.fromARGB(255, 17, 101, 20),
            ),
            LabeledDraggableIcon(
              label: "Crash Site",
              assetPath: "assets/icons/Shipwreck.png",
              iconData: Icons.airplanemode_active,
              color: Colors.orange,
            ),
            LabeledDraggableIcon(
              label: "Testing Station",
              assetPath: "assets/icons/TestingStation.png",
              iconData: Icons.science,
              color: Colors.teal,
            ),
          ],
          const SizedBox(height: 50),
          _sidebarActions(),
        ],
      ),
    );
  }

  Widget _buildHousesTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          LabeledDraggableIcon(
            label: "Alexin",
            assetPath: "assets/icons/House_Alexin.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Argpsaz",
            assetPath: "assets/icons/House_Argpsaz.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Dyvetz",
            assetPath: "assets/icons/House_Dyvetz.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Ecaz",
            assetPath: "assets/icons/House_Ecaz.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Hagal",
            assetPath: "assets/icons/House_Hagal.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Hurata",
            assetPath: "assets/icons/House_Hurata.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Imota",
            assetPath: "assets/icons/House_Imota.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Kenola",
            assetPath: "assets/icons/House_Kenola.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Lindaren",
            assetPath: "assets/icons/House_Lindaren.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Maros",
            assetPath: "assets/icons/House_Maros.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Mikarroi",
            assetPath: "assets/icons/House_Mikarrol.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Moritani",
            assetPath: "assets/icons/House_Moritani.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Mutelli",
            assetPath: "assets/icons/House_Mutelli.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Novebruns",
            assetPath: "assets/icons/House_Novebruns.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Richese",
            assetPath: "assets/icons/House_Richese.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Sor",
            assetPath: "assets/icons/House_Sor.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Spinnette",
            assetPath: "assets/icons/House_Spinnette.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Taligari",
            assetPath: "assets/icons/House_Taligari.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Thorvald",
            assetPath: "assets/icons/House_Thorvald.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Tseida",
            assetPath: "assets/icons/House_Tseida.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Varota",
            assetPath: "assets/icons/House_Varota.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Vernius",
            assetPath: "assets/icons/House_Vernius.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Wallach",
            assetPath: "assets/icons/House_Wallach.png",
            color: Colors.blue,
          ),
          LabeledDraggableIcon(
            label: "Wydras",
            assetPath: "assets/icons/House_Wydras.png",
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _confirmResetMap() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Map?'),
            content: const Text(
              'Are you sure you want to clear all icons, strokes, and overlay data from the map?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        placedIcons.clear();
        strokes.clear();
        _overlay.clear();
      });
      await saveLayout(); // Optionally persist the cleared state
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Map cleared')));
    }
  }

  Future<void> _copyShareCode() async {
    final jsonData = {
      'icons': placedIcons.map((e) => e.toJsonNormalized(_canvasSize)).toList(),
      'strokes': strokes.map((e) => e.toJsonNormalized(_canvasSize)).toList(),
    };

    final encoded = base64Encode(utf8.encode(jsonEncode(jsonData)));

    await Clipboard.setData(ClipboardData(text: encoded));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Map copied to clipboard')));
  }

  Future<void> _pasteShareCode() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text == null || data!.text!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard is empty or invalid')),
      );
      return;
    }

    try {
      final jsonStr = utf8.decode(base64Decode(data.text!));
      final Map<String, dynamic> jsonData = jsonDecode(jsonStr);

      setState(() {
        placedIcons.clear();
        if (jsonData.containsKey('icons')) {
          placedIcons.addAll(
            (jsonData['icons'] as List).map(
              (e) => PlacedIcon.fromJsonNormalized(e, _canvasSize),
            ),
          );
        }

        strokes.clear();
        if (jsonData.containsKey('strokes')) {
          strokes.addAll(
            (jsonData['strokes'] as List).map(
              (e) => Stroke.fromJsonNormalized(e, _canvasSize),
            ),
          );
        }
      });

      await saveLayout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Map loaded from clipboard')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load map from clipboard')),
      );
    }
  }

  void _confirmClearStrokes() async {
    if (strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There are no strokes to clear.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Strokes?'),
            content: const Text(
              'This will remove all drawn lines from the map.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Clear Strokes'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        strokes.clear();
      });
      await saveLayout(); // Save without strokes
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All strokes cleared')));
    }
  }

  Widget _colorButton(Color color) {
    final bool isSelected = _selectedStrokeColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedStrokeColor = color),
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            width: isSelected ? 3.0 : 1.5,
            color: isSelected ? Colors.tealAccent : Colors.grey.shade800,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color.fromARGB(164, 100, 255, 219),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ]
                  : [],
        ),
      ),
    );
  }

  bool _isWithinCanvas(Offset point) {
    return point.dx >= 0 &&
        point.dy >= 0 &&
        point.dx <= _canvasSize &&
        point.dy <= _canvasSize;
  }

  void _startStroke(Offset point) {
    if (_isWithinCanvas(point)) {
      setState(() {
        _currentStroke = Stroke(
          points: [point],
          color: _selectedStrokeColor,
          id: UniqueKey().toString(),
        );
      });
    }
  }

  void _addPointToStroke(Offset point) {
    if (_isWithinCanvas(point)) {
      setState(() {
        _currentStroke?.points.add(point);
      });
    } else {
      // If the point is outside the canvas, end the stroke
      _endStroke();
      saveLayout();
    }
  }

  void _endStroke() {
    setState(() {
      if (_currentStroke != null) {
        strokes.add(_currentStroke!);
        _currentStroke = null;
        saveLayout();
      }
    });
  }

  void _showDeleteMenu(BuildContext context, TapDownDetails details) async {
    final RenderBox canvasBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = canvasBox.globalToLocal(details.globalPosition);

    // Find closest icon
    const iconThreshold = 20.0;
    PlacedIcon? iconNearby;
    double iconMinDistance = double.infinity;

    for (final icon in placedIcons) {
      final distance = (icon.offset - localPosition).distance;
      if (distance < iconThreshold && distance < iconMinDistance) {
        iconMinDistance = distance;
        iconNearby = icon;
      }
    }

    // Find closest stroke
    final strokeNearby = _findStrokeNear(localPosition);

    // Build menu options
    final menuItems = <PopupMenuEntry<String>>[];
    if (iconNearby != null) {
      if (iconNearby.assetPath != null &&
              iconNearby.assetPath!.contains("Titanium") ||
          iconNearby.assetPath!.contains("Stravidium")) {
        menuItems.add(
          const PopupMenuItem<String>(
            value: 'edit_icon',
            child: Text('Add Count'),
          ),
        );
      }
      menuItems.add(
        const PopupMenuItem<String>(
          value: 'delete_icon',
          child: Text('Delete Icon'),
        ),
      );
    }
    if (strokeNearby != null) {
      menuItems.add(
        const PopupMenuItem<String>(
          value: 'delete_stroke',
          child: Text('Delete Stroke'),
        ),
      );
    }

    // If nothing is near, don't show the menu
    if (menuItems.isEmpty) return;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx + 1,
        details.globalPosition.dy + 1,
      ),
      items: menuItems,
    );

    setState(() {
      switch (selected) {
        case 'delete_icon':
          if (iconNearby != null) {
            placedIcons.removeWhere((icon) => icon.id == iconNearby!.id);
            saveLayout();
          }
          break;
        case 'edit_icon':
          _showIconDetailsDialog(iconNearby!);
          break;
        case 'delete_stroke':
          if (strokeNearby != null) {
            strokes.removeWhere((stroke) => stroke.id == strokeNearby.id);
            saveLayout();
          }
          break;
        default:
      }
    });
  }

  void _showIconDetailsDialog(PlacedIcon icon) {
    final TextEditingController controller = TextEditingController(
      text: icon.nodeCount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Icon Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon.assetPath != null)
                Image.asset(icon.assetPath!, height: 40)
              else if (icon.iconData != null)
                Icon(icon.iconData, size: 40, color: icon.color),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Node Count',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null) {
                  setState(() {
                    icon.nodeCount = value;
                  });
                  saveLayout();
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Stroke? _findStrokeNear(Offset position, {double threshold = 10.0}) {
    for (final stroke in strokes) {
      for (final point in stroke.points) {
        if ((point - position).distance <= threshold) {
          return stroke;
        }
      }
    }
    return null;
  }

  File _getSaveFile() {
    // Use the user's Documents directory for safe file storage on Windows
    final home = Platform.environment['USERPROFILE'] ?? '.';
    final documentsDir = Directory('$home\\.dune-awakening');

    return File('${documentsDir.path}\\map_data.json');
  }

  Future<void> saveLayout() async {
    final file = _getSaveFile();

    final jsonData = {
      'icons':
          placedIcons
              .map((icon) => icon.toJsonNormalized(_canvasSize))
              .toList(),
      'strokes':
          strokes
              .map((stroke) => stroke.toJsonNormalized(_canvasSize))
              .toList(),
    };

    await file.writeAsString(jsonEncode(jsonData));
  }

  Future<void> loadLayout() async {
    final file = _getSaveFile();
    if (await file.exists()) {
      final jsonStr = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(jsonStr);

      setState(() {
        // Load icons
        placedIcons.clear();
        if (jsonData.containsKey('icons')) {
          placedIcons.addAll(
            (jsonData['icons'] as List<dynamic>)
                .map((json) => PlacedIcon.fromJsonNormalized(json, _canvasSize))
                .toList(),
          );
        }

        // Load strokes
        strokes.clear();
        if (jsonData.containsKey('strokes')) {
          strokes.addAll(
            (jsonData['strokes'] as List<dynamic>)
                .map((json) => Stroke.fromJsonNormalized(json, _canvasSize))
                .toList(),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No save file found')));
    }
  }
}
