import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../models/plan_model.dart';
import 'plan_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class PlanListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Plans',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService.getPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No plans available.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          var plans = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Plan(
              id: doc.id,
              name: data['name'] ?? '',
              price: (data['price'] as num).toDouble(),
              validityText: '${data['validityDays']} days',
              features: List<String>.from(data['features'] ?? []),
              validity: data['validityDays'] ?? 0,
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                return _buildPlanCard(context, plans[index]);
              },
            ),
          );
        },
      ),
    );
  }

  /// Attractive Card UI for Plans
  Widget _buildPlanCard(BuildContext context, Plan plan) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              '\$${plan.price} / ${plan.validityText}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: plan.features
                  .map((feature) => Chip(
                        label: Text(feature, style: TextStyle(fontSize: 12)),
                        backgroundColor: Colors.blue[50],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlanDetailsScreen(plan: plan),
                    ),
                  );
                },
                child: Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer effect for loading
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 100,
              width: double.infinity,
              padding: EdgeInsets.all(12),
            ),
          ),
        );
      },
    );
  }
}
