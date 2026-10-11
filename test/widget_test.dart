import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_watch_box/core/prefs/pref_manager.dart';
import 'package:the_watch_box/controllers/auth_controller.dart';
import 'package:the_watch_box/controllers/search_controller.dart';
import 'package:the_watch_box/controllers/bookmark_controller.dart';
import 'package:the_watch_box/controllers/alert_controller.dart';
import 'package:the_watch_box/main.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Set mock values for SharedPreferences
    SharedPreferences.setMockInitialValues({
      'onboarded': true,
      'active_user_id': -1,
    });

    // Manually initialize core services before pumping application
    await Get.putAsync<PrefManager>(() => PrefManager().init());
    Get.put(AuthController());
    Get.put(WatchSearchController());
    Get.put(BookmarkController());
    Get.put(AlertController());

    // Build our app and trigger a frame.
    await tester.pumpWidget(const TheWatchBoxApp());

    // Verify that splash screen content is displayed initially
    expect(find.text('THE WATCH BOX'), findsOneWidget);
    expect(find.text('YOUR WORLD OF HOROLOGY'), findsOneWidget);

    // Pump frames to complete loading bar timers (2 seconds)
    await tester.pump(const Duration(seconds: 3));
  });
}
