import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
      appBar: AppBar(
        title: const Text('Walker Dashboard'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          // 🗺️ Google Map Section
          Container(
            height: Get.height * 0.35,
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade700),
            ),
            child: currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentLocation!,
                  zoom: 15,
                ),
                myLocationEnabled: true,
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

          // 🧾 Walk Requests Section
          Expanded(
            child: Obx(() {
              if (walkerCtrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final requests = walkerCtrl.walkRequests;
              if (requests.isEmpty) {
                return const Center(
                  child: Text(
                    "No new walk requests yet 👣",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.person_pin_circle, color: Colors.green),
                      title: Text("Request from: ${req['wanderer_id']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Start: ${req['start_location'] ?? 'Not specified'}"),
                          Text("End: ${req['end_location'] ?? 'Not specified'}"),
                          Text("Status: ${req['status']}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () async {
                              await walkerCtrl.updateRequestStatus(req['id'], 'accepted');
                              Get.snackbar("Accepted ✅", "You accepted the walk request");
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () async {
                              await walkerCtrl.updateRequestStatus(req['id'], 'rejected');
                              Get.snackbar("Rejected ❌", "You rejected the walk request");
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
