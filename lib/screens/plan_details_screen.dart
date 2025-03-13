import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/plan_model.dart';
import '../services/database_service.dart';
import 'purchase_confirmation_screen.dart';

class PlanDetailsScreen extends StatefulWidget {
  final Plan plan;

  const PlanDetailsScreen({Key? key, required this.plan}) : super(key: key);

  @override
  _PlanDetailsScreenState createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  bool _isPurchasing = false;

  Future<void> _handlePurchase() async {
    setState(() => _isPurchasing = true);

    try {
      final result = await DatabaseService.purchasePlan(widget.plan.id);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PurchaseConfirmationScreen(
            plan: widget.plan,
            qrCodeData: result['qrCodeData'],
            expiryDate: result['expiryDate'],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to purchase plan. Please try again.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Plan Details',
          style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blueAccent.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blueAccent,
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ],
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plan.name,
                    style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '\$${widget.plan.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '/ ${widget.plan.validityText}',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            Text(
              'Features',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 12),

            ...widget.plan.features.map((feature) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.greenAccent, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                )),

            SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPurchasing ? null : _handlePurchase,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blueAccent,
                ),
                child: _isPurchasing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Purchase Plan',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
