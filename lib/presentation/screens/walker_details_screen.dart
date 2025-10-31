import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saathi/controllers/schedule_walk_controller.dart';
import 'package:saathi/controllers/walker_details_controller.dart';
import 'package:saathi/controllers/wanderer_dashboard_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalkerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> walker;
  const WalkerDetailsScreen({super.key, required this.walker});

  @override
  State<WalkerDetailsScreen> createState() => _WalkerDetailsScreenState();
}

class _WalkerDetailsScreenState extends State<WalkerDetailsScreen> {
  final WalkerDetailsController ctrl = Get.find<WalkerDetailsController>();
  final WandererDashboardController dashCtrl = Get.find<WandererDashboardController>();
  final ScheduleWalkController walkController = Get.find<ScheduleWalkController>();

  final Color primaryColor = const Color(0xFF7AB7A7);
  final Color gradientStart = const Color(0xFFeaf4f2);
  final Color gradientEnd = const Color(0xFFfdfaf6);
  final Color textPrimary = Colors.black87;
  final Color textSecondary = Colors.black54;

  @override
  void initState() {
    super.initState();
    final id = widget.walker['id']?.toString();
    if (id != null) ctrl.fetchReviews(id);
  }

  @override
  Widget build(BuildContext context) {
    final w = Get.width;
    final walker = widget.walker;
    final walkerName = walker['full_name'] ?? 'Walker';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          walkerName,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(w * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: w * 0.2,
                backgroundColor: Colors.white,
                backgroundImage: walker['profile_image'] != null
                    ? NetworkImage(walker['profile_image'])
                    : null,
                child: walker['profile_image'] == null
                    ? Icon(
                  Icons.person,
                  size: w * 0.2,
                  color: Colors.grey.shade300,
                )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                walkerName,
                style: GoogleFonts.nunito(
                  fontSize: w * 0.07,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Color(0xFFF9A825), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "${walker['rating'] ?? '4.8'} (12 Reviews)",
                    style: GoogleFonts.nunito(
                      fontSize: w * 0.04,
                      color: textSecondary,
                    ),
                  ),
                  if (walker['is_verified'] == true) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: GoogleFonts.nunito(
                        fontSize: w * 0.04,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ],
              ),
              const SizedBox(height: 24),
              _buildThemedButton(
                onPressed: () => _showScheduleDialog(context, walker),
                label: 'Schedule a Walk',
                icon: Icons.calendar_today,
                color: primaryColor,
              ),
              const SizedBox(height: 12),
              _buildThemedButton(
                onPressed: () {
                  Get.snackbar(
                    'Chat Feature',
                    'Chat with $walkerName is coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                label: 'Chat with $walkerName',
                icon: Icons.chat_bubble_outline,
                color: Colors.white,
                textColor: primaryColor,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(w, 'About $walkerName'),
              const SizedBox(height: 8),
              Text(
                walker['bio'] ??
                    'Friendly and experienced walker. '
                        'Loves meeting new people and exploring the city parks. '
                        'Available for morning and evening walks. '
                        'Fluent in English and Hindi.',
                textAlign: TextAlign.start,
                style: GoogleFonts.nunito(
                  fontSize: w * 0.04,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(w, 'Reviews'),
              const SizedBox(height: 8),
              Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.reviews.isEmpty) {
                  return Column(
                    children: [
                      _buildMockReview(w, 'Aarav Sharma',
                          'The journey was fantastic! So punctual and great to talk to. Felt very safe.'),
                      _buildMockReview(w, 'Priya Mehta',
                          'A very professional and kind companion. Highly recommend.'),
                    ],
                  );
                }
                return Column(
                  children: ctrl.reviews.map((r) {
                    final reviewer = r['reviewer'] as Map<String, dynamic>?;
                    return _buildReviewCard(
                      w,
                      reviewer?['full_name'] ?? 'Anonymous',
                      r['comment'] ?? '',
                      r['rating'] ?? 5,
                      reviewer?['profile_image'],
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Align _buildSectionHeader(double w, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.w800,
          fontSize: w * 0.05,
          color: textPrimary,
        ),
      ),
    );
  }

  Widget _buildThemedButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: Size(Get.width, Get.height * 0.065),
        textStyle: GoogleFonts.nunito(
          fontSize: Get.width * 0.042,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Get.height * 0.02),
          side: BorderSide(color: primaryColor, width: 1.5),
        ),
        elevation: 5,
      ),
    );
  }

  Widget _buildMockReview(double w, String name, String comment) {
    return _buildReviewCard(w, name, comment, 5.0, null);
  }

  Widget _buildReviewCard(
      double w, String name, String comment, double rating, String? imageUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.04,
                    ),
                  ),
                ),
                const Icon(Icons.star, color: Color(0xFFF9A825), size: 16),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: w * 0.04,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              comment,
              style: GoogleFonts.nunito(
                color: textSecondary,
                fontSize: w * 0.038,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showScheduleDialog(
      BuildContext context, Map<String, dynamic> walker) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    final scheduled = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    await walkController.scheduleWalk(
      walkerId: walker['id'],
      wandererId: dashCtrl.supabase.auth.currentUser!.id,
      startTime: scheduled,
    );
  }
}

