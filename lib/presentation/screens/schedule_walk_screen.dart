import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/walker_details_controller.dart';


class ScheduleWalkScreen extends StatefulWidget {
  final String walkerId;
  final String wandererId;

  const ScheduleWalkScreen({
    super.key,
    required this.walkerId,
    required this.wandererId,
  });

  @override
  State<ScheduleWalkScreen> createState() => _ScheduleWalkScreenState();
}

class _ScheduleWalkScreenState extends State<ScheduleWalkScreen> {
  final controller = Get.put(WandererDetailsController());
  DateTime? selectedDateTime;

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = Get.width;
    final h = Get.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text("Schedule a Walk"),
      ),
      body: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          children: [
            Text(
              "Choose a date and time for your walk",
              style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: h * 0.03),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
              ),
              onPressed: pickDateTime,
              label: Text(selectedDateTime == null
                  ? "Pick Date & Time"
                  : "${selectedDateTime!.toLocal()}".split('.')[0]),
            ),
            SizedBox(height: h * 0.05),
            Obx(() {
              return controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: const Icon(Icons.directions_walk),
                label: const Text("Confirm Walk"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.2, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (selectedDateTime == null) {
                    Get.snackbar("Error", "Please select date and time");
                  } else {
                    controller.scheduleWalk(
                      walkerId: widget.walkerId,
                      wandererId: widget.wandererId,
                      startTime: selectedDateTime!,
                    );
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
