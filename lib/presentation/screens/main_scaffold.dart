
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/nav_controller.dart';

import '../widgets/bottom_navigation_bar.dart';
import 'dashboard_screen.dart';
import 'homescreen.dart';

class MainScaffold extends StatelessWidget {
  MainScaffold({super.key});

  final NavController navController = Get.put(NavController());

  final List<Widget> screens = [


   DashboardScreen(),
   HomePage(),
   HomePage(),


  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor:   Color(0xFF121212),
      body: screens[navController.selectedIndex.value],
      bottomNavigationBar: BottomNavBar(navController: navController),
    ));
  }
}


