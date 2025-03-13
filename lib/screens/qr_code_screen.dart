import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class QRCodeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your QR Code'),
      ),
      body: StreamBuilder<User?>(
        stream: DatabaseService.getUserStream(), // Ensure correct stream return type
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No active subscription found',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go back to plans'),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data!;
          if (user.qrCodeData == null) {
            return Center(
              child: Text('No QR Code available'),
            );
          }

          final planExpiryDate = user.planExpiryDate;

          return Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your Subscription QR Code',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: user.qrCodeData!,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
                  if (planExpiryDate != null)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Expires on:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${planExpiryDate.day}/${planExpiryDate.month}/${planExpiryDate.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _getRemainingTimePercentage(planExpiryDate),
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getRemainingTimePercentage(planExpiryDate) > 0.25
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _getRemainingDaysText(planExpiryDate),
                              style: TextStyle(
                                color: _getRemainingTimePercentage(planExpiryDate) > 0.25
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Show this QR code to verify your subscription',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _getRemainingTimePercentage(DateTime expiryDate) {
    final now = DateTime.now();
    final totalDuration = expiryDate.difference(now.subtract(Duration(days: 30))).inSeconds;
    final remainingDuration = expiryDate.difference(now).inSeconds;

    if (remainingDuration.isNegative) return 0.0;
    return totalDuration > 0 ? remainingDuration / totalDuration : 0.0;
  }

  String _getRemainingDaysText(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);

    if (difference.isNegative) {
      return 'Subscription expired';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days > 0) {
      return '$days days remaining';
    } else {
      return '$hours hours remaining';
    }
  }
}
