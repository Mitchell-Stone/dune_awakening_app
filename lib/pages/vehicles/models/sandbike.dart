// Vehicle models
import 'package:deep_desert/pages/vehicles/models/materials.dart';

abstract class VehicleComponent {
  final String type;
  final String description;
  final int durability;
  final String assemblyRequirement;
  final List<MaterialRequirement> materials;

  VehicleComponent({
    required this.type,
    required this.description,
    required this.durability,
    required this.assemblyRequirement,
    required this.materials,
  });
}

class Sandbike {
  final String name;
  final String description;
  final Map<String, int> assemblyRequirement;
  final List<Engine> engines;
  final List<Booster> boosters;
  final List<Tread> treads; // Add treads as needed
  final List<PowerSupplyUnit> psus; // Add PSUs as needed
  final List<Hull> hulls; // Add hulls as needed
  final List<Chassis> chassis; // Add chassis as needed
  // Define other part types like Chassis, Hull, PSU, Tread

  Sandbike({
    required this.name,
    required this.description,
    required this.assemblyRequirement,
    required this.engines,
    required this.boosters,
    required this.treads,
    required this.psus,
    required this.hulls,
    required this.chassis,
  });

  factory Sandbike.fromJson(Map<String, dynamic> json) {
    return Sandbike(
      name: json['name'],
      description: json['description'],
      assemblyRequirement: Map<String, int>.from(json['assemblyRequirement']),
      engines:
          (json['parts']['engines'] as List)
              .map((e) => Engine.fromJson(e))
              .toList(),
      boosters:
          (json['parts']['boosters'] as List?)
              ?.map((b) => Booster.fromJson(b))
              .toList() ??
          [],
      treads:
          (json['parts']['treads'] as List?)
              ?.map((t) => Tread.fromJson(t))
              .toList() ??
          [],
      psus:
          (json['parts']['powerSupplyUnits'] as List?)
              ?.map((p) => PowerSupplyUnit.fromJson(p))
              .toList() ??
          [],
      hulls:
          (json['parts']['hulls'] as List?)
              ?.map((h) => Hull.fromJson(h))
              .toList() ??
          [],
      chassis:
          (json['parts']['chassis'] as List?)
              ?.map((c) => Chassis.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class Tread extends VehicleComponent {
  final int armor;
  final int vibrationLevel;

  Tread({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.armor,
    required this.vibrationLevel,
  });

  factory Tread.fromJson(Map<String, dynamic> json) {
    return Tread(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      armor: json['armor'],
      vibrationLevel: json['vibrationLevel'],
      materials:
          (json['materials'] as List)
              .map((m) => MaterialRequirement.fromJson(m))
              .toList(),
    );
  }
}

class PowerSupplyUnit extends VehicleComponent {
  final double temperatureRating;
  final double fuelEfficiencyPercent;

  PowerSupplyUnit({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.temperatureRating,
    required this.fuelEfficiencyPercent,
  });

  factory PowerSupplyUnit.fromJson(Map<String, dynamic> json) {
    return PowerSupplyUnit(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      temperatureRating: (json['temperatureRating'] as num).toDouble(),
      fuelEfficiencyPercent: (json['fuelEfficiencyPercent'] as num).toDouble(),
      materials:
          (json['materials'] as List)
              .map((m) => MaterialRequirement.fromJson(m))
              .toList(),
    );
  }
}

class Hull extends VehicleComponent {
  final int armor;
  final int seats;
  final int utilitySlots;

  Hull({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.armor,
    required this.seats,
    required this.utilitySlots,
  });

  factory Hull.fromJson(Map<String, dynamic> json) {
    return Hull(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      armor: json['armor'],
      seats: json['seats'],
      utilitySlots: json['utilitySlots'],
      materials:
          (json['materials'] as List)
              .map((m) => MaterialRequirement.fromJson(m))
              .toList(),
    );
  }
}

class Chassis extends VehicleComponent {
  final int armor;
  final int fuelCapacity;

  Chassis({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.armor,
    required this.fuelCapacity,
  });

  factory Chassis.fromJson(Map<String, dynamic> json) {
    return Chassis(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      armor: json['armor'],
      fuelCapacity: json['fuelCapacity'],
      materials:
          (json['materials'] as List)
              .map((m) => MaterialRequirement.fromJson(m))
              .toList(),
    );
  }
}

class Booster extends VehicleComponent {
  final int armor;
  final double boostRating;
  final int extraHeat;
  final double powerConsumptionPerSecond;

  Booster({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.armor,
    required this.boostRating,
    required this.extraHeat,
    required this.powerConsumptionPerSecond,
  });

  factory Booster.fromJson(Map<String, dynamic> json) {
    return Booster(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      armor: json['armor'],
      boostRating: (json['boostRating'] as num).toDouble(),
      extraHeat: json['extraHeat'],
      powerConsumptionPerSecond:
          (json['powerConsumptionPerSecond'] as num).toDouble(),
      materials:
          (json['materials'] as List)
              .map((m) => MaterialRequirement.fromJson(m))
              .toList(),
    );
  }
}

class Engine extends VehicleComponent {
  final String acceleration;
  final double speedKmh;
  final double powerConsumptionPerSecond;

  Engine({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.acceleration,
    required this.speedKmh,
    required this.powerConsumptionPerSecond,
  });

  factory Engine.fromJson(Map<String, dynamic> json) {
    return Engine(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      acceleration: json['acceleration'],
      speedKmh: (json['speedKmh'] as num).toDouble(),
      powerConsumptionPerSecond:
          (json['powerConsumptionPerSecond'] as num).toDouble(),
      materials:
          (json['materials'] as List)
              .map((m) => MaterialRequirement.fromJson(m))
              .toList(),
    );
  }
}
