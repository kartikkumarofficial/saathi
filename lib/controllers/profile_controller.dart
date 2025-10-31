import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_controller.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;
  final authController = Get.find<AuthController>();


  var userName = ''.obs;
  var email = ''.obs;
  var about = ''.obs;
  var role = ''.obs;
  var profileImageUrl = ''.obs;

  var journeysTaken = 0.obs;
  var milesTraveled = 0.0.obs;
  var rating = 4.8.obs; // default, can be dynamic later

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        userName.value = response['name'] ?? '';
        email.value = response['email'] ?? '';
        about.value = response['about'] ?? '';
        role.value = response['role'] ?? '';
        profileImageUrl.value = response['profile_url'] ?? '';
        journeysTaken.value = response['journeys_taken'] ?? 0;
        milesTraveled.value =
            double.tryParse(response['miles_traveled'].toString()) ?? 0.0;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleRole() async {
    final newRole = role.value == 'walker' ? 'wanderer' : 'walker';
    await supabase
        .from('users')
        .update({'role': newRole})
        .eq('id', supabase.auth.currentUser!.id);
    role.value = newRole;
    Get.snackbar("Role Updated", "You are now a $newRole");
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/login');
  }
}
