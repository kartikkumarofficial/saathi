import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/nav_controller.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatelessWidget {
  final NavController navController;
  const BottomNavBar({super.key, required this.navController});

  // --- THIS IS YOUR REAL APP THEME COLOR ---
  static const Color _tealGreen = Color(0xFF7AB7A7);

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.self_improvement, 'label': 'Home'},
      {'icon': Icons.handshake, 'label': 'Connect'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // Brighter
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Softer shadow
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Added horizontal padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final selected = navController.selectedIndex.value == index;
            final icon = items[index]['icon'] as IconData;
            final label = items[index]['label'] as String;

            return GestureDetector(
              onTap: () => navController.changeTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  // --- FIX: Using TEAL color ---
                  color: selected
                      ? _tealGreen.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: selected ? 1.1 : 1.0), // Smaller scale
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      builder: (context, scale, _) => Transform.scale(
                        scale: scale,
                        child: Icon(
                          icon,
                          // --- FIX: Using TEAL color ---
                          color: selected
                              ? _tealGreen
                              : Colors.grey.shade600,
                          size: 26, // Slightly smaller
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: GoogleFonts.nunito( // --- FIX: Using Nunito font ---
                        color: selected
                            ? _tealGreen
                            : Colors.grey.shade600,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w500, // Bolder
                        fontSize: 12, // Fixed size
                      ),
                      child: Text(label),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}