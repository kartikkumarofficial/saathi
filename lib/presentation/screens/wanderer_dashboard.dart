// FILE: lib/presentation/screens/wanderer_dashboard.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/walker_card.dart';


class WandererDashboard extends StatefulWidget {
  const WandererDashboard({super.key});

  @override
  State<WandererDashboard> createState() => _WandererDashboardState();
}

class _WandererDashboardState extends State<WandererDashboard> with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  // map controller + state
  final MapController _mapController = MapController();
  LatLng? _currentLatLng;
  bool _mapReady = false;

  // walkers
  List<Map<String, dynamic>> walkers = [];
  bool isLoading = true;
  int? selectedIndex;

  // sheet controller
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _ensureLocationAndLoad();
  }

  Future<void> _ensureLocationAndLoad() async {
    await _requestLocationPermission();
    await _getCurrentLocation();
    await fetchWalkers();
    // small delay to let map widgets init
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _mapReady = true);
    });
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Location required',
        'Please enable location from settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _currentLatLng = LatLng(pos.latitude, pos.longitude);
      // animate map to location (if map mounted)
      if (_mapController.ready) {
        _mapController.move(_currentLatLng!, 15.0);
      }
      setState(() {});
    } catch (e) {
      print('Could not get location: $e');
    }
  }

  Future<void> fetchWalkers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final res = await supabase
          .from('users')
          .select('id, full_name, profile_image, location_lat, location_long, is_verified')
          .eq('role', 'walker')
          .limit(30);
      // normalize into a typed list
      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(res ?? []);
      walkers = list;
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch walkers: $e', backgroundColor: Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // move camera to a LatLng and optionally open sheet with index
  void _focusOnWalker(int index, {bool openSheet = true}) {
    final row = walkers[index];
    final double? lat = (row['location_lat'] is num) ? (row['location_lat'] as num).toDouble() : null;
    final double? lng = (row['location_long'] is num) ? (row['location_long'] as num).toDouble() : null;
    if (lat != null && lng != null) {
      final dest = LatLng(lat, lng);
      _mapController.move(dest, 16.0);
    }
    setState(() => selectedIndex = index);
    if (openSheet) {
      // expand sheet to show full list / selected item
      _sheetController.animateTo(0.45, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
      // small delay to allow sheet settle then scroll to index (we'll ensure list scrolls)
    }
  }

  // center on user
  void _centerOnUser() {
    if (_currentLatLng != null && _mapController.ready) {
      _mapController.move(_currentLatLng!, 15.0);
    } else {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = Get.height;
    final w = Get.width;

    // tile layer url (OpenStreetMap)
    const tileUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            // Map area (top half)
            SizedBox(
              height: h * 0.55,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(23.8103, 90.4125),
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(23.8103, 90.4125),
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),

            ),

            // top header overlay
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hello, Wanderer', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                                Text('Find friendly Walkers near you', style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[700])),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _centerOnUser,
                            icon: const Icon(Icons.my_location_rounded, color: Color(0xFF7C83FD)),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Draggable bottom sheet with list
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.25,
              minChildSize: 0.18,
              maxChildSize: 0.70,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      // top drag handle
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                      ),

                      // header row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nearby Walkers', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
                            Text('${walkers.length} nearby', style: GoogleFonts.nunito(color: Colors.grey[600])),
                          ],
                        ),
                      ),

                      // content list
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          controller: scrollController,
                          itemCount: walkers.length,
                          itemBuilder: (context, index) {
                            final w = walkers[index];
                            final isSel = selectedIndex == index;
                            final name = (w['full_name'] ?? 'Unknown') as String;
                            final img = (w['profile_image'] ?? 'https://via.placeholder.com/150') as String;
                            final distanceStr = _calcDistanceString(w);
                            final rating = (w['rating'] is num) ? (w['rating'] as num).toDouble() : 4.8;

                            return GestureDetector(
                              onTap: () {
                                _focusOnWalker(index, openSheet: true);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF7C83FD).withOpacity(0.08) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSel ? const Color(0xFF7C83FD) : Colors.grey.shade200),
                                  boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.02), blurRadius: 6)],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(radius: 28, backgroundImage: NetworkImage(img)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(distanceStr, style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 18),
                                            const SizedBox(width: 4),
                                            Text(rating.toStringAsFixed(1), style: GoogleFonts.nunito()),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Create Request flow or view profile
                                            Get.snackbar('Request', 'Request Walker tapped', backgroundColor: Colors.white);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF7C83FD),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          child: const Text('Request'),
                                        ),
                                      ],
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
            ),
          ],
        ),
      ),
    );
  }

  // simple helper: calculate approximate distance from user's current location if possible
  String _calcDistanceString(Map<String, dynamic> row) {
    try {
      if (_currentLatLng == null) return 'Distance unknown';
      final lat = (row['location_lat'] is num) ? (row['location_lat'] as num).toDouble() : null;
      final lng = (row['location_long'] is num) ? (row['location_long'] as num).toDouble() : null;
      if (lat == null || lng == null) return 'Distance unknown';

      final Distance distance = Distance();
      final double meters = distance.as(LengthUnit.Meter, _currentLatLng!, LatLng(lat, lng));
      if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    } catch (e) {
      return 'Distance unknown';
    }
  }
}

// tiny convenience extension to mapIndexed (if not using collection package)
extension _IndexedIterable<E> on Iterable<E> {
  Iterable<T?> mapIndexed<T>(T? Function(int, E) f) sync* {
    var i = 0;
    for (final e in this) {
      yield f(i++, e);
    }
  }
}
