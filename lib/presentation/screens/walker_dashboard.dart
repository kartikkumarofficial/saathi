import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:saathi/presentation/screens/walk_session_screen.dart';
import '../../../controllers/walker_controller.dart';


class WalkerDashboardScreen extends StatefulWidget {
  const WalkerDashboardScreen({super.key});

  @override
  State<WalkerDashboardScreen> createState() => _WalkerDashboardScreenState();
}

class _WalkerDashboardScreenState extends State<WalkerDashboardScreen> {
  final WalkerController walkerCtrl = Get.put(WalkerController());
  LatLng? currentLocation;
  GoogleMapController? mapController;

  static const Color _tealGreen = Color(0xFF7AB7A7);
  static const Color _darkText = Color(0xFF4A4E6C);
  static const Color _lightText = Colors.black54;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _getCurrentLocation();
    await walkerCtrl.fetchWalkRequests();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Location Disabled", "Please enable location services");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Permission Denied", "Location permission is required");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Permission Denied", "Enable location in settings");
      return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 🗺️ Map Section
          Container(
            height: Get.height * 0.35,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: currentLocation == null
                  ? const Center(child: CircularProgressIndicator(color: _tealGreen))
                  : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentLocation!,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => mapController = controller,
                markers: {
                  Marker(
                    markerId: const MarkerId('walker'),
                    position: currentLocation!,
                    infoWindow: const InfoWindow(title: "You are here"),
                  ),
                },
              ),
            ),
          ),

          // 🧾 Walk Requests
          Expanded(
            child: Obx(() {
              if (walkerCtrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: _tealGreen));
              }

              if (walkerCtrl.walkRequests.isEmpty) {
                return Center(
                  child: Text(
                    "No walk requests yet 👣",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: _lightText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: walkerCtrl.fetchWalkRequests,
                color: _tealGreen,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: walkerCtrl.walkRequests.length,
                  itemBuilder: (context, index) {
                    final req = walkerCtrl.walkRequests[index];
                    final wandererName = req['wanderer_name'] ?? 'Unknown';
                    final wandererImage = req['wanderer_image'];
                    final start = req['start_location'] ?? 'N/A';
                    final status = req['status'] ?? 'Pending';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      shadowColor: Colors.black12,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage: wandererImage != null
                                      ? NetworkImage(wandererImage)
                                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                                  backgroundColor: Colors.grey[200],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Request from $wandererName",
                                        style: GoogleFonts.nunito(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: _darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Location: $start",
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          color: _lightText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: status == 'accepted'
                                        ? _tealGreen.withOpacity(0.15)
                                        : status == 'rejected'
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Status: ${status.isNotEmpty ? '${status[0].toUpperCase()}${status.substring(1)}' : ''}",
                                    style: GoogleFonts.nunito(
                                      color: status == 'accepted'
                                          ? _tealGreen
                                          : status == 'rejected'
                                          ? Colors.red
                                          : _darkText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    // ✅ ACCEPT BUTTON
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _tealGreen,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () async {
                                        await walkerCtrl.updateRequestStatus(req['id'], 'accepted');
                                        Get.snackbar("Accepted ✅", "You accepted the walk request");

                                        // ✅ Navigate to Session Screen
                                        Get.to(() => WalkSessionScreen(
                                          requestData: req,
                                          walkRequestId: req['id'].toString(),
                                          walkerId: req['walker_id'] ?? '',
                                          wandererId: req['wanderer_id'] ?? '',
                                        ));

                                        walkerCtrl.walkRequests.removeAt(index);
                                      },
                                      child: Text("Accept", style: GoogleFonts.nunito(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 8),

                                    // ❌ REJECT BUTTON
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.redAccent),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () async {
                                        await walkerCtrl.updateRequestStatus(req['id'], 'rejected');
                                        walkerCtrl.walkRequests.removeAt(index);
                                        Get.snackbar("Rejected ❌", "You rejected the walk request");
                                      },
                                      child: Text("Reject", style: GoogleFonts.nunito(color: Colors.redAccent)),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
