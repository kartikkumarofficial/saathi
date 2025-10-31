// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saathi/presentation/screens/profile/edit_account.dart';
import '../../../controllers/user_controller.dart';
import '../../widgets/fadedDivider.dart';
import '../../widgets/profile_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    userController.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: userController.fetchUserProfile,
        child: Obx(() {
          if (userController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            children: [
              const SizedBox(height: 35),

              // 👤 Profile Avatar
              Center(
                child: CircleAvatar(
                  radius: Get.width * 0.18,
                  backgroundImage: userController.profileImageUrl.value.isNotEmpty
                      ? NetworkImage(userController.profileImageUrl.value)
                      : const AssetImage('assets/default_profile.png')
                  as ImageProvider,
                ),
              ),

              const SizedBox(height: 12),

              // 🧑‍💼 Name & Email
              Center(
                child: Text(
                  userController.userName.value,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Center(
                child: Text(
                  userController.email.value,
                  style: GoogleFonts.barlow(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 25),
              FadedDividerHorizontal(),

              // ⚙️ Modern Role Switch
              const SizedBox(height: 25),
              Center(child: _buildRoleSlider()),

              const SizedBox(height: 25),
              FadedDividerHorizontal(),

              // 📊 Stats
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard("Journeys",
                      userController.journeysTaken.value.toString()),
                  _buildStatCard(
                      "Rating", userController.rating.value.toStringAsFixed(1)),
                  _buildStatCard("Miles",
                      userController.milesTraveled.value.toInt().toString()),
                ],
              ),

              const SizedBox(height: 25),
              FadedDividerHorizontal(),

              // 💬 About Me
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "About Me",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userController.about.value.isNotEmpty
                          ? userController.about.value
                          : "No description added yet.",
                      style: GoogleFonts.barlow(
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              FadedDividerHorizontal(),

              // ⚙️ Options
              ProfileTile(
                icon: Icons.settings,
                label: "Edit Account Details",
                onTap: () {
                  Get.to(EditAccountPage());
                },
              ),
              ProfileTile(
                icon: Icons.help_outline,
                label: "Help & Support",
                onTap: () {},
              ),
              ProfileTile(
                icon: Icons.card_giftcard,
                label: "Refer & Earn",
                onTap: () {},
              ),

              const SizedBox(height: 15),

              // 🚪 Logout
              TextButton.icon(
                onPressed: () => userController.logOut(),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),

              Center(
                child: Text(
                  "v1.0.0 • Saathi",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// 🌈 Modern Role Slider Widget
  Widget _buildRoleSlider() {
    final isWalker = userController.role.value == 'walker';
    return GestureDetector(
      onTap: () {
        final newRole = isWalker ? 'wanderer' : 'walker';
        userController.updateRole(newRole);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: Get.width * 0.75,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated Sliding Circle
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment:
              isWalker ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: Get.width * 0.35,
                height: 45,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isWalker
                        ? [Colors.tealAccent.shade700, Colors.teal]
                        : [Colors.orangeAccent.shade200, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: Text(
                  isWalker ? "Walker" : "Wanderer",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Text labels in background
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Wanderer",
                      style: GoogleFonts.barlow(
                        fontSize: 15,
                        color:
                        isWalker ? Colors.grey.shade500 : Colors.grey[900],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Walker",
                      style: GoogleFonts.barlow(
                        fontSize: 15,
                        color:
                        isWalker ? Colors.grey[900] : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.barlow(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
