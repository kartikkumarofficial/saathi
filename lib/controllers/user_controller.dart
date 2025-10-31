import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../presentation/screens/auth/login_screen.dart';

class UserController extends GetxController {
  final supabase = Supabase.instance.client;

  var userName = ''.obs;
  var email = ''.obs;
  var profileImageUrl = ''.obs;
  var about = ''.obs;
  var role = 'wanderer'.obs;
  var journeysTaken = 0.obs;
  var rating = 0.0.obs;
  var milesTraveled = 0.0.obs;
  var isLoading = false.obs;

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      userName.value = response['full_name'] ?? '';
      email.value = response['email'] ?? '';
      profileImageUrl.value = response['profile_image'] ?? '';
      about.value = response['about'] ?? '';
      role.value = response['role'] ?? 'wanderer';
      journeysTaken.value = response['journeys_taken'] ?? 0;
      rating.value = (response['rating'] ?? 0.0).toDouble();
      milesTraveled.value = (response['miles_traveled'] ?? 0.0).toDouble();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRole(String newRole) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('users').update({'role': newRole}).eq('id', user.id);
      role.value = newRole;
      Get.snackbar('Success', 'Role updated to $newRole');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> logOut() async {
    try {
      isLoading.value = true;
      await supabase.auth.signOut();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar('Logout Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
