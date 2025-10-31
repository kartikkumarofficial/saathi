import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saathi/presentation/screens/homescreen.dart';
import 'package:saathi/presentation/screens/wanderer_dashboard.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/auth_controller.dart';

import '../widgets/bottom_nav_bar_dark.dart';
import '../widgets/bottom_navigation_bar.dart';

// // Screens
// import 'wanderer_home_screen.dart';
// import 'walker_home_screen.dart';
// import 'bookings_screen.dart';
// import 'chat_screen.dart';
// import 'profile_screen.dart';

class MainScaffold extends StatelessWidget {
  MainScaffold({super.key});

  final NavController navController = Get.find<NavController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final userRole = authController.user.value?.role ?? 'wanderer';

    /// Different screen sets depending on role
    final List<Widget> wandererScreens = [
      WandererDashboard(),
      HomePage(),
      HomePage(),
      HomePage(),

      // const BookingsScreen(),
      // const ChatScreen(),
      // const ProfileScreen(),
    ];

    final List<Widget> walkerScreens = [
      HomePage(),
      HomePage(),
      HomePage(),
      HomePage(),
      // const WalkerHomeScreen(),
      // const BookingsScreen(),
      // const ChatScreen(),
      // const ProfileScreen(),
    ];

    /// Pick correct one
    final List<Widget> screens =
    userRole == 'walker' ? walkerScreens : wandererScreens;

    return Obx(
          () => Scaffold(
        // backgroundColor: Colors.transparent,
        body: screens[navController.selectedIndex.value],
        bottomNavigationBar: BottomNavBar(navController: navController),
      ),
    );
  }
}
