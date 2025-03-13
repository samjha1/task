class Purchase {
  final String id;
  final String userId;
  final String planId;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double amount;

  Purchase({
    required this.id,
    required this.userId,
    required this.planId,
    required this.purchaseDate,
    required this.expiryDate,
    required this.amount,
  });

  factory Purchase.fromMap(Map<String, dynamic> map, String id) {
    return Purchase(
      id: id,
      userId: map['userId'],
      planId: map['planId'],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchaseDate']),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      amount: map['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'planId': planId,
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'amount': amount,
    };
  }
}
