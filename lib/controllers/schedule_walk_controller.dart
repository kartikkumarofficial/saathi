import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleWalkController extends GetxController {
  final supabase = Supabase.instance.client;
  final isLoading = false.obs;

  Future<void> scheduleWalk({
    required String walkerId,
    required String wandererId,
    required DateTime startTime,
  }) async {
    try {
      isLoading.value = true;

      final response = await supabase.from('walk_requests').insert({
        'walker_id': walkerId,
        'wanderer_id': wandererId,
        'status': 'pending', // pending until walker accepts
        'scheduled_time': startTime.toUtc().toIso8601String(),
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      if (response.error != null) {
        throw response.error!;
      }

      Get.snackbar(
        "Walk Requested",
        "Your walk request has been sent to the walker!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.secondaryContainer,
      );
    } catch (e) {
      Get.snackbar(
        "Failed to Schedule",
        e.toString(),
        backgroundColor: Get.theme.colorScheme.errorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
