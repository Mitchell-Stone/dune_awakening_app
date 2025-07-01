class Storage {
  final String type;
  final int volume;

  Storage({required this.type, required this.volume});

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(type: json['type'], volume: json['volume']);
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'volume': volume};
  }
}


