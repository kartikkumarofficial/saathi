// lib/presentation/screens/wanderer_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'schedule_walk_screen.dart';

class WandererDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> wanderer;

  const WandererDetailsScreen({super.key, required this.wanderer});

  @override
  State<WandererDetailsScreen> createState() => _WandererDetailsScreenState();
}

class _WandererDetailsScreenState extends State<WandererDetailsScreen> {
  final supabase = Supabase.instance.client;
  final w = Get.width;
  final h = Get.height;

  List<Map<String, dynamic>> reviews = [];
  bool isLoadingReviews = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      isLoadingReviews = true;
      errorMsg = null;
    });

    try {
      // Fetch ratings and the reviewer's basic info from users (via foreign key reviewer_id)
      // Adjust select fields to match your DB schema if needed.
      final res = await supabase
          .from('ratings')
          .select('rating, comment, created_at, reviewer_id(id, full_name, profile_image)')
          .eq('reviewee_id', widget.wanderer['id'])
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> list = (res as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      setState(() {
        reviews = list;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Could not load reviews';
      });
      debugPrint('❌ fetchReviews error: $e');
    } finally {
      setState(() {
        isLoadingReviews = false;
      });
    }
  }

  void _onSchedulePressed() {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      Get.snackbar(
        'Not signed in',
        'Please log in to schedule a walk.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
      );
      return;
    }

    // Navigate to Schedule screen and pass walker + wanderer ids
    Get.to(() => ScheduleWalkScreen(
      walkerId: widget.wanderer['id'],
      wandererId: currentUserId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(widget.wanderer['full_name'] ?? 'Wanderer Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: "walker_${widget.wanderer['id'] ?? widget.wanderer['full_name']}",
              child: CircleAvatar(
                radius: width * 0.22,
                backgroundImage: NetworkImage(
                  widget.wanderer['profile_image'] ?? 'https://via.placeholder.com/150',
                ),
                backgroundColor: Colors.grey[200],
              ),
            ),

            SizedBox(height: height * 0.02),

            Text(
              widget.wanderer['full_name'] ?? 'Unknown Walker',
              style: TextStyle(
                fontSize: width * 0.065,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: height * 0.01),

            Text(
              widget.wanderer['bio'] ?? "Exploring life, one step at a time 🌿",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.042,
                color: Colors.grey.shade700,
              ),
            ),

            SizedBox(height: height * 0.03),
            Divider(thickness: 1, color: Colors.grey.shade300),

            // Contact + Meta
            ListTile(
              leading: const Icon(Icons.email, color: Colors.green),
              title: Text(widget.wanderer['email'] ?? "No email available"),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: Text(widget.wanderer['phone'] ?? "No phone info"),
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text("Rating: ${widget.wanderer['rating'] ?? 4.8} / 5"),
            ),

            SizedBox(height: height * 0.03),

            // Schedule button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: EdgeInsets.symmetric(horizontal: width * 0.16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _onSchedulePressed,
              icon: const Icon(Icons.calendar_month),
              label: const Text("Schedule a Walk"),
            ),

            SizedBox(height: height * 0.03),
            Divider(thickness: 1, color: Colors.grey.shade300),
            SizedBox(height: height * 0.02),

            // Reviews header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Reviews",
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ),

            SizedBox(height: height * 0.015),

            // Reviews content
            if (isLoadingReviews)
              SizedBox(
                height: height * 0.18,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (errorMsg != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: height * 0.02),
                child: Text(errorMsg!, style: TextStyle(color: Colors.red.shade400)),
              )
            else if (reviews.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.02),
                  child: Text("No reviews yet. Be the first to review!",
                      style: TextStyle(color: Colors.grey.shade700)),
                )
              else
              // show reviews in a column
                Column(
                  children: reviews.map((r) {
                    final reviewer = (r['reviewer_id'] is Map) ? r['reviewer_id'] as Map : null;
                    final reviewerName = reviewer?['full_name'] ?? 'Anonymous';
                    final reviewerImage = reviewer?['profile_image'];
                    final rating = r['rating'] ?? 0;
                    final comment = r['comment'] ?? '';
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: width * 0.06,
                            backgroundImage: (reviewerImage != null && reviewerImage.isNotEmpty)
                                ? NetworkImage(reviewerImage)
                                : null,
                            backgroundColor: Colors.grey[200],
                          ),
                          SizedBox(width: width * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(reviewerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        SizedBox(width: width * 0.01),
                                        Text(rating.toString(), style: TextStyle(color: Colors.grey.shade800)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(comment, style: TextStyle(color: Colors.grey.shade700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

            SizedBox(height: height * 0.06),
          ],
        ),
      ),
    );
  }
}
