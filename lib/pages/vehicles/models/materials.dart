class MaterialRequirement {
  final String name;
  final int amount;

  MaterialRequirement({required this.name, required this.amount});

  factory MaterialRequirement.fromJson(Map<String, dynamic> json) {
    // Some entries use 'type', some use 'name'
    return MaterialRequirement(
      name: json['name'] ?? json['type'],
      amount: json['amount'],
    );
  }
}
