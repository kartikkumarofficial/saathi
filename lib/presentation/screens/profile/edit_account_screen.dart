import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/editaccount_controller.dart';

class EditAccountPage extends StatelessWidget {
  final accountController = Get.put(EditAccountController());

  EditAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Get.back(result: true),
        ),
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // 🖼️ Profile Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: accountController.pickImage,
                  child: CircleAvatar(
                    radius: Get.width * 0.18,
                    backgroundColor: Colors.grey[100],
                    backgroundImage: accountController.selectedImage.value != null
                        ? FileImage(accountController.selectedImage.value!)
                        : accountController.userController.profileImageUrl.value.isNotEmpty
                        ? NetworkImage(accountController.userController.profileImageUrl.value)
                        : const AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✍️ Username below image
            Text(
              accountController.nameController.text.isNotEmpty
                  ? accountController.nameController.text
                  : "Your Name",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 4),
            Text(
              accountController.emailController.text.isNotEmpty
                  ? accountController.emailController.text
                  : "email@example.com",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 28),

            // ✨ Editable Fields
            buildInputField(
              label: "Full Name",
              controller: accountController.nameController,
              icon: CupertinoIcons.person,
            ),
            const SizedBox(height: 16),

            buildInputField(
              label: "Email",
              controller: accountController.emailController,
              icon: CupertinoIcons.mail,
            ),
            const SizedBox(height: 16),

            buildInputField(
              label: "About",
              controller: accountController.aboutController,
              icon: CupertinoIcons.pencil_ellipsis_rectangle,
              maxLines: 3,
            ),

            const SizedBox(height: 60),
          ],
        ),
      )),

      // 💾 Save Button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Obx(
                () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              onPressed: accountController.isLoading.value
                  ? null
                  : accountController.saveChanges,
              child: accountController.isLoading.value
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Text(
                "Save Changes",
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🧩 Custom Input Field
  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15.5, color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.deepPurpleAccent, size: 20)
            : null,
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14.5,
          color: Colors.grey[700],
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.3),
        ),
      ),
    );
  }
}
