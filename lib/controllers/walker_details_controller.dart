// lib/controllers/walker_details_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalkerDetailsController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var isLoading = false.obs;
  var reviews = <Map<String, dynamic>>[].obs;

  Future<void> fetchReviews(String walkerId) async {
    try {
      isLoading.value = true;

      // fetch ratings with reviewer info; adjust field names if your schema differs
      final res = await supabase
          .from('ratings')
          .select('rating, comment, created_at, reviewer_id(id, full_name, profile_image)')
          .eq('reviewee_id', walkerId)
          .order('created_at', ascending: false);

      if (res is List) {
        // convert reviewer join to single key 'reviewer' for UI convenience
        final list = (res).map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final reviewer = (m['reviewer_id'] is Map) ? Map<String, dynamic>.from(m['reviewer_id']) : null;
          return {
            'rating': m['rating'],
            'comment': m['comment'],
            'created_at': m['created_at'],
            'reviewer': reviewer,
          };
        }).toList();

        reviews.assignAll(list);
      } else {
        reviews.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch reviews: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
