import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/onboarding/onboarding_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/admin/admin_dashboard.dart';
import '../../views/profile/subscription_plans_screen.dart';
import '../../views/profile/notifications_screen.dart';
import '../../views/profile/account_settings_screen.dart';
import '../../views/profile/change_password_screen.dart';
import 'app_routes.dart';

/// GetPage table, extracted out of main.dart so the app entrypoint only
/// wires up bootstrapping (DB, prefs, controllers) and route list growth
/// doesn't bloat main.dart.
class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OnboardingController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainContainerScreen(),
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminDashboard(),
    ),
    GetPage(
      name: AppRoutes.subscriptionPlans,
      page: () => const SubscriptionPlansScreen(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const ActivityNotificationsScreen(),
    ),
    GetPage(
      name: AppRoutes.accountSettings,
      page: () => const AccountSettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
    ),
  ];
}
