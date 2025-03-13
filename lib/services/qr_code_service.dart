import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeService {
  static Future<String> generateQRCode({
    required String userId,
    required String planId,
    required DateTime expiryDate,
  }) async {
    final uuid = Uuid();
    final uniqueId = uuid.v4();

    final dataString =
        '$userId|$planId|${expiryDate.millisecondsSinceEpoch}|$uniqueId';

    final bytes = utf8.encode(dataString);
    final digest = sha256.convert(bytes);

    final qrCodeData = '$dataString|${digest.toString()}';

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'qrcode': qrCodeData,
      'planId': planId,
      'planExpiryDate': expiryDate.toIso8601String(),
    });

    return qrCodeData;
  }

  static Future<String?> fetchQRCode(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['qrCodeData'] as String?;
    }
    return null;
  }

  static bool verifyQRCode(String qrData) {
    try {
      final parts = qrData.split('|');
      if (parts.length != 5) return false;

      final userId = parts[0];
      final planId = parts[1];
      final expiryTimestamp = int.parse(parts[2]);
      final uniqueId = parts[3];
      final providedHash = parts[4];

      final dataString = '$userId|$planId|$expiryTimestamp|$uniqueId';
      final bytes = utf8.encode(dataString);
      final digest = sha256.convert(bytes);

      final now = DateTime.now().millisecondsSinceEpoch;
      return providedHash == digest.toString() && expiryTimestamp > now;
    } catch (e) {
      return false;
    }
  }
}
