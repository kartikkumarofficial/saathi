// walker_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalkerController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  var walkRequests = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  Future<void> fetchWalkRequests() async {
    try {
      isLoading.value = true;
      final res = await supabase.from('walk_requests').select();

      // Join user info for wanderers
      final enriched = await Future.wait(res.map((req) async {
        final wanderer = await supabase
            .from('users')
            .select('full_name, profile_image')
            .eq('id', req['wanderer_id'])
            .maybeSingle();
        return {
          ...req,
          'wanderer_name': wanderer?['full_name'] ?? 'Unknown',
          'wanderer_image': wanderer?['profile_image'],
        };
      }));

      walkRequests.assignAll(enriched);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRequestStatus(String id, String status) async {
    await supabase.from('walk_requests').update({'status': status}).eq('id', id);
  }
}
