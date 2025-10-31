// lib/controllers/wanderer_dashboard_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:saathi/controllers/schedule_walk_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../presentation/screens/walker_details_screen.dart';

class WandererDashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  GoogleMapController? mapController;
  final walkController = Get.find<ScheduleWalkController>();
  final Rxn<LatLng> currentLatLng = Rxn<LatLng>();

  // reactive collections
  var walkers = <Map<String, dynamic>>[].obs;
  var markers = <Marker>[].obs;

  // selected walker shown in bottomsheet
  final Rxn<Map<String, dynamic>> selectedWalker = Rxn<Map<String, dynamic>>();
  String? lastTappedMarkerId;

  // debug helper
  void debug(String msg) => debugPrint('[WDC] $msg');

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    debug('Initializing dashboard...');
    await _getCurrentLocation();
    await fetchWalkers();
  }

  /// get current device location
  Future<void> _getCurrentLocation() async {
    try {
      debug('Requesting location services status...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debug('Location services disabled.');
        // still continue; use fallback later
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        debug('Location permission denied forever.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      currentLatLng.value = LatLng(pos.latitude, pos.longitude);
      debug('Location obtained: ${pos.latitude}, ${pos.longitude}');
    } catch (e, st) {
      debug('Location error: $e\n$st');
    }
  }

  /// fetch walkers from Supabase - intentionally doesn't request a `rating` field from users
  /// to avoid "column does not exist" errors. Rating is shown as fallback in UI.
  Future<void> fetchWalkers() async {
    try {
      debug('Fetching walkers from Supabase...');
      final res = await supabase
          .from('users')
          .select('id, full_name, profile_image, bio, language, interests, is_verified, location_lat, location_lng, role, status')
          .eq('role', 'walker')
          .eq('status', 'active')
          .limit(100);

      if (res == null) {
        debug('Supabase returned null for users.');
        walkers.clear();
        markers.value = [];
        return;
      }

      if (res is List) {
        walkers.value = res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        debug('Fetched ${walkers.length} walkers.');
      } else {
        debug('Unexpected response type from supabase users select: ${res.runtimeType}');
        walkers.clear();
      }

      setMarkers();
    } catch (e, st) {
      debug('Fetch error: $e\n$st');
      Get.snackbar('Error', 'Failed to fetch walkers: $e', snackPosition: SnackPosition.BOTTOM);
      walkers.clear();
      markers.value = [];
    }
  }

  /// create markers for user + walkers
  void setMarkers() {
    final newMarkers = <Marker>[];

    if (currentLatLng.value != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId('me'),
        position: currentLatLng.value!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'You are here'),
      ));
    }

    for (int i = 0; i < walkers.length; i++) {
      final w = walkers[i];
      final lat = (w['location_lat'] as num?)?.toDouble();
      final lng = (w['location_lng'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      final markerId = 'walker_$i';
      newMarkers.add(Marker(
        markerId: MarkerId(markerId),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          selectedWalker.value == w ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        onTap: () => onMarkerTapped(markerId, w),
      ));
    }

    markers.value = newMarkers;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // if we have a location, animate camera there
    if (currentLatLng.value != null) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng.value!, 14));
    }
  }

  /// marker tap: first tap shows a small popup + sets selectedWalker
  /// second tap (same marker) opens full details bottom sheet / page
  void onMarkerTapped(String markerId, Map<String, dynamic> walker) {
    debug('Marker tapped: $markerId');

    if (lastTappedMarkerId == markerId) {
      // second tap -> open bottom sheet details
      showWalkerDetailsBottomSheet(walker);
      return;
    }

    lastTappedMarkerId = markerId;
    selectedWalker.value = walker;
    setMarkers();

    final lat = (walker['location_lat'] as num?)?.toDouble();
    final lng = (walker['location_lng'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));
    }

    _showMarkerInfoPopup(walker);
  }

  void _showMarkerInfoPopup(Map<String, dynamic> walker) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: walker['profile_image'] != null
                    ? NetworkImage(walker['profile_image'])
                    : const AssetImage('assets/avatar.png') as ImageProvider,
              ),
              const SizedBox(height: 8),
              Text(walker['full_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(walker['bio'] ?? 'Available for walks', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back(); // close dialog
                    },
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      showWalkerDetailsBottomSheet(walker);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                    child: const Text('View profile'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// shows a draggable bottom sheet containing full short info + actions
  void showWalkerDetailsBottomSheet(Map<String, dynamic> walker) {
    // set selectedWalker
    selectedWalker.value = walker;
    setMarkers();

    Get.bottomSheet(
      DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.36,
        minChildSize: 0.18,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: walker['profile_image'] != null
                            ? NetworkImage(walker['profile_image'])
                            : const AssetImage('assets/avatar.png') as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(walker['full_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 6),
                                Text("${(walker['rating'] ?? '4.8')}"),
                                const SizedBox(width: 12),
                                if (walker['is_verified'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                                    child: const Text('Verified', style: TextStyle(color: Colors.green)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(walker['bio'] ?? 'No bio available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Get.back(); // close sheet
                      Get.to(() => WalkerDetailsScreen(walker: walker), arguments: walker);
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: Colors.green.shade700),
                    child: const Text('View full profile'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // open schedule dialog right from sheet
                      DateTime? date = await showDatePicker(
                        context: Get.context!,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date == null) return;
                      TimeOfDay? time = await showTimePicker(context: Get.context!, initialTime: TimeOfDay.now());
                      if (time == null) return;
                      final scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);


                      // schedule via controller method
                      await walkController.scheduleWalk(
                        walkerId: walker['id']?.toString() ?? '',
                        wandererId: Supabase.instance.client.auth.currentUser?.id ?? '',
                        startTime: scheduled,
                      );


                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: Colors.green.shade500),
                    child: const Text('Schedule a walk'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  /// recenter map to user
  void recenter() {
    if (currentLatLng.value == null || mapController == null) return;
    mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng.value!, 15));
  }
}
