import 'package:get/get.dart';

class DashboardController extends GetxController {
  // -------------------------------
  // 🎥 CAMERA DATA
  // -------------------------------
  var cameras = <Map<String, dynamic>>[
    {
      'name': 'Front Gate',
      'status': 'Online',
      'feed': 'assets/camera1.png',
    },
    {
      'name': 'Garage',
      'status': 'Offline',
      'feed': 'assets/camera2.png',
    },
    {
      'name': 'Backyard',
      'status': 'Online',
      'feed': 'assets/camera3.png',
    },
  ].obs;

  // -------------------------------
  // ⚠️ ALERT DATA
  // -------------------------------
  var alerts = <Map<String, dynamic>>[
    {
      'msg': 'Motion detected near gate',
      'time': '2m ago',
      'type': 'motion',
    },
    {
      'msg': 'Camera offline: Garage',
      'time': '10m ago',
      'type': 'offline',
    },
    {
      'msg': 'Face not recognized at backyard',
      'time': '30m ago',
      'type': 'face',
    },
  ].obs;

  // -------------------------------
  // 📊 STATS DATA
  // -------------------------------
  var totalCameras = 5.obs;
  var onlineCameras = 3.obs;
  var totalAlertsToday = 4.obs;

  // -------------------------------
  // 🧩 METHODS
  // -------------------------------

  /// Add a new camera dynamically
  void addCamera(String name) {
    if (name.isEmpty) return;

    cameras.add({
      'name': name,
      'status': 'Online',
      'feed': 'assets/default_camera.png', // placeholder image
    });

    totalCameras.value = cameras.length;
    onlineCameras.value += 1;
  }

  /// Add a new alert dynamically
  void addAlert(String message, {String type = 'motion'}) {
    alerts.insert(0, {
      'msg': message,
      'time': 'just now',
      'type': type,
    });

    totalAlertsToday.value += 1;
  }

  /// Toggle camera online/offline
  void toggleCameraStatus(int index) {
    if (index < 0 || index >= cameras.length) return;

    final current = cameras[index];
    final newStatus =
    current['status'] == 'Online' ? 'Offline' : 'Online';

    cameras[index] = {
      ...current,
      'status': newStatus,
    };

    // Update stats
    onlineCameras.value =
        cameras.where((cam) => cam['status'] == 'Online').length;
  }

  /// Clear all alerts
  void clearAlerts() {
    alerts.clear();
    totalAlertsToday.value = 0;
  }
}
