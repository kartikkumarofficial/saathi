import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WandererDashboardController extends GetxController {
  final supabase = Supabase.instance.client;

  // Google Map controller
  GoogleMapController? mapController;

  // Reactive current user location
  final Rxn<LatLng> currentLatLng = Rxn<LatLng>();

  // Reactive walker list
  var walkers = <Map<String, dynamic>>[].obs;

  // Reactive markers list
  var markers = <Marker>[].obs;

  // Currently selected marker index
  int? selectedIndex;

  // Loading state
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    isLoading.value = true;
    await _getCurrentLocation();
    await fetchWalkers();
    isLoading.value = false;
  }

  /// 📍 Get current location of the user
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location Disabled', 'Please enable location services');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Permission Denied', 'Location permission is required');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission Permanently Denied',
            'Enable location permission from settings');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.high),
      );

      currentLatLng.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
    }
  }

  /// 🧭 Fetch walker data from Supabase
  Future<void> fetchWalkers() async {
    try {
      isLoading.value = true;

      // Fetch all walkers (add dummy lat/lng if you’re testing)
      final response = await supabase
          .from('users')
          .select('id, full_name, profile_image, location_lat, location_lng, role')
          .eq('role', 'walker');

      walkers.value =
          (response as List).map((e) => Map<String, dynamic>.from(e)).toList();

      _setMarkers();
    } catch (e) {
      debugPrint("❌ Failed to fetch walkers: $e");
      Get.snackbar('Error', 'Failed to fetch walkers');
    } finally {
      isLoading.value = false;
    }
  }

  /// 🗺️ Setup markers on the map (walkers + user)
  void _setMarkers() {
    final newMarkers = <Marker>[];

    // Current user location marker
    if (currentLatLng.value != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('me'),
          position: currentLatLng.value!,
          icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }

    // Add walker markers
    for (int i = 0; i < walkers.length; i++) {
      final walker = walkers[i];
      final lat = (walker['location_lat'] as num?)?.toDouble();
      final lng = (walker['location_lng'] as num?)?.toDouble();

      if (lat == null || lng == null) continue;

      newMarkers.add(
        Marker(
          markerId: MarkerId('walker_$i'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == selectedIndex
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: walker['full_name'] ?? 'Unknown',
          ),
          onTap: () => onMarkerTapped(i),
        ),
      );
    }

    markers.value = newMarkers;
  }

  /// 📍 Handle marker tap and zoom
  void onMarkerTapped(int index) {
    selectedIndex = index;
    _setMarkers();

    final walker = walkers[index];
    final lat = (walker['location_lat'] as num?)?.toDouble();
    final lng = (walker['location_lng'] as num?)?.toDouble();

    if (lat != null && lng != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16),
      );
    }
  }

  /// 🗺️ Called when map is created
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// 🔁 Recenter map on user's current location
  void recenter() {
    if (currentLatLng.value != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng.value!, 15),
      );
    }
  }
}
