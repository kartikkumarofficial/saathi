import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class WalkSessionScreen extends StatefulWidget {
  final String walkRequestId;
  final String walkerId;
  final String wandererId;
  final Map<String, dynamic> requestData;

  const WalkSessionScreen({
    Key? key,
    required this.walkRequestId,
    required this.walkerId,
    required this.wandererId,
    required this.requestData,
  }) : super(key: key);

  @override
  State<WalkSessionScreen> createState() => _WalkSessionScreenState();
}

class _WalkSessionScreenState extends State<WalkSessionScreen> {

  final supabase = Supabase.instance.client;
  bool sessionActive = false;
  String? sessionId;

  Future<void> startSession() async {
    final res = await supabase.from('walk_sessions').insert({
      'walk_request_id': widget.walkRequestId,
      'walker_id': widget.walkerId,
      'wanderer_id': widget.wandererId,
      'start_time': DateTime.now().toIso8601String(),
      'status': 'active',
    }).select().single();

    setState(() {
      sessionId = res['id'];
      sessionActive = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session started!')),
    );
  }


  Future<void> endSession() async {
    if (sessionId == null) return;

    // await supabase.from('walk_sessions').update({
    //   'end_time': DateTime.now().toIso8601String(),
    //   'status': 'completed',
    // }).eq('id', sessionId);

    setState(() {
      sessionActive = false;
      sessionId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session ended!')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final _tealGreen = const Color(0xFF2E8B57);
    final wandererName = widget.requestData['wanderer_name'] ?? 'Wanderer';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _tealGreen,
        title: Text(
          "$wandererName’s Session",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              "Session with $wandererName",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Choose an action below to begin your walking session.",
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 💬 Chat Option
            _buildOptionCard(
              icon: Icons.chat_bubble_rounded,
              title: "Chat with $wandererName",
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      walkRequestId: widget.walkRequestId,
                      walkerId: widget.walkerId,
                      wandererId: widget.wandererId,
                      requestData: widget.requestData,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 📍 Share Live Location Option
            _buildOptionCard(
              icon: Icons.location_on_rounded,
              title: "Share Live Location",
              color: Colors.teal,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                    Text("📍 Live location shared with wanderer!"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const Spacer(),

            // 🔴 Start / End Session Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sessionActive ? endSession : startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  sessionActive ? Colors.redAccent : _tealGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  sessionActive ? "End Session" : "Start Session",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
