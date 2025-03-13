class Plan {
  final String id;
  final String name;
  final double price;
  final int validity;
  final List<String> features;

  Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.validity,
    required this.features,
    required String validityText,
  });

  factory Plan.fromMap(Map<String, dynamic> map, String id) {
    return Plan(
      id: id,
      name: map['name'],
      price: map['price'].toDouble(),
      validity: map['validity'],
      features: List<String>.from(map['features']),
      validityText: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'validity': validity,
      'features': features,
    };
  }

  String get validityText {
    if (validity == 7) return '1 Week';
    if (validity == 30) return '1 Month';
    if (validity == 90) return '3 Months';
    return '$validity days';
  }
}
