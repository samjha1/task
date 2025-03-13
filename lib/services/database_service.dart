import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _plansCollection =
      _firestore.collection('pricingPlans');
  static final CollectionReference _purchasesCollection =
      _firestore.collection('purchases');

  static Stream<QuerySnapshot> getPlans() {
    return _plansCollection.snapshots();
  }

  static Future<Map<String, dynamic>> purchasePlan(String planId) async {
    try {
      DocumentSnapshot planDoc = await _plansCollection.doc(planId).get();
      if (!planDoc.exists) {
        throw Exception("Plan not found");
      }
      Map<String, dynamic> planData = planDoc.data() as Map<String, dynamic>;

      String purchaseId = const Uuid().v4();
      String qrCodeData = "Purchase ID: $purchaseId, Plan: ${planData['name']}";

      DateTime expiryDate =
          DateTime.now().add(Duration(days: planData['validityDays'] ?? 30));

      await _purchasesCollection.doc(purchaseId).set({
        'planId': planId,
        'planName': planData['name'],
        'price': planData['price'],
        'expiryDate': Timestamp.fromDate(expiryDate),
        'qrCodeData': qrCodeData,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      return {
        'qrCodeData': qrCodeData,
        'expiryDate': expiryDate,
      };
    } catch (e) {
      print("Error purchasing plan: $e");
      throw e;
    }
  }

  static Future<void> checkAndUpdateExpiredPlans() async {
    try {
      QuerySnapshot snapshot = await _purchasesCollection.get();
      DateTime now = DateTime.now();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['expiryDate'] != null) {
          DateTime expiryDate = (data['expiryDate'] as Timestamp).toDate();
          if (expiryDate.isBefore(now)) {
            await _purchasesCollection
                .doc(doc.id)
                .update({'status': 'expired'});
          }
        }
      }
    } catch (e) {
      print("Error updating expired plans: $e");
    }
  }

  static getUserStream() {}
}
