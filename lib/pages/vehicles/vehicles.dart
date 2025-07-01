import 'package:flutter/material.dart';

class Vehicles extends StatefulWidget {
  const Vehicles({super.key});

  @override
  State<Vehicles> createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
        bottom: const TabBar(
        isScrollable: true,
        tabs: [
          Tab(text: 'Sandbike'),
          Tab(text: 'Buggy'),
          Tab(text: 'Ornithopter'),
          Tab(text: 'Assault Ornithopter'),
          Tab(text: 'Carrier Ornithopter'),
          Tab(text: 'Sandcrawler'),
        ],
        ),
      ),
      body: const TabBarView(
        children: [
        Center(child: Text('Cars list goes here')),
        Center(child: Text('Trucks list goes here')),
        Center(child: Text('Bikes list goes here')),
        Center(child: Text('Boats list goes here')),
        Center(child: Text('Planes list goes here')),
        Center(child: Text('Trains list goes here')),
        ],
      ),
      ),
    );
  }
}