import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../widgets/primary_button.dart';
import '../widgets/role_card.dart';
import 'auth/login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final AuthController authController = Get.find<AuthController>();
  String? selectedRole; // tracks which role user selected

  void onRoleTap(String role) {
    setState(() {
      selectedRole = role;
    });
    // Update local user role safely using copyWith
    if (authController.user.value != null) {
      authController.user.value =
          authController.user.value!.copyWith(role: role);
    }
  }


  @override
  Widget build(BuildContext context) {
    final h = Get.height;
    final w = Get.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.08, vertical: h * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: h * 0.05),
            Image.asset('assets/images/eldercare_logo.png', height: h * 0.15),
            SizedBox(height: h * 0.03),
            Text(
              "Welcome to Saathi",
              style: GoogleFonts.nunito(
                fontSize: w * 0.075,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.015),
            Text(
              "Choose your role to continue",
              style: GoogleFonts.nunito(
                fontSize: w * 0.045,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.06),

            /// --- Role Cards ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AnimatedRoleCard(
                  title: "Wanderer",
                  icon: Icons.directions_walk_rounded,
                  color: Colors.blue,
                  isSelected: selectedRole == "wanderer",
                  onTap: () => onRoleTap("wanderer"),
                ),
                _AnimatedRoleCard(
                  title: "Walker",
                  icon: Icons.volunteer_activism_rounded,
                  color: Colors.green,
                  isSelected: selectedRole == "walker",
                  onTap: () => onRoleTap("walker"),
                ),
              ],
            ),

            const Spacer(),

            /// --- Continue Button ---
            PrimaryButton(
              text: selectedRole == null
                  ? "Select a Role to Continue"
                  : "Continue as ${selectedRole!.capitalizeFirst}",
              onPressed: () async {
                if (selectedRole == null) {
                  Get.snackbar(
                    "Select Role",
                    "Please choose a role before continuing.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange.shade100,
                    colorText: Colors.black87,
                  );
                  return;
                }

                try {
                  // Update role in Supabase users table
                  await authController.updateUserRole(selectedRole!);
                  Get.to(() => const LoginScreen());
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    e.toString(),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade400,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// --- Custom Animated Role Card ---
class _AnimatedRoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedRoleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = Get.width;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: w * 0.36,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: w * 0.1),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: w * 0.045,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
