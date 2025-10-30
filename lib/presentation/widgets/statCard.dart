import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget statCard({required String title, required String value, String? subValue}) {
  return Expanded(
    child: Column(
      children: [
        if (subValue != null)
          Text(
            subValue,
            style: GoogleFonts.playfairDisplay(
              fontSize: 14,
              color: Colors.orange[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}
