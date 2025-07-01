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

class AssaultOrnithopter {
  final String name;
  final String description;
  final Map<String, int> assemblyRequirement;
  final List<Cabin> cabins;
  final List<Cockpit> cockpits;
  final List<OrnithopterEngine> engines;
  final List<Generator> generators;
  final List<Tail> tails;
  final List<Wing> wings;

  AssaultOrnithopter({
    required this.name,
    required this.description,
    required this.assemblyRequirement,
    required this.cabins,
    required this.cockpits,
    required this.engines,
    required this.generators,
    required this.tails,
    required this.wings,
  });

  factory AssaultOrnithopter.fromJson(Map<String, dynamic> json) {
    return AssaultOrnithopter(
      name: json['name'],
      description: json['description'],
      assemblyRequirement: Map<String, int>.from(json['assemblyRequirement']),
      cabins: (json['parts']['cabins'] as List)
          .map((e) => Cabin.fromJson(e))
          .toList(),
      cockpits: (json['parts']['cockpits'] as List)
          .map((e) => Cockpit.fromJson(e))
          .toList(),
      engines: (json['parts']['engines'] as List)
          .map((e) => OrnithopterEngine.fromJson(e))
          .toList(),
      generators: (json['parts']['generators'] as List)
          .map((e) => Generator.fromJson(e))
          .toList(),
      tails: (json['parts']['tails'] as List)
          .map((e) => Tail.fromJson(e))
          .toList(),
      wings: (json['parts']['wings'] as List)
          .map((e) => Wing.fromJson(e))
          .toList(),
    );
  }
}

class Cabin extends VehicleComponent {
  final int armor;
  final int seats;
  final int utilitySlots;

  Cabin({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.armor,
    required this.seats,
    required this.utilitySlots,
  });

  factory Cabin.fromJson(Map<String, dynamic> json) {
    return Cabin(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      armor: json['armor'],
      seats: json['seats'],
      utilitySlots: json['utilitySlots'],
      materials: (json['materials'] as List)
          .map((m) => MaterialRequirement.fromJson(m))
          .toList(),
    );
  }
}

class Cockpit extends VehicleComponent {
  final int armor;
  final int seats;
  final int utilitySlots;

  Cockpit({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.armor,
    required this.seats,
    required this.utilitySlots,
  });

  factory Cockpit.fromJson(Map<String, dynamic> json) {
    return Cockpit(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      armor: json['armor'],
      seats: json['seats'],
      utilitySlots: json['utilitySlots'],
      materials: (json['materials'] as List)
          .map((m) => MaterialRequirement.fromJson(m))
          .toList(),
    );
  }
}

class OrnithopterEngine extends VehicleComponent {
  final double speedKmh;
  final double powerConsumptionPerSecond;

  OrnithopterEngine({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.speedKmh,
    required this.powerConsumptionPerSecond,
  });

  factory OrnithopterEngine.fromJson(Map<String, dynamic> json) {
    return OrnithopterEngine(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      speedKmh: (json['speedKmh'] as num).toDouble(),
      powerConsumptionPerSecond: (json['powerConsumptionPerSecond'] as num).toDouble(),
      materials: (json['materials'] as List)
          .map((m) => MaterialRequirement.fromJson(m))
          .toList(),
    );
  }
}

class Generator extends VehicleComponent {
  final double temperatureRating;
  final double fuelEfficiencyPercent;

  Generator({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.temperatureRating,
    required this.fuelEfficiencyPercent,
  });

  factory Generator.fromJson(Map<String, dynamic> json) {
    return Generator(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      temperatureRating: (json['temperatureRating'] as num).toDouble(),
      fuelEfficiencyPercent: (json['fuelEfficiencyPercent'] as num).toDouble(),
      materials: (json['materials'] as List)
          .map((m) => MaterialRequirement.fromJson(m))
          .toList(),
    );
  }
}

class Tail extends VehicleComponent {
  final int armor;

  Tail({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.armor,
  });

  factory Tail.fromJson(Map<String, dynamic> json) {
    return Tail(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      armor: json['armor'],
      materials: (json['materials'] as List)
          .map((m) => MaterialRequirement.fromJson(m))
          .toList(),
    );
  }
}

class Wing extends VehicleComponent {
  final int armor;
  final String wingType;
  final double glideSpeedKmh;
  final int turnRating;
  final int agility;

  Wing({
    required super.type,
    required super.description,
    required super.durability,
    required super.assemblyRequirement,
    required super.materials,
    required this.armor,
    required this.wingType,
    required this.glideSpeedKmh,
    required this.turnRating,
    required this.agility,
  });

  factory Wing.fromJson(Map<String, dynamic> json) {
    return Wing(
      type: json['type'],
      description: json['description'],
      durability: json['durability'],
      assemblyRequirement: json['assemblyRequirement'],
      armor: json['armor'],
      wingType: json['wingType'],
      glideSpeedKmh: (json['glideSpeedKmh'] as num).toDouble(),
      turnRating: json['turnRating'],
      agility: json['agility'],
      materials: (json['materials'] as List)
          .map((m) => MaterialRequirement.fromJson(m))
          .toList(),
    );
  }
}
