import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saathi/controllers/user_controller.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/services/cloudinary_service.dart';

class EditAccountController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final aboutController = TextEditingController();

  final isLoading = false.obs;
  final selectedImage = Rxn<File>();
  final userController = Get.find<UserController>();

  @override
  void onInit() {
    nameController.text = userController.userName.value;
    emailController.text = userController.email.value;
    aboutController.text = userController.about.value;
    super.onInit();
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
      if (selectedImage.value != null) {
        final uploadedUrl =
        await CloudinaryService.uploadImage(selectedImage.value!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          Get.snackbar('Error', 'Image upload failed',
              colorText: Colors.white);
          return;
        }
      }

      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final about = aboutController.text.trim();
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        await Supabase.instance.client.from('users').update({
          'username': name,
          'email': email,
          'profile_image': imageUrl,
          'about': about,
        }).eq('id', user.id);

        await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: email),
        );

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
