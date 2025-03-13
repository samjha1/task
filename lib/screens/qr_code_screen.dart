import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeScreen extends StatefulWidget {
  final String userId;

  QRCodeScreen({required this.userId});

  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? qrCodeData;
  DateTime? expiryDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQRCode();
  }

  Future<void> _fetchQRCode() async {
    await Future.delayed(Duration(seconds: 2));

    final data = null; 

    if (data != null) {
      setState(() {
        qrCodeData = data;
        expiryDate = _parseExpiryDate(data);
        isLoading = false;
      });
    } else {
      setState(() {
        qrCodeData = "SampleQRCode123456";
        expiryDate =
            DateTime.now().add(Duration(days: 30)); 
        isLoading = false;
      });
    }
  }

  DateTime? _parseExpiryDate(String qrData) {
    final parts = qrData.split('|');
    if (parts.length < 3) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(parts[2]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(color: Colors.black)
              : Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Subscription QR Code',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildQRCodeCard(),
                      SizedBox(height: 16),
                      if (expiryDate != null) _buildExpiryInfo(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildQRCodeCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black54,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            QrImageView(
              data: qrCodeData!,
              version: QrVersions.auto,
              size: 250,
            ),
            SizedBox(height: 10),
            Text(
              'Scan this QR Code',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryInfo() {
    final remainingDays = expiryDate!.difference(DateTime.now()).inDays;
    final isExpiringSoon = remainingDays <= 5;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black26,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Expires on: ${expiryDate!.toLocal()}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: remainingDays / 30,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                    isExpiringSoon ? Colors.red : Colors.green),
              ),
            ),
            SizedBox(height: 10),
            Text(
              remainingDays > 0
                  ? '$remainingDays days remaining'
                  : 'Subscription Expired',
              style: TextStyle(
                color: isExpiringSoon ? Colors.red : Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
