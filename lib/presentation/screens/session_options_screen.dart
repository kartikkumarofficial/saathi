import 'package:flutter/material.dart';
import 'chat_screen.dart';

class SessionOptionsScreen extends StatelessWidget {
  final String walkRequestId;
  final String walkerId;
  final String wandererId;
  final Map<String, dynamic> requestData;

  const SessionOptionsScreen({
    Key? key,
    required this.walkRequestId,
    required this.walkerId,
    required this.wandererId,
    required this.requestData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _tealGreen = const Color(0xFF2E8B57);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Walk Session",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _tealGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              "Choose what you’d like to do with ${requestData['wanderer_name'] ?? 'the wanderer'}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
            _buildOptionCard(
              context,
              icon: Icons.chat_rounded,
              title: "Chat with Wanderer",
              subtitle: "Send and receive messages in real time",
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      walkRequestId: walkRequestId,
                      walkerId: walkerId,
                      wandererId: wandererId,
                      requestData: requestData,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context,
              icon: Icons.screen_share_rounded,
              title: "Share Screen",
              subtitle: "Share your location and walk stats",
              color: Colors.teal,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Screen sharing coming soon!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap}) {
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
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
