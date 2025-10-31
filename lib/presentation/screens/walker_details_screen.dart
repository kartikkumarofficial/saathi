import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/walker_details_controller.dart';
import '../../controllers/wanderer_dashboard_controller.dart';

class WalkerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> walker;
  const WalkerDetailsScreen({super.key, required this.walker});

  @override
  State<WalkerDetailsScreen> createState() => _WalkerDetailsScreenState();
}

class _WalkerDetailsScreenState extends State<WalkerDetailsScreen> {
  final WalkerDetailsController ctrl = Get.put(WalkerDetailsController());
  final WandererDashboardController dashCtrl = Get.find<WandererDashboardController>();

  @override
  void initState() {
    super.initState();
    final id = widget.walker['id']?.toString();
    if (id != null) ctrl.fetchReviews(id);
  }

  Future<void> _scheduleWalk() async {
    final walker = widget.walker;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    final scheduled = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    await dashCtrl.scheduleWalk(walker['id'], scheduled);
  }

  @override
  Widget build(BuildContext context) {
    final w = Get.width;
    final walker = widget.walker;

    return Scaffold(
      appBar: AppBar(
        title: Text(walker['full_name'] ?? 'Walker'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          children: [
            CircleAvatar(
              radius: w * 0.18,
              backgroundImage: walker['profile_image'] != null
                  ? NetworkImage(walker['profile_image'])
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              walker['full_name'] ?? 'Unknown',
              style: TextStyle(
                fontSize: w * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            if (walker['is_verified'] == true)
              Text('✅ Verified',
                  style: TextStyle(color: Colors.green.shade700)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  "${walker['rating'] ?? 4.8}",
                  style: TextStyle(fontSize: w * 0.045),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              walker['bio'] ?? 'No bio provided',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // ✅ Updated schedule button
            ElevatedButton.icon(
              onPressed: _scheduleWalk,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Schedule a Walk'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reviews',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: w * 0.05,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 🗣 Reviews list
            Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (ctrl.reviews.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No reviews yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }
              return Column(
                children: ctrl.reviews.map((r) {
                  final reviewer = r['reviewer'] as Map<String, dynamic>?;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: reviewer != null &&
                            reviewer['profile_image'] != null
                            ? NetworkImage(reviewer['profile_image'])
                            : null,
                      ),
                      title: Text(reviewer?['full_name'] ?? 'Anonymous'),
                      subtitle: Text(r['comment'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          Text('${r['rating'] ?? 0}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
