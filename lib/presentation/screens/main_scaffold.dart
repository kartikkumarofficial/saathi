import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saathi/presentation/screens/homescreen.dart';
import 'package:saathi/presentation/screens/profile_screen.dart';
import 'package:saathi/presentation/screens/walker_dashboard.dart';
import 'package:saathi/presentation/screens/wanderer_dashboard.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/bottom_nav_bar_dark.dart';
import '../widgets/bottom_navigation_bar.dart'; // using your BottomNavBar widget

class MainScaffold extends StatelessWidget {
  MainScaffold({super.key});

  // GetX controllers
  final NavController navController = Get.put(NavController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userRole = authController.user.value?.role ?? 'wanderer';
      final currentIndex = navController.selectedIndex.value;

      // Screens for each role
      final wandererScreens = [
        WandererDashboard(),
        HomePage(),
        ProfileScreen(),
      ];

      final walkerScreens = [
        WalkerDashboardScreen(),
        HomePage(),
        ProfileScreen(),
      ];

      // Select screen set based on user role
      final screens = userRole == 'walker' ? walkerScreens : wandererScreens;

      return Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavBar(navController: navController),
      );
    });
  }
}
