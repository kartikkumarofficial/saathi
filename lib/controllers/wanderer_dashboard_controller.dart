import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WandererDashboardController extends GetxController {
  final supabase = Supabase.instance.client;

  GoogleMapController? mapController;
  final Rxn<LatLng> currentLatLng = Rxn<LatLng>();
  var walkers = <Map<String, dynamic>>[].obs;
  var markers = <Marker>[].obs;
  int? selectedIndex;

  @override
  void onInit() {
    super.onInit();
    _initLocationAndData();
  }

  Future<void> _initLocationAndData() async {
    await _getCurrentLocation();
    await fetchWalkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
          locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.best));

      currentLatLng.value = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  Future<void> fetchWalkers() async {
    try {
      final response = await supabase
          .from('users')
          .select('id, full_name, profile_image, location_lat, location_lng, rating')
          .eq('role', 'walker')
          .eq('status', 'active');

      walkers.value = (response as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      _setMarkers();
    } catch (e) {
      debugPrint("Fetch error: $e");
      Get.snackbar('Error', 'Failed to fetch wanderers');
    }
  }

  void _setMarkers() {
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

      newMarkers.add(Marker(
        markerId: MarkerId('walker_$i'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          i == selectedIndex ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        onTap: () => onMarkerTapped(i),
      ));
    }

    markers.value = newMarkers;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onMarkerTapped(int index) {
    selectedIndex = index;
    _setMarkers();
    final w = walkers[index];
    final lat = (w['location_lat'] as num?)?.toDouble();
    final lng = (w['location_lng'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16),
      );
    }
  }

  void recenter() {
    if (currentLatLng.value != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng.value!, 15),
      );
    }
  }

  /// 📨 Send request to a walker
  Future<void> sendRequest(Map<String, dynamic> walker) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "Please log in to send requests");
        return;
      }

      await supabase.from('walker_requests').insert({
        'sender_id': currentUser.id,
        'receiver_id': walker['id'],
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        'Request Sent ✅',
        'Your request has been sent to ${walker['full_name']}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      debugPrint("Request error: $e");
      Get.snackbar('Error', 'Failed to send request');
    }
  }
}
