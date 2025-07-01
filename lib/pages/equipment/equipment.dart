import 'dart:convert';
import 'dart:io';
import 'package:deep_desert/pages/equipment/models/equipment.dart';
import 'package:deep_desert/pages/equipment/models/power.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  List<Equipment> equipmentList = [];
  List<Power> powerList = [];
  int fuelDays = 7; // Default to 7 days
  Map<String, int> fuelTotals = {};
  int totalPowerUsage = 0;
  int totalPowerGenerated = 0;
  int totalWaterStorage = 0;
  int totalPhysicalStorage = 0;
  Map<dynamic, int> selectedEquipment = {};
  String searchQuery = '';
  bool isHalved = true;

  @override
  void initState() {
    super.initState();
    _loadEquipment().then((_) {
      _loadSelectedEquipment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredList =
        equipmentList
            .where(
              (e) => e.name.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();
    final materialsSummary = _calculateMaterialsSummary();

    return Row(
      children: [
        Container(
          width: 350,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Equipment',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final equipment = filteredList[index];

                          String text = 'Power Generated: ${equipment.power}';

                          if (equipment.storageCapacity != null) {
                            // Skip water storage items in the main list
                            text =
                                'Storage: ${equipment.storageCapacity!.volume} (${equipment.storageCapacity!.type})';
                          }
                          return Card(
                            child: ListTile(
                              title: Text(equipment.name),
                              subtitle: Text(text),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedEquipment.update(
                                      equipment,
                                      (count) => count + 1,
                                      ifAbsent: () => 1,
                                    );
                                    totalPowerUsage += equipment.power;
                                    _recalculateStorageTotals();
                                    _saveSelectedEquipment();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Power Sources',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: powerList.length,
                        itemBuilder: (context, index) {
                          final power = powerList[index];
                          return Card(
                            child: ListTile(
                              title: Text(power.name),
                              subtitle: Text(
                                'Power Generated: ${power.powerGenerated}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedEquipment.update(
                                      power,
                                      (count) => count + 1,
                                      ifAbsent: () => 1,
                                    );
                                    totalPowerGenerated += power.powerGenerated;
                                    _recalculateStorageTotals();
                                    _saveSelectedEquipment();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),

        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Selected Equipment',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Expanded(
                      child: ListView(
                        children:
                            selectedEquipment.entries.map((entry) {
                              String text = '';
                              if (entry.key is Equipment) {
                                if (entry.key.type == "Storage") {
                                  text =
                                      'Storage: ${(entry.key as Equipment).storageCapacity!.volume * entry.value} (${(entry.key as Equipment).storageCapacity!.type})';
                                } else {
                                  // If it's an equipment without storage, show power usage
                                  final equipment = entry.key as Equipment;
                                  totalPowerUsage +=
                                      equipment.power * entry.value;
                                  text =
                                      'Power Usage: ${(entry.key as Equipment).power * entry.value}';
                                }
                              } else if (entry.key is Power) {
                                text =
                                    'Power Generated: ${(entry.key as Power).powerGenerated * entry.value}';
                              }

                              return ListTile(
                                title: Text(entry.key.name),
                                subtitle: Text(
                                  text,
                                  style: TextStyle(
                                    color:
                                        entry.key is Equipment
                                            ? ((entry.key as Equipment).power >
                                                    0
                                                ? Colors.red
                                                : Colors.green)
                                            : entry.key is Power
                                            ? Colors.green
                                            : null,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          final count =
                                              selectedEquipment[entry.key]!;
                                          if (count > 1) {
                                            selectedEquipment[entry.key] =
                                                count - 1;
                                          } else {
                                            selectedEquipment.remove(entry.key);
                                          }
                                          if (entry.key is Equipment) {
                                            totalPowerUsage -=
                                                (entry.key.power as num)
                                                    .toInt();
                                          } else if (entry.key is Power) {
                                            totalPowerGenerated -=
                                                (entry.key.powerGenerated
                                                        as num)
                                                    .toInt();
                                          }
                                          _recalculateStorageTotals();
                                          _saveSelectedEquipment();
                                        });
                                      },
                                    ),
                                    Text(
                                      '${entry.value}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          selectedEquipment[entry.key] =
                                              entry.value + 1;
                                          if (entry.key is Equipment) {
                                            totalPowerUsage +=
                                                (entry.key.power as num)
                                                    .toInt();
                                          } else if (entry.key is Power) {
                                            totalPowerGenerated +=
                                                (entry.key.powerGenerated
                                                        as num)
                                                    .toInt();
                                          }
                                          _recalculateStorageTotals();
                                          _saveSelectedEquipment();
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          selectedEquipment.remove(entry.key);
                                          if (entry.key is Equipment) {
                                            totalPowerUsage -=
                                                (entry.key.power as num)
                                                    .toInt();
                                          } else if (entry.key is Power) {
                                            totalPowerGenerated -=
                                                (entry.key.powerGenerated
                                                        as num)
                                                    .toInt();
                                          }
                                          _recalculateStorageTotals();
                                          _saveSelectedEquipment();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Required Materials',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Material')),
                        DataColumn(label: Text('Amount')),
                      ],
                      rows:
                          materialsSummary.entries.map((entry) {
                            if (isHalved) {
                              entry = MapEntry(
                                entry.key,
                                (entry.value / 2).ceil(),
                              );
                            }
                            return DataRow(
                              cells: [
                                DataCell(Text(entry.key)),
                                DataCell(Text(entry.value.toString())),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        VerticalDivider(width: 1),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 280,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text('Power', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Usage:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '$totalPowerUsage',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Generated:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '$totalPowerGenerated',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Deficit:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${totalPowerGenerated - totalPowerUsage}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              (totalPowerGenerated - totalPowerUsage) < 0
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text('Storage', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Water Storage:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '$totalWaterStorage',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Physical Storage:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '$totalPhysicalStorage',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Fuel Requirements',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Days to calculate:'),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: fuelDays.toString(),
                          ),
                          onSubmitted: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed > 0) {
                              setState(() {
                                fuelDays = parsed;
                                _recalculateStorageTotals();
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (fuelTotals.isEmpty)
                  const Text('No fuel requirements.')
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          fuelTotals.entries.map((entry) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${entry.key}:'),
                                Text('${entry.value}'),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Halved Requirements',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Switch(
                          value: isHalved,
                          onChanged: (value) {
                            setState(() {
                              isHalved = value;
                              _recalculateStorageTotals();
                            });
                          },
                          activeColor: Colors.tealAccent.shade200,
                          activeTrackColor:
                              Colors.tealAccent.shade700, // Track color when ON
                        ),
                        Text(
                          isHalved ? 'Enabled' : 'Disabled',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    final buffer = StringBuffer();
                    buffer.writeln('```'); // Start code block
                    buffer.writeln('Equipment                    | Amount');
                    buffer.writeln('-----------------------------|--------');
                    for (var entry in selectedEquipment.entries) {
                      final item = entry.key;
                      final count = entry.value;

                      buffer.writeln(
                        '${item.name.padRight(29)}| ${count.toString().padLeft(6)}',
                      );
                    }
                    buffer.writeln('');
                    buffer.writeln('Material                     | Amount');
                    buffer.writeln('-----------------------------|--------');

                    for (var entry in materialsSummary.entries) {
                      final amount =
                          isHalved ? (entry.value / 2).ceil() : entry.value;
                      final material = entry.key.padRight(29);
                      final amountStr = amount.toString().padLeft(6);
                      buffer.writeln('$material| $amountStr');
                    }

                    if (fuelTotals.isNotEmpty) {
                      buffer.writeln('');
                      buffer.writeln('Fuel                         | Amount');
                      buffer.writeln('-----------------------------|--------');

                      for (var entry in fuelTotals.entries) {
                        final fuelType = entry.key.padRight(29);
                        final amountStr = entry.value.toString().padLeft(6);
                        buffer.writeln('$fuelType| $amountStr');
                      }
                    }
                    buffer.writeln('```'); // End code block
                    Clipboard.setData(ClipboardData(text: buffer.toString()));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Materials copied to clipboard!'),
                      ),
                    );
                  },
                  child: Text('Copy Required Amounts'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _recalculateStorageTotals() {
    totalWaterStorage = 0;
    totalPhysicalStorage = 0;
    fuelTotals.clear();

    for (final entry in selectedEquipment.entries) {
      final item = entry.key;
      final count = entry.value;

      // Storage
      if (item is Equipment && item.storageCapacity != null) {
        final storage = item.storageCapacity!;
        final volume = storage.volume * count;
        if (storage.type.toLowerCase() == 'water') {
          totalWaterStorage += volume;
        } else {
          totalPhysicalStorage += volume;
        }
      }

      // Fuel
      if (item is Power) {
        final fuel = item.fuel;
        final totalFuel = fuel.amountPerDay * fuelDays * count; // ← FIXED
        // add the fuel materials to the table

        fuelTotals.update(
          fuel.type,
          (prev) => prev + totalFuel,
          ifAbsent: () => totalFuel,
        );
      }
    }
  }

  File _getSaveFile(String filename) {
    // Use the user's Documents directory for safe file storage on Windows
    final home = Platform.environment['USERPROFILE'] ?? '.';
    final documentsDir = Directory('$home\\.dune-awakening');

    String path = '${documentsDir.path}\\$filename';
    File file = File(path);

    if (!file.existsSync()) {
      file.createSync(recursive: true);
      file.writeAsString('[]'); // Initialize with an empty JSON array
    }

    return file;
  }

  Future<void> _saveSelectedEquipment() async {
    final file = _getSaveFile('selected_equipment.json');
    final data =
        selectedEquipment.entries.map((entry) {
          return {
            'name': entry.key.name,
            'type': entry.key is Equipment ? 'equipment' : 'power',
            'count': entry.value,
          };
        }).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> _loadSelectedEquipment() async {
    final file = _getSaveFile('selected_equipment.json');
    final content = await file.readAsString();
    final List<dynamic> data = jsonDecode(content);

    int tempPowerUsage = 0;
    int tempPowerGenerated = 0;

    for (final item in data) {
      final String name = item['name'];
      final String type = item['type'];
      final int count = item['count'];

      if (type == 'equipment') {
        Equipment? match;
        try {
          match = equipmentList.firstWhere((e) => e.name == name);
        } catch (_) {
          match = null;
        }
        if (match != null) {
          selectedEquipment[match] = count;
          tempPowerUsage += match.power * count;
        }
      } else if (type == 'power') {
        Power? match;
        try {
          match = powerList.firstWhere((p) => p.name == name);
        } catch (_) {
          match = null;
        }
        if (match != null) {
          selectedEquipment[match] = count;
          tempPowerGenerated += match.powerGenerated * count;
        }
      }
    }

    setState(() {
      totalPowerUsage = tempPowerUsage;
      totalPowerGenerated = tempPowerGenerated;
      _recalculateStorageTotals();
    });
  }

  Map<String, int> _calculateMaterialsSummary() {
    final Map<String, int> summary = {};
    for (var entry in selectedEquipment.entries) {
      final equipment = entry.key;
      final count = entry.value;
      for (var mat in equipment.materials) {
        summary.update(
          mat.type,
          (value) => (value + (mat.amount * count)).toInt(),
          ifAbsent: () => mat.amount * count,
        );
      }
    }
    return summary;
  }

  Future<void> _loadEquipment() async {
    final file = _getSaveFile('equipment.json');

    if (file.existsSync()) {
      final content = await file.readAsString();
      final Map<String, dynamic> all = jsonDecode(content);
      final List<dynamic> equipmentJsonList = all['equipment'] as List<dynamic>;
      final List<dynamic> powerJsonList = all['power'] as List<dynamic>;
      setState(() {
        equipmentList =
            equipmentJsonList
                .map((json) => Equipment.fromJson(json as Map<String, dynamic>))
                .toList();

        powerList =
            powerJsonList
                .map((json) => Power.fromJson(json as Map<String, dynamic>))
                .toList();
      });
    } else {
      print('Equipment file not found.');
    }
  }
}
