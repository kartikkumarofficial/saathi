import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalkerCard extends StatelessWidget {
  final String name;
  final String image;
  final String distance;
  final double rating;

  const WalkerCard({
    super.key,
    required this.name,
    required this.image,
    required this.distance,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundImage: NetworkImage(image)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Text("$distance away",
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              Text(rating.toStringAsFixed(1),
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}
