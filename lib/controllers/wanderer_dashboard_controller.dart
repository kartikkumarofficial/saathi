import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final Color primaryColor = const Color(0xFF7AB7A7);
  final Color textPrimary = Colors.black87;
  final Color textSecondary = Colors.black54;

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

  /// fetch walkers from Supabase
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
    if (currentLatLng.value != null) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng.value!, 14));
    }
  }

  /// marker tap: first tap shows a small popup + sets selectedWalker
  /// second tap (same marker) opens full details bottom sheet / page
  void onMarkerTapped(String markerId, Map<String, dynamic> walker) {
    debug('Marker tapped: $markerId');

    if (lastTappedMarkerId == markerId) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemedAvatar(walker['profile_image'], 28),
              const SizedBox(height: 12),
              Text(
                walker['full_name'] ?? 'Unknown',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                walker['bio'] ?? 'Available for walks',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(color: textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Close',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      showWalkerDetailsBottomSheet(walker);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'View profile',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                    ),
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
    selectedWalker.value = walker;
    setMarkers();

    Get.bottomSheet(
      DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildThemedAvatar(walker['profile_image'], 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              walker['full_name'] ?? 'Unknown',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFF9A825), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  "${(walker['rating'] ?? '4.8')}",
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (walker['is_verified'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Verified',
                                      style: GoogleFonts.nunito(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    walker['bio'] ?? 'No bio available',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildThemedButton(
                    onPressed: () {
                      Get.back(); // close sheet
                      Get.to(() => WalkerDetailsScreen(walker: walker), arguments: walker);
                    },
                    label: 'View Full Profile',
                    icon: Icons.person_search_outlined,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 10),
                  _buildThemedButton(
                    onPressed: () => _showScheduleDialog(context, walker),
                    label: 'Schedule a Walk',
                    icon: Icons.calendar_today_outlined,
                    color: Colors.white,
                    textColor: primaryColor,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildThemedButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: Size(Get.width, Get.height * 0.065),
        textStyle: GoogleFonts.nunito(
          fontSize: Get.width * 0.042,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Get.height * 0.02),
          side: BorderSide(color: primaryColor, width: 1.5),
        ),
        elevation: 5,
      ),
    );
  }

  Widget _buildThemedAvatar(String? imageUrl, double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
      child: imageUrl == null
          ? Icon(
        Icons.person,
        size: radius,
        color: Colors.grey.shade400,
      )
          : null,
    );
  }

  Future<void> _showScheduleDialog(BuildContext context, Map<String, dynamic> walker) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    final scheduled = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    await walkController.scheduleWalk(
      walkerId: walker['id']?.toString() ?? '',
      wandererId: Supabase.instance.client.auth.currentUser?.id ?? '',
      startTime: scheduled,
    );
  }

  /// recenter map to user
  void recenter() {
    if (currentLatLng.value == null || mapController == null) return;
    mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng.value!, 15));
  }
}

