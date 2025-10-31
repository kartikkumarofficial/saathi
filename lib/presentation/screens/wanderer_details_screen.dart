import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WandererDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> walker;
  const WandererDetailsScreen({super.key, required this.walker});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(walker['full_name'] ?? "Walker Details"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: w * 0.18,
              backgroundImage: NetworkImage(
                walker['profile_image'] ?? 'https://via.placeholder.com/100',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              walker['full_name'] ?? 'Unknown Walker',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: w * 0.06,
                  color: Colors.green.shade800),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text("${walker['rating'] ?? 4.8}",
                    style: TextStyle(fontSize: w * 0.045)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Ready to accompany you on your next peaceful walk!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
