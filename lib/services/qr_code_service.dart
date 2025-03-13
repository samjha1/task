// lib/services/qr_code_service.dart
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class QRCodeService {
  static Future<String> generateQRCode({
    required String userId,
    required String planId,
    required DateTime expiryDate,
  }) async {
    // Create a unique identifier for this subscription
    final uuid = Uuid();
    final uniqueId = uuid.v4();
    
    // Create a string with all the relevant information
    final dataString = '$userId|$planId|${expiryDate.millisecondsSinceEpoch}|$uniqueId';
    
    // Create a hash of the data for verification
    final bytes = utf8.encode(dataString);
    final digest = sha256.convert(bytes);
    
    // Return the final QR code data
    return '$dataString|${digest.toString()}';
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
      
      // Recreate the hash for verification
      final dataString = '$userId|$planId|$expiryTimestamp|$uniqueId';
      final bytes = utf8.encode(dataString);
      final digest = sha256.convert(bytes);
      
      // Check if the QR code is valid and not expired
      final now = DateTime.now().millisecondsSinceEpoch;
      return providedHash == digest.toString() && expiryTimestamp > now;
    } catch (e) {
      return false;
    }
  }
}
