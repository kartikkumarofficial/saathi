import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF7AB7A7),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w * 0.04),
        ),
        elevation: 6,
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: w * 0.045,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
