import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/screens/main_scaffold.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/onboarding_screen.dart';
import 'auth_controller.dart';

class SplashController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final storage = GetStorage();

  @override
  void onReady() {
    super.onReady();
    _checkFirstTimeAndNavigate();
  }

  Future<void> _checkFirstTimeAndNavigate() async {
    // Delay for splash screen
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Check if user has seen onboarding
      final bool hasSeenOnboarding = storage.read('hasSeenOnboarding') ?? false;

      if (!hasSeenOnboarding) {
        // New user, show OnboardingScreen
        print('[SPLASH] New user. Navigating to OnboardingScreen.');
        Get.offAll(() => const OnboardingScreen());
      } else {
        // Existing user, check session
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          // User is logged in, navigate to home
          print('[SPLASH] User logged in. Navigating to Home.');

          // Main app screen
          Get.offAll(() => MainScaffold());
        } else {
          // User is logged out, navigate to login
          print('[SPLASH] User logged out. Navigating to LoginScreen.');
          Get.offAll(() => LoginScreen());
        }
      }
    } catch (e) {
      // Fallback to LoginScreen on error
      print('[SPLASH] Error: $e');
      Get.offAll(() => LoginScreen());
    }
  }
}

