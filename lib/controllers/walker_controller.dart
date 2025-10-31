import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalkerController extends GetxController {
  final supabase = Supabase.instance.client;

  var walkRequests = [].obs;
  var isLoading = false.obs;

  Future<void> fetchRequests(String walkerId) async {
    isLoading.value = true;
    final response = await supabase
        .from('walk_requests')
        .select('id, wanderer_id, start_location, end_location, price, status')
        .eq('walker_id', walkerId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    walkRequests.value = response;
    isLoading.value = false;
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await supabase
        .from('walk_requests')
        .update({'status': status})
        .eq('id', requestId);
    await fetchRequests(
        supabase.auth.currentUser!.id); // refresh list after update
  }
}
