import 'dart:io';

import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late String _dataLocation; // Example data location

  @override
  void initState() {
    super.initState();
    // Load settings from persistent storage or set defaults
    _loadSettings();
  }

  void _loadSettings() async {
    // Simulate loading settings from persistent storage
    final home = Platform.environment['USERPROFILE'] ?? '.';
    final documentsDir = Directory('$home\\.dune-awakening');
    setState(() {
      _dataLocation = documentsDir.path; // Example location
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Data Location'),
            subtitle: Text('All data use and stored by the app can be found here: ${_dataLocation}'),
          ),
        ],
      ),
    );
  }
}
