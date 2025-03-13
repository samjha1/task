import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:task/services/qr_code_service.dart';

class QRCodeScreen extends StatefulWidget {
  final String userId;
  final String planId;

  QRCodeScreen({required this.userId, required this.planId});

  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? qrCodeData;
  DateTime? expiryDate;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQRCode();
  }

  Future<void> _fetchQRCode() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final qrData = await QRCodeService.fetchQRCode(widget.userId);

      if (qrData != null) {
        setState(() {
          qrCodeData = qrData;
          expiryDate = _parseExpiryDate(qrData);
          isLoading = false;
        });
      } else {
        await _generateNewQRCode();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load QR code: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _generateNewQRCode() async {
    try {
      final expiryDate = DateTime.now().add(Duration(days: 30));

      final qrData = await QRCodeService.generateQRCode(
        userId: widget.userId,
        planId: widget.planId,
        expiryDate: expiryDate,
      );

      setState(() {
        qrCodeData = qrData;
        this.expiryDate = expiryDate;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to generate QR code: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  DateTime? _parseExpiryDate(String qrData) {
    try {
      final parts = qrData.split('|');
      if (parts.length < 3) return null;
      return DateTime.fromMillisecondsSinceEpoch(int.parse(parts[2]));
    } catch (e) {
      return null;
    }
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchQRCode,
            color: Colors.white,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text('Loading your QR code...',
                        style: TextStyle(color: Colors.blue.shade800))
                  ],
                )
              : errorMessage != null && qrCodeData == null
                  ? _buildErrorView()
                  : Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your Subscription QR Code',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildQRCodeCard(),
                          SizedBox(height: 16),
                          if (expiryDate != null) _buildExpiryInfo(),
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchQRCode,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Try Again'),
            ),
          ),
        ],
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
              errorStateBuilder: (context, error) {
                return Container(
                  width: 250,
                  height: 250,
                  child: Center(
                    child: Text(
                      "Error generating QR code",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Scan this QR Code to verify subscription',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Plan: ${widget.planId}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryInfo() {
    final remainingDays = expiryDate!.difference(DateTime.now()).inDays;
    final isExpiringSoon = remainingDays <= 5 && remainingDays > 0;
    final isExpired = remainingDays <= 0;

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
              'Subscription ${isExpired ? 'Expired on' : 'Expires on'}:',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '${expiryDate!.toLocal().toString().split('.')[0]}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: isExpired ? 0 : (remainingDays / 30).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(isExpired
                    ? Colors.red
                    : (isExpiringSoon ? Colors.orange : Colors.green)),
              ),
            ),
            SizedBox(height: 10),
            if (QRCodeService.verifyQRCode(qrCodeData!))
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Invalid QR Code',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
