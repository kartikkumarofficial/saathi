import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WandererDetailsController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var reviews = [].obs;

  // Fetch reviews for the walker
  Future<void> fetchReviews(String walkerId) async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('ratings')
          .select('*, reviewer_id(full_name, profile_image)')
          .eq('reviewee_id', walkerId);

      reviews.assignAll(response);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch reviews: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Schedule a walk session
  Future<void> scheduleWalk({
    required String walkerId,
    required String wandererId,
    required DateTime startTime,
  }) async {
    try {
      isLoading.value = true;

      final walk = {
        'walker_id': walkerId,
        'wanderer_id': wandererId,
        'started_at': startTime.toIso8601String(),
        'status': 'scheduled',
      };

      await supabase.from('walk_sessions').insert(walk);
      Get.snackbar('Success', 'Walk scheduled successfully!');
      Get.toNamed('/payment'); // Navigate to payment screen after scheduling
    } catch (e) {
      Get.snackbar('Error', 'Failed to schedule walk: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
