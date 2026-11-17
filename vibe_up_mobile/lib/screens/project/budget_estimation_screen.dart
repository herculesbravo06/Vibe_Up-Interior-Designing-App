import 'package:flutter/material.dart';
import 'package:vibe_up/theme/app_theme.dart';

class BudgetEstimationScreen extends StatelessWidget {
  const BudgetEstimationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result & Budget', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Final AR / Image representation
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.5), width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?q=80&w=1000&auto=format&fit=crop'), // Placeholder rendered room
                  fit: BoxFit.cover,
                )
              ),
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('3D Top View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
            Text('Budget Estimation', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Based on the catalogue items added to your 3D plan.', style: TextStyle(color: AppTheme.textDim)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildCostRow('Modern Sofa 1', '₹ 12,000.00'),
                  _buildCostRow('Glass Table 4', '₹ 1,600.00'),
                  _buildCostRow('Floor Lamp', '₹ 450.00'),
                  _buildCostRow('Designer Consultation', '₹ 0.00'),
                  const Divider(color: AppTheme.textDim, height: 32),
                  _buildCostRow('Total Estimated Cost', '₹ 14,050.00', isTotal: true),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                 // Save plan in JPEG/PDF 
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                   content: Text('Plan Saved successfully as PDF!'), 
                   backgroundColor: AppTheme.primaryAccent,
                 ));
                 Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Confirm & Save Plan (PDF/JPEG)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                 Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryAccent, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  foregroundColor: AppTheme.primaryAccent,
              ),
              child: const Text('Return to Home', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? AppTheme.primaryAccent : AppTheme.textLight)),
          Text(amount, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? AppTheme.primaryAccent : AppTheme.textLight)),
        ],
      ),
    );
  }
}
