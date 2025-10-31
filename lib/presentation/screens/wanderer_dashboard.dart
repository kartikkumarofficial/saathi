import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/wanderer_dashboard_controller.dart';

class WandererDashboardGoogle extends StatelessWidget {
  const WandererDashboardGoogle({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(WandererDashboardController());
    final h = Get.height;
    final w = Get.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   title: const Text('Explore Wanderers', style: TextStyle(color: Colors.white)),
      //   centerTitle: true,
      //   backgroundColor: Colors.green.shade700.withOpacity(0.8),
      //   elevation: 0,
      // ),
      body: Stack(
        children: [
          // Map
          Obx(() {
            if (c.currentLatLng.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return GoogleMap(
              onMapCreated: c.onMapCreated,
              initialCameraPosition: CameraPosition(
                target: c.currentLatLng.value!,
                zoom: 14,
              ),
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              markers: c.markers.toSet(),
            );
          }),

          // Floating recenter button
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 12,
            child: FloatingActionButton(
              backgroundColor: Colors.green.shade700,
              onPressed: c.recenter,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Draggable bottom sheet
          Obx(() {
            if (c.walkers.isEmpty) {
              return const SizedBox();
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.25,
              minChildSize: 0.25,
              maxChildSize: 0.65,
              builder: (context, scrollController) {
                return Container(
                  width: w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Nearby Wanderers",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: w * 0.045,
                              color: Colors.green.shade800)),
                      // const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: c.walkers.length,
                          itemBuilder: (context, i) {
                            final wData = c.walkers[i];
                            return GestureDetector(
                              onTap: () => c.onMarkerTapped(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(
                                    horizontal: w * 0.04, vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    colors: i == c.selectedIndex
                                        ? [Colors.green.shade100, Colors.green.shade50]
                                        : [Colors.white, Colors.grey.shade100],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: w * 0.08,
                                      backgroundImage: NetworkImage(
                                        wData['profile_image'] ??
                                            'https://via.placeholder.com/100',
                                      ),
                                    ),
                                    SizedBox(width: w * 0.04),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            wData['full_name'] ?? 'Unknown',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: w * 0.04),
                                          ),
                                          SizedBox(height: h * 0.005),
                                          Text(
                                            "⭐ ${wData['rating'] ?? 4.8}",
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontSize: w * 0.035,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () => Get.snackbar(
                                          'Request Sent', 'Wanderer notified!'),
                                      child: const Text("Request"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
