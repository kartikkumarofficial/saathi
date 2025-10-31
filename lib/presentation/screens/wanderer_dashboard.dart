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
    final h = Get.height;
    final w = Get.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          /// 🌍 Google Map
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

          /// 🎯 Recenter Button
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 12,
            child: FloatingActionButton(
              backgroundColor: Colors.green.shade700,
              onPressed: c.recenter,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          /// 📜 Draggable Bottom Sheet (List of Walkers)
          Obx(() {
            if (c.walkers.isEmpty) {
              return const SizedBox();
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.1,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: h * 0.01),
                      Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(height: h * 0.015),
                      Text(
                        "Nearby Walkers",
                        style: TextStyle(
                          fontSize: w * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.only(bottom: h * 0.02),
                          itemCount: c.walkers.length,
                          itemBuilder: (context, i) {
                            final wData = c.walkers[i];
                            final isSelected =
                                c.selectedIndex.value == i; // ✅ fixed reactive index

                            return GestureDetector(
                              onTap: () {
                                c.onMarkerTapped(i);
                                c.openWalkerDetails(wData);
                              },

                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: EdgeInsets.symmetric(
                                    horizontal: w * 0.04, vertical: 6),
                                padding: EdgeInsets.all(w * 0.04),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    colors: isSelected
                                        ? [Colors.green.shade100, Colors.white]
                                        : [Colors.white, Colors.grey.shade100],
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 6,
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
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            wData['full_name'] ?? 'Unknown',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: w * 0.042,
                                            ),
                                          ),
                                          SizedBox(height: h * 0.004),
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 18),
                                              SizedBox(width: w * 0.01),
                                              Text(
                                                "${wData['rating'] ?? 4.8}",
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontSize: w * 0.038,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
