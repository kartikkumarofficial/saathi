import 'package:flutter/material.dart';
import '../../controllers/nav_controller.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatelessWidget {
  final NavController navController;
  const BottomNavBar({super.key, required this.navController});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.self_improvement, 'label': 'Home'},
      {'icon': Icons.handshake, 'label': 'Connect'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
                  color: selected
                      ? const Color(0xFFA3A8F9).withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: selected ? 1.2 : 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      builder: (context, scale, _) => Transform.scale(
                        scale: scale,
                        child: Icon(
                          icon,
                          color: selected
                              ? const Color(0xFF7C83FD)
                              : Colors.grey.shade600,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF7C83FD)
                            : Colors.grey.shade600,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: selected ? 13 : 12,
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
