class User {
  final String id;
  final String name;
  final String email;
  String? activePlanId;
  DateTime? planExpiryDate;
  String? qrCodeData;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.activePlanId,
    this.planExpiryDate,
    this.qrCodeData,
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'],
      email: map['email'],
      activePlanId: map['activePlanId'],
      planExpiryDate: map['planExpiryDate'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['planExpiryDate']) 
        : null,
      qrCodeData: map['qrCodeData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'activePlanId': activePlanId,
      'planExpiryDate': planExpiryDate?.millisecondsSinceEpoch,
      'qrCodeData': qrCodeData,
    };
  }
}
