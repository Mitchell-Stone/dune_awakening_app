
import 'package:deep_desert/pages/equipment/models/fuel.dart';

class Power {
  final String name;
  final String type;
  final String description;
  final List<EquipmentMaterial> materials;
  final Fuel fuel;
  final int powerGenerated;

  Power({
    required this.name,
    required this.type,
    required this.description,
    required this.materials,
    required this.fuel,
    required this.powerGenerated,
  });

  factory Power.fromJson(Map<String, dynamic> json) {
    return Power(
      name: json['name'],
      type: json['type'],
      description: json['description'],
      materials:
          (json['materials'] as List<dynamic>)
              .map((m) => EquipmentMaterial.fromJson(m))
              .toList(),
      fuel: Fuel.fromJson(json['fuel']),
      powerGenerated: json['power_generated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'materials': materials.map((m) => m.toJson()).toList(),
      'fuel': fuel.toJson(),
      'power_generated': powerGenerated,
    };
  }
}


class EquipmentMaterial {
  final String type;
  final int amount;

  EquipmentMaterial({required this.type, required this.amount});

  Map<String, dynamic> toJson() {
    return {'type': type, 'amount': amount};
  }

  factory EquipmentMaterial.fromJson(Map<String, dynamic> json) {
    return EquipmentMaterial(type: json['type'], amount: json['amount']);
  }
}


