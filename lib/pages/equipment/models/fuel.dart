class Fuel {
  final String type;
  final int amountPerDay;

  Fuel({required this.type, required this.amountPerDay});

  factory Fuel.fromJson(Map<String, dynamic> json) {
    return Fuel(type: json['type'], amountPerDay: json['amount_per_day']);
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'amount_per_day': amountPerDay};
  }
}
