import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services/cloudinary_service.dart';
import '../controllers/user_controller.dart';

class EditAccountController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final aboutController = TextEditingController();

  final isLoading = false.obs;
  final selectedImage = Rxn<File>();
  final userController = Get.find<UserController>();
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    nameController.text = userController.userName.value;
    emailController.text = userController.email.value;
    aboutController.text = userController.about.value;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      selectedImage.value = File(result.files.single.path!);
    }
  }

  Future<void> saveChanges() async {
    isLoading.value = true;

    try {
      String? imageUrl = userController.profileImageUrl.value;

      // ✅ Upload and replace image if selected
      if (selectedImage.value != null) {
        final newUrl = await CloudinaryService.uploadAndReplaceImage(
          imageFile: selectedImage.value!,
          oldImageUrl: userController.profileImageUrl.value,
        );

        if (newUrl != null) {
          imageUrl = newUrl;
        } else {
          Get.snackbar('Error', 'Image upload failed', colorText: Colors.white);
          return;
        }
      }

      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final about = aboutController.text.trim();
      final currentUser = supabase.auth.currentUser;

      if (currentUser != null) {
        // ✅ Update Supabase 'users' table
        await supabase.from('users').update({
          'full_name': name,
          'email': email,
          'profile_image': imageUrl,
          'about': about,
        }).eq('id', currentUser.id);

        // ✅ Update Supabase auth user email
        await supabase.auth.updateUser(UserAttributes(email: email));

        // ✅ Update local state
        userController.userName.value = name;
        userController.email.value = email;
        userController.profileImageUrl.value = imageUrl ?? '';
        userController.about.value = about;

        Get.back();
        Get.snackbar('Success', 'Profile updated', colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    aboutController.dispose();
    super.onClose();
  }
}
