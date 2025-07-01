import 'dart:io';
import 'package:deep_desert/pages/equipment/equipment.dart';
import 'package:deep_desert/pages/map_editor/map_editor.dart';
import 'package:deep_desert/pages/settings/settings.dart';
import 'package:deep_desert/pages/vehicles/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure you add the asset in pubspec.yaml under flutter: assets:
    // - data/equipment.json

    return MaterialApp(
      title: 'Dune: Awakening',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF1E1E1E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent.shade700,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: const Color.fromARGB(179, 255, 255, 255),
          displayColor: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Dune: Awakening - Deep Desert')),
        body: const MainNavigationPage(),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    MapEditor(),
    EquipmentPage(),
    Vehicles(),
    Settings(),
  ];

  final List<String> fileNames = [
    'map_data.json',
    'equipment.json',
    'selected_equipment.json',
  ];

  // Example of loading the asset when the app starts
  @override
  void initState() {
    super.initState();
    // You can load the asset here or in a provider/init function
    for (var fileName in fileNames) {
      _loadAsset(fileName);
    }
  }

  _loadAsset(String filename) async {
    final home = Platform.environment['USERPROFILE'] ?? '.';
    final documentsDir = Directory('$home\\.dune-awakening');

    if (!await documentsDir.exists()) {
      print('Creating documents directory at: ${documentsDir.path}');
      await documentsDir.create(recursive: true);
    }

    final file = File('${documentsDir.path}\\$filename');
    if (!await file.exists()) {
      print('Creating file: ${file.path}');
      await file.create(recursive: true);
      await file.writeAsString(
        await rootBundle.loadString('assets/data/$filename'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.map),
                label: Text('Map Editor'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.build),
                label: Text('Equipment'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.directions_car),
                label: Text('Vehicles'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
