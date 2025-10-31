import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/walker_controller.dart';
import '../widgets/walker_map_widget.dart';
// import 'walker_map_widget.dart';

class WalkerDashboard extends StatelessWidget {
  final WalkerController controller = Get.put(WalkerController());

  WalkerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final walkerId = controller.supabase.auth.currentUser!.id;
    controller.fetchRequests(walkerId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Walker Dashboard"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 250,
            child: WalkerMapWidget(),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.walkRequests.isEmpty) {
                return const Center(child: Text("No new requests yet 🕊️"));
              }
              return ListView.builder(
                itemCount: controller.walkRequests.length,
                itemBuilder: (context, index) {
                  final req = controller.walkRequests[index];
                  return Card(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Start: ${req['start_location']}"),
                          Text("End: ${req['end_location']}"),
                          Text("Price: ₹${req['price']}"),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                label: const Text("Accept"),
                                onPressed: () async {
                                  await controller.updateRequestStatus(
                                      req['id'], 'accepted');
                                },
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.close),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                label: const Text("Reject"),
                                onPressed: () async {
                                  await controller.updateRequestStatus(
                                      req['id'], 'rejected');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
