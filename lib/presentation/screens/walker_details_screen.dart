import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/wanderer_dashboard_controller.dart'; // adjust path if needed

class WalkerDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> walker;
  const WalkerDetailsScreen({super.key, required this.walker});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final c = Get.find<WandererDashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(walker['full_name'] ?? "Walker Details"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile photo
            CircleAvatar(
              radius: w * 0.18,
              backgroundImage: NetworkImage(
                walker['profile_image'] ?? 'https://via.placeholder.com/100',
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              walker['full_name'] ?? 'Unknown Walker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: w * 0.06,
                color: Colors.green.shade800,
              ),
            ),

            // Verified badge
            if (walker['is_verified'] == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "✅ Verified Walker",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  "${walker['rating'] ?? '4.8'}",
                  style: TextStyle(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bio
            Text(
              walker['bio'] ??
                  "Friendly and experienced walker, ready to accompany you on your next peaceful walk.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: w * 0.04,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // Languages
            if (walker['language'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Languages Spoken:",
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: (walker['language'] as List)
                        .map((lang) => Chip(
                      label: Text(lang.toString()),
                      backgroundColor: Colors.green.shade50,
                    ))
                        .toList(),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Interests
            if (walker['interests'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Interests:",
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: (walker['interests'] as List)
                        .map((intst) => Chip(
                      label: Text(intst.toString()),
                      backgroundColor: Colors.green.shade50,
                    ))
                        .toList(),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // Schedule button
            ElevatedButton.icon(
              onPressed: () => _showScheduleDialog(context, c, walker),
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: const Text("Schedule Walk",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showScheduleDialog(
      BuildContext context, WandererDashboardController c, Map<String, dynamic> walker) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (selectedDate == null) return;

    TimeOfDay? selectedTime =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (selectedTime == null) return;

    final scheduled = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        selectedTime.hour, selectedTime.minute);

    await c.scheduleWalk(walker['id'], scheduled);

    Get.snackbar(
      "Walk Scheduled",
      "You scheduled a walk with ${walker['full_name']} on ${DateFormat('MMM d, hh:mm a').format(scheduled)}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.black,
    );
  }
}


