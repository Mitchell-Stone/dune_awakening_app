
import 'package:deep_desert/pages/equipment/models/power.dart';
import 'package:deep_desert/pages/equipment/models/storage.dart';

class Equipment {
  final String name;
  final String type;
  final String description;
  final int power;
  final List<EquipmentMaterial> materials;
  final Storage? storageCapacity;

  Equipment({
    required this.name,
    required this.type,
    required this.description,
    required this.power,
    required this.materials,
    this.storageCapacity,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'power': power,
      'materials': materials.map((m) => m.toJson()).toList(),
      'name': name,
      'type': type,
      'storage_capacity': storageCapacity?.toJson(),
      'power_usage': power,
    };
  }

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      name: json['name'],
      type: json['type'],
      description: json['description'],
      power: json['power_usage'],
      materials:
          (json['materials'] as List<dynamic>)
              .map((m) => EquipmentMaterial.fromJson(m))
              .toList(),
      storageCapacity:
          json['storage_capacity'] != null
              ? Storage.fromJson(json['storage_capacity'])
              : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Equipment &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
