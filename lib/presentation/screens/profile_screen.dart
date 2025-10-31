import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/profile_controller.dart';
import '../widgets/fadedDivider.dart';
import '../widgets/profile_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: controller.fetchUserProfile,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.only(top: 45),
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: Get.width * 0.18,
                    backgroundImage: controller.profileImageUrl.value.isNotEmpty
                        ? NetworkImage(controller.profileImageUrl.value)
                        : const AssetImage('assets/default_profile.png')
                    as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  controller.userName.value,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  controller.email.value,
                  style: GoogleFonts.barlow(color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 20),

              /// 🌈 Elegant Role Switcher
              Center(
                child: RoleToggle(
                  currentRole: controller.role.value,
                  onToggle: controller.toggleRole,
                ),
              ),

              const SizedBox(height: 25),
              FadedDividerHorizontal(),

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "About Me",
                      style: GoogleFonts.barlow(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.about.value.isNotEmpty
                          ? controller.about.value
                          : "No description added yet.",
                      style: GoogleFonts.barlow(
                        color: Colors.grey[700],
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.02),
                child: Column(
                  children: [
                    ProfileTile(
                      icon: Icons.settings,
                      label: "Edit Account Details",
                      onTap: () async {
                        final result = await Get.toNamed('/editAccount');
                        if (result == true) {
                          controller.fetchUserProfile();
                        }
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
                  ],
                ),
              ),

              TextButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              Center(
                child: Text(
                  "v1.0.0 • AidKRIYA",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// 🎚️ Custom Slider Toggle Widget
class RoleToggle extends StatefulWidget {
  final String currentRole;
  final VoidCallback onToggle;

  const RoleToggle({super.key, required this.currentRole, required this.onToggle});

  @override
  State<RoleToggle> createState() => _RoleToggleState();
}

class _RoleToggleState extends State<RoleToggle> {
  bool get isWalker => widget.currentRole == 'walker';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        height: 48,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.deepPurple.shade50,
          border: Border.all(color: Colors.deepPurple, width: 1.5),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: isWalker ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: Container(
                height: 48,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Walker",
                      style: GoogleFonts.poppins(
                        color: isWalker ? Colors.white : Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Wanderer",
                      style: GoogleFonts.poppins(
                        color: !isWalker ? Colors.white : Colors.deepPurple,
                        fontWeight: FontWeight.w600,
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
}
