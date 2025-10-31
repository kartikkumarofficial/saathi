import 'package:get/get.dart';
import 'package:saathi/controllers/wanderer_dashboard_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nav_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/schedule_walk_controller.dart';
import '../controllers/dashboard_controller.dart';
// import '../controllers/profile_controller.dart';
// import '../controllers/edit_account_controller.dart';
import '../controllers/walker_controller.dart';
import '../controllers/walker_details_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 🔒 Authentication
    Get.put(AuthController(), permanent: true);

    // 🧭 Navigation and UI
    Get.put(NavController(), permanent: true);
    Get.put(ThemeController(), permanent: true);

    // 👤 User Management
    Get.put(UserController(), permanent: true);
    // Get.put(ProfileController(), permanent: true);
    // Get.put(EditAccountController(), permanent: true);

    // 🚶‍♂️ Walker & Walk Scheduling
    Get.put(ScheduleWalkController(), permanent: true);
    Get.put(WalkerController(), permanent: true);

    Get.put(WandererDashboardController(), permanent: true);
    Get.put(WalkerDetailsController(), permanent: true);

  }
}
