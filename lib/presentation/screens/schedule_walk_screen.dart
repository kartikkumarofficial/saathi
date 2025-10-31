import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_walk_controller.dart';

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
  final c = Get.put(ScheduleWalkController());
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
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Choose a date and time for your walk 🗓️",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: h * 0.03),

            /// Pick date and time
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: pickDateTime,
              label: Text(
                selectedDateTime == null
                    ? "Pick Date & Time"
                    : "${selectedDateTime!.toLocal()}".split('.')[0],
              ),
            ),

            SizedBox(height: h * 0.05),

            /// Confirm button
            Obx(() {
              return c.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: const Icon(Icons.directions_walk),
                label: const Text("Confirm Walk"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.2,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (selectedDateTime == null) {
                    Get.snackbar(
                      "Error",
                      "Please select date and time",
                      backgroundColor: Colors.red.shade100,
                      colorText: Colors.red.shade800,
                    );
                  } else {
                    c.scheduleWalk(
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
