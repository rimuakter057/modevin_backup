import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_watch_box/core/prefs/pref_manager.dart';
import 'package:the_watch_box/controllers/auth_controller.dart';
import 'package:the_watch_box/controllers/search_controller.dart';
import 'package:the_watch_box/controllers/alert_controller.dart';
import 'package:the_watch_box/models/watch_model.dart';
import 'package:path/path.dart';
import 'package:the_watch_box/controllers/bookmark_controller.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUpAll(() async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, 'watch_sphere.db');
    await databaseFactory.deleteDatabase(path);

    // Set mock values for SharedPreferences
    SharedPreferences.setMockInitialValues({
      'onboarded': true,
      'active_user_id': 2, // John Doe (Free)
    });
    
    await Get.putAsync<PrefManager>(() => PrefManager().init());
    Get.put(AuthController());
    Get.put(WatchSearchController());
    Get.put(BookmarkController());
    Get.put(AlertController());
  });

  tearDownAll(() {
    Get.reset();
  });

  test('Marketplace peer-to-peer flows test', () async {
    final searchCtrl = Get.find<WatchSearchController>();
    final authCtrl = Get.find<AuthController>();
    final alertCtrl = Get.find<AlertController>();

    // Log in John Doe explicitly
    final initialLogin = await authCtrl.login('John Doe', 'user', 'free');
    expect(initialLogin, isTrue);
    expect(authCtrl.currentUser.value, isNotNull);
    expect(authCtrl.currentUser.value!.id, 2);

    // 1. Verify we can get trader listings
    final traderListings = await searchCtrl.getTraderListings();
    // Initially we have 3 active seeded trader listings
    expect(traderListings.length, 3);
    expect(traderListings.any((w) => w.brand == 'Rolex' && w.model == 'Daytona'), isTrue);

    // 2. Verify we can create a custom listing for current user (John Doe)
    final createSuccess = await searchCtrl.createCustomListing(
      brand: 'Rolex',
      model: 'Submariner',
      title: 'My Custom Submariner 124060',
      price: 13900.0,
      year: 2022,
      condition: 'Mint',
      location: 'New York, USA',
    );
    expect(createSuccess, isTrue);

    // Get active user listings
    final activeListings = await searchCtrl.getUserListings(isSold: false);
    expect(activeListings.length, 1);
    expect(activeListings.first.title, 'My Custom Submariner 124060');

    // 3. Verify buying a trader listing
    final firstTraderWatch = traderListings.first; // e.g. Daytona
    final buySuccess = await searchCtrl.buyListing(firstTraderWatch, 'John Doe');
    expect(buySuccess, isTrue);

    // After purchase, the watch is marked sold and not returned in active list
    final updatedTraderListings = await searchCtrl.getTraderListings();
    expect(updatedTraderListings.any((w) => w.id == firstTraderWatch.id), isFalse);

    // First, let's login as the seller (user 3, "Horology Fan") so we can see it as sold listing
    final loginSuccess = await authCtrl.login('Horology Fan', 'user', 'paid');
    expect(loginSuccess, isTrue);
    expect(authCtrl.currentUser.value!.id, 3);

    final soldListings = await searchCtrl.getUserListings(isSold: true);
    expect(soldListings.any((w) => w.id == firstTraderWatch.id), isTrue);

    // Generate invoice
    final invoiceSuccess = await searchCtrl.generateInvoice(
      listingId: firstTraderWatch.id!,
      buyerName: 'John Doe',
      buyerEmail: 'john.doe@example.com',
      price: firstTraderWatch.price,
    );
    expect(invoiceSuccess, isTrue);

    // Get the invoice
    final invoice = await searchCtrl.getInvoice(firstTraderWatch.id!);
    expect(invoice, isNotNull);
    expect(invoice!['buyer_name'], 'John Doe');
    expect(invoice['buyer_email'], 'john.doe@example.com');
  });
}
