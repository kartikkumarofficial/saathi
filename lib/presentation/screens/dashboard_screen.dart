import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../controllers/dashboard_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/user_controller.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final UserController userController = Get.find<UserController>();

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = Get.height;
    final w = Get.width;

    return Scaffold(
      backgroundColor: const Color(0xFFfdfaf6),


      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7AB7A7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _openAddModal(context, h, w),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:EdgeInsets.only(right: 12,top:25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Greeting
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey, ${userController.userName.value.isNotEmpty ? userController.userName.value : 'Guest User'} 👋',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // const Text(
                      //   'Your smart surveillance dashboard.',
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                    ],
                  ),
                  // Right side: Icons
                  Row(
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset('assets/notifications.png'),
                      ),
                      SizedBox(width: 15),
                      // Profile Icon / Image
                      GestureDetector(
                        onTap: () {
                          final navController = Get.find<NavController>();
                          navController.changeTab(2);
                        },
                        child: Obx( () => CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: userController.profileImageUrl.value.isNotEmpty
                              ? NetworkImage(userController.profileImageUrl.value)
                              : null,
                          child: userController.profileImageUrl.value.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),),
                      ),
                    ],
                  )
                ],
              ),
            ),


            // 👋 Greeting


            SizedBox(height: h * 0.03),

            // 📊 Summary Row
            _buildStatsRow(h, w),

            SizedBox(height: h * 0.03),

            // 🎥 Camera Feeds
            Text(
              "Live Cameras",
              style: GoogleFonts.nunito(
                fontSize: w * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: h * 0.015),

            Obx(() => SizedBox(
              height: h * 0.25,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.cameras.length,
                itemBuilder: (context, index) {
                  final cam = controller.cameras[index];
                  return _cameraCard(cam, h, w);
                },
              ),
            )),

            SizedBox(height: h * 0.035),

            // ⚠️ Alerts
            Text(
              "Recent Alerts",
              style: GoogleFonts.nunito(
                fontSize: w * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: h * 0.015),

            Obx(() => Column(
              children: controller.alerts
                  .map((alert) => _alertTile(alert, h, w))
                  .toList(),
            )),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildStatsRow(double h, double w) {
    return Obx(() {
      final c = controller;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard("Total Cameras", c.totalCameras.value.toString(), Icons.videocam, h, w),
          _statCard("Online", c.onlineCameras.value.toString(), Icons.wifi, h, w),
          _statCard("Alerts Today", c.totalAlertsToday.value.toString(), Icons.warning, h, w),
        ],
      );
    });
  }

  Widget _statCard(String title, String value, IconData icon, double h, double w) {
    return Container(
      width: w * 0.28,
      height: h * 0.12,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.05),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      padding: EdgeInsets.all(w * 0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.teal.shade400, size: w * 0.08),
          SizedBox(height: h * 0.005),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: w * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: w * 0.03,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraCard(Map<String, dynamic> cam, double h, double w) {
    return Container(
      margin: EdgeInsets.only(right: w * 0.04),
      width: w * 0.65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w * 0.05),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.05)),
            child: Image.asset(
              cam['feed'],
              height: h * 0.16,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cam['name'],
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: w * 0.04,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: cam['status'] == 'Online'
                          ? Colors.green
                          : Colors.redAccent,
                      size: w * 0.025,
                    ),
                    SizedBox(width: w * 0.01),
                    Text(
                      cam['status'],
                      style: GoogleFonts.nunito(
                        color: Colors.black54,
                        fontSize: w * 0.035,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _alertTile(Map<String, dynamic> alert, double h, double w) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.015),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.05),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: w * 0.08),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert['msg'],
                    style: GoogleFonts.nunito(
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(height: h * 0.004),
                Text(alert['time'],
                    style: GoogleFonts.nunito(
                      color: Colors.grey,
                      fontSize: w * 0.032,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAddModal(BuildContext context, double h, double w) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.08)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(w * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add New Camera",
                style: GoogleFonts.nunito(
                  fontSize: w * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.02),
              TextField(
                decoration: InputDecoration(
                  labelText: "Camera Name",
                  prefixIcon: Icon(Icons.videocam, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(w * 0.05),
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7AB7A7),
                  minimumSize: Size(double.infinity, h * 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.04),
                  ),
                ),
                child: Text("Add Camera",
                    style: GoogleFonts.nunito(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              SizedBox(height: h * 0.02),
            ],
          ),
        );
      },
    );
  }
}
