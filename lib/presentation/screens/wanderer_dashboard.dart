// lib/presentation/screens/wanderer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/schedule_walk_controller.dart';
import '../../controllers/wanderer_dashboard_controller.dart';
import 'walker_details_screen.dart';

class WandererDashboard extends StatelessWidget {
  const WandererDashboard({super.key});

  static const Color _tealGreen = Color(0xFF7AB7A7);
  static const Color _darkText = Color(0xFF4A4E6C);
  static const Color _lightText = Colors.black54;

  @override
  Widget build(BuildContext context) {
    final WandererDashboardController c = Get.find<WandererDashboardController>();
    final w = Get.width;
    final h = Get.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map
          Obx(() {
            if (c.currentLatLng.value == null) {
              return const Center(child: CircularProgressIndicator(color: _tealGreen));
            }
            return GoogleMap(
              onMapCreated: c.onMapCreated,
              initialCameraPosition: CameraPosition(target: c.currentLatLng.value!, zoom: 14),
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              markers: c.markers.map((m) => m).toSet(),
            );
          }),

          // Recenter
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 12,
            child: FloatingActionButton(
              backgroundColor: _tealGreen,
              onPressed: c.recenter,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Bottom persistent draggable sheet that either shows a list of walkers or selected walker details.
          Obx(() {
            if (c.walkers.isEmpty) {
              // show small hint when no walkers or still loading
              return Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: Text(
                    'Searching for nearby walkers...',
                    style: GoogleFonts.nunito(color: _darkText),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // DraggableScrollableSheet to show list / selected
            return DraggableScrollableSheet(
              initialChildSize: 0.30,
              minChildSize: 0.12,
              maxChildSize: 0.8,
              builder: (context, sc) {
                final selected = c.selectedWalker.value;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, spreadRadius: 2)],
                  ),
                  child: selected == null
                      ? _walkerListView(c, sc, w, h)
                      : _selectedPreview(c, selected, sc, w, h),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _walkerListView(WandererDashboardController c, ScrollController sc, double w, double h) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
        const SizedBox(height: 12),
        Text(
          'Nearby Walkers',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: w * 0.05,
            color: _darkText,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            controller: sc,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: c.walkers.length,
            itemBuilder: (context, i) {
              final wData = c.walkers[i];
              final rating = wData['rating'] ?? 4.8;
              return Card(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: wData['profile_image'] != null
                        ? NetworkImage(wData['profile_image'])
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                  title: Text(
                    wData['full_name'] ?? 'Unknown',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 17, color: _darkText),
                  ),
                  subtitle: Text(
                    wData['bio'] ?? 'Available for walks',
                    style: GoogleFonts.nunito(color: _lightText, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  onTap: () {
                    c.selectedWalker.value = wData;
                    c.setMarkers();
                    final lat = (wData['location_lat'] as num?)?.toDouble();
                    final lng = (wData['location_lng'] as num?)?.toDouble();
                    if (lat != null && lng != null) {
                      c.mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));
                    }
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _selectedPreview(
      WandererDashboardController c,
      Map<String, dynamic> selected,
      ScrollController sc,
      double w,
      double h,
      ) {
    final walkController = Get.find<ScheduleWalkController>();

    return SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: selected['profile_image'] != null
                    ? NetworkImage(selected['profile_image'])
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected['full_name'] ?? 'Unknown',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 20, color: _darkText),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        "${selected['rating'] ?? 4.8}",
                        style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 12),
                      if (selected['is_verified'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7AB7A7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Verified',
                            style: GoogleFonts.nunito(color: _tealGreen, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ]),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  c.selectedWalker.value = null;
                  c.setMarkers();
                },
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            selected['bio'] ?? 'No bio available',
            style: GoogleFonts.nunito(color: _lightText, fontSize: 15, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // tap a list item => center map & select
                    c.showWalkerDetailsBottomSheet(selected);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _tealGreen,
                    side: const BorderSide(color: _tealGreen, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Open Profile',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    _showScheduleDialog(Get.context!, walkController, selected, c.supabase.auth.currentUser!.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tealGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Schedule Walk',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(
      BuildContext context,
      ScheduleWalkController walkController,
      Map<String, dynamic> walker,
      String wandererId,
      ) async {
    final ThemeData pickerTheme = ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: _tealGreen,
        onPrimary: Colors.white,
        onSurface: _darkText,
      ),
      dialogBackgroundColor: Colors.white,
      buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
    );

    // 🗓 Pick date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(data: pickerTheme, child: child!),
    );
    if (selectedDate == null) return;

    // ⏰ Pick time
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(data: pickerTheme, child: child!),
    );
    if (selectedTime == null) return;

    final scheduled = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // ✅ Use walkController instead of dashboard controller
    await walkController.scheduleWalk(
      walkerId: walker['id'].toString(),
      wandererId: wandererId,
      startTime: scheduled,
    );
  }
}