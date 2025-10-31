import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalkerController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var walkRequests = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalkRequests(); // Auto-fetch when controller initializes
  }

  Future<void> fetchWalkRequests() async {
    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;
      if (user == null) {
        walkRequests.clear();
        return;
      }

      final response = await supabase
          .from('walk_requests')
          .select()
          .eq('walker_id', user.id)
          .order('created_at', ascending: false);

      // ✅ Explicitly cast dynamic -> Map<String, dynamic>
      final List<Map<String, dynamic>> data =
      List<Map<String, dynamic>>.from(response as List);

      walkRequests.assignAll(data);
    } catch (e) {
      Get.snackbar("Error fetching requests", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRequestStatus(String id, String status) async {
    try {
      await supabase
          .from('walk_requests')
          .update({'status': status})
          .eq('id', id);

      await fetchWalkRequests();
    } catch (e) {
      Get.snackbar("Error updating request", e.toString());
    }
  }
}
