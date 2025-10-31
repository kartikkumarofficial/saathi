import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditAccountController extends GetxController {
  final supabase = Supabase.instance.client;

  var isSaving = false.obs;
  var currentImageUrl = ''.obs;
  var profileImage = Rx<File?>(null);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final aboutController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    final userId = supabase.auth.currentUser!.id;
    final response =
    await supabase.from('users').select().eq('id', userId).single();
    nameController.text = response['name'] ?? '';
    emailController.text = response['email'] ?? '';
    aboutController.text = response['about'] ?? '';
    currentImageUrl.value = response['profile_image'] ?? '';
  }

  Future<String?> uploadToCloudinary(File file) async {
    const cloudName = 'YOUR_CLOUDINARY_NAME';
    const uploadPreset = 'YOUR_UPLOAD_PRESET';

    final url =
    Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final data = json.decode(await response.stream.bytesToString());
      return data['secure_url'];
    } else {
      Get.snackbar("Error", "Image upload failed");
      return null;
    }
  }

  Future<void> saveProfile() async {
    try {
      isSaving.value = true;
      String? imageUrl = currentImageUrl.value;

      if (profileImage.value != null) {
        final uploadedUrl = await uploadToCloudinary(profileImage.value!);
        if (uploadedUrl != null) imageUrl = uploadedUrl;
      }

      final userId = supabase.auth.currentUser!.id;
      await supabase.from('users').update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'about': aboutController.text.trim(),
        'profile_image': imageUrl,
      }).eq('id', userId);

      Get.back(result: true);
      Get.snackbar("Success", "Profile updated successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSaving.value = false;
    }
  }
}
