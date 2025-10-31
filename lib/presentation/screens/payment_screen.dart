import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatelessWidget {
  final Map<String, dynamic> walker;

  const PaymentScreen({super.key, required this.walker});

  @override
  Widget build(BuildContext context) {
    final w = Get.width;
    final h = Get.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: h * 0.05),
            const Icon(Icons.payment, size: 80, color: Colors.green),
            SizedBox(height: h * 0.03),
            Text(
              "Pay securely to confirm your walk with ${walker['full_name']}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: w * 0.045, color: Colors.grey.shade700),
            ),
            SizedBox(height: h * 0.05),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: EdgeInsets.symmetric(horizontal: w * 0.2, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Get.snackbar("Payment Successful", "Your walk has been booked!",
                    backgroundColor: Colors.green.shade100,
                    colorText: Colors.green.shade800);
                Get.offAllNamed('/home');
              },
              icon: const Icon(Icons.done),
              label: const Text("Pay Now ₹499"),
            )
          ],
        ),
      ),
    );
  }
}
