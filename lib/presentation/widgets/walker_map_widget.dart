import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/services/location_service.dart';

class WalkerMapWidget extends StatefulWidget {
  const WalkerMapWidget({super.key});

  @override
  State<WalkerMapWidget> createState() => _WalkerMapWidgetState();
}

class _WalkerMapWidgetState extends State<WalkerMapWidget> {
  GoogleMapController? mapController;
  LatLng? currentPosition;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    Position? pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      setState(() {
        currentPosition = LatLng(pos.latitude, pos.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: currentPosition!,
        zoom: 16,
      ),
      markers: {
        Marker(
          markerId: const MarkerId("walker"),
          position: currentPosition!,
          infoWindow: const InfoWindow(title: "You are here"),
        ),
      },
      onMapCreated: (controller) => mapController = controller,
    );
  }
}
