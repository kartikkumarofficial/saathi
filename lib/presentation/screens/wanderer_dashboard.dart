// lib/presentation/screens/wanderer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/wanderer_dashboard_controller.dart';
import 'walker_details_screen.dart';

class WandererDashboard extends StatelessWidget {
  const WandererDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(WandererDashboardController());
    final w = Get.width;
    final h = Get.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map
          Obx(() {
            if (c.currentLatLng.value == null) {
              return const Center(child: CircularProgressIndicator());
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
              backgroundColor: Colors.green.shade700,
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
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    'No nearby walkers found — make sure your location is enabled and you have active walkers in DB.',
                    style: TextStyle(color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // DraggableScrollableSheet to show list / selected
            return DraggableScrollableSheet(
              initialChildSize: 0.22,
              minChildSize: 0.12,
              maxChildSize: 0.8,
              builder: (context, sc) {
                final selected = c.selectedWalker.value;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
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
        const SizedBox(height: 10),
        Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey[350], borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 8),
        Text('Nearby Walkers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: w * 0.045, color: Colors.green.shade800)),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.separated(
            controller: sc,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: c.walkers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final wData = c.walkers[i];
              final rating = wData['rating'] ?? 4.8;
              return ListTile(
                leading: CircleAvatar(backgroundImage: wData['profile_image'] != null ? NetworkImage(wData['profile_image']) : null, radius: 26),
                title: Text(wData['full_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(wData['bio'] ?? 'Available for walks'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(rating.toString()),
                    ]),
                  ],
                ),
                onTap: () {
                  // tap a list item => center map & select
                  c.selectedWalker.value = wData;
                  c.setMarkers();
                  final lat = (wData['location_lat'] as num?)?.toDouble();
                  final lng = (wData['location_lng'] as num?)?.toDouble();
                  if (lat != null && lng != null) {
                    c.mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));
                  }
                },
              );
            },
          ),
        )
      ],
    );
  }

  Widget _selectedPreview(WandererDashboardController c, Map<String, dynamic> selected, ScrollController sc, double w, double h) {
    return SingleChildScrollView(
      controller: sc,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey[350], borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(radius: 36, backgroundImage: selected['profile_image'] != null ? NetworkImage(selected['profile_image']) : null),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(selected['full_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text("${selected['rating'] ?? 4.8}"),
                    const SizedBox(width: 12),
                    if (selected['is_verified'] == true)
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)), child: const Text('Verified', style: TextStyle(color: Colors.green)))
                  ]),
                ]),
              ),
              IconButton(
                onPressed: () {
                  // clear selection - goes back to list
                  c.selectedWalker.value = null;
                  c.setMarkers();
                },
                icon: const Icon(Icons.keyboard_arrow_down),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(selected['bio'] ?? 'No bio available'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => c.showWalkerDetailsBottomSheet(selected), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700), child: const Text('Open profile'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: () async {
              // schedule quick flow
              DateTime? date = await showDatePicker(context: Get.context!, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
              if (date == null) return;
              TimeOfDay? time = await showTimePicker(context: Get.context!, initialTime: TimeOfDay.now());
              if (time == null) return;
              final scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
              await c.scheduleWalk(selected['id']?.toString() ?? '', scheduled);
            }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade500), child: const Text('Schedule'))),
          ]),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
