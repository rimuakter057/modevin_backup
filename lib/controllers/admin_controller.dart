import 'package:get/get.dart';
import '../core/db/db_helper.dart';
import '../core/prefs/pref_manager.dart';
import '../models/user_model.dart';

class AdminController extends GetxController {
  final DbHelper _dbHelper = DbHelper();
  final PrefManager _pref = Get.find<PrefManager>();

  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<Map<String, dynamic>> paymentLogs = <Map<String, dynamic>>[].obs;
  
  // Platform Controls (sync with SharedPreferences)
  final RxBool ebayActive = true.obs;
  final RxBool chrono24Active = true.obs;
  final RxBool grailzeeActive = true.obs;
  final RxBool imageSearchActive = true.obs;
  final RxBool adsActive = true.obs;

  // Pricing values (mock configuration settings)
  final RxDouble premiumPlanPrice = 29.99.obs;
  final RxDouble vipPlanPrice = 49.99.obs;

  // Diagnostics and Health (simulated analytics)
  final RxDouble cpuUsage = 12.4.obs;
  final RxDouble ramUsage = 44.1.obs;
  final RxInt apiRequestsCount = 1042.obs;
  final RxInt activeSessions = 8.obs;
  final RxDouble systemUptimeHours = 172.5.obs;

  final RxList<String> simulatedErrorLogs = <String>[].obs;
  final RxList<Map<String, dynamic>> simulatedApiSpeeds = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadToggles();
    fetchUsers();
    fetchPaymentHistory();
    _startSimulatedDiagnostics();
  }

  void _loadToggles() {
    ebayActive.value = _pref.ebayEnabled;
    chrono24Active.value = _pref.chrono24Enabled;
    grailzeeActive.value = _pref.grailzeeEnabled;
    imageSearchActive.value = _pref.imageSearchEnabled;
    adsActive.value = _pref.adsEnabled;
  }

  // Toggles for Admin Dashboard
  Future<void> toggleEbay(bool val) async {
    ebayActive.value = val;
    await _pref.setEbayEnabled(val);
  }

  Future<void> toggleChrono24(bool val) async {
    chrono24Active.value = val;
    await _pref.setChrono24Enabled(val);
  }

  Future<void> toggleGrailzee(bool val) async {
    grailzeeActive.value = val;
    await _pref.setGrailzeeEnabled(val);
  }

  Future<void> toggleImageSearch(bool val) async {
    imageSearchActive.value = val;
    await _pref.setImageSearchEnabled(val);
  }

  Future<void> toggleAds(bool val) async {
    adsActive.value = val;
    await _pref.setAdsEnabled(val);
  }

  // Load Users List
  Future<void> fetchUsers() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('users');
      final list = maps.map((m) => UserModel.fromMap(m)).toList();
      allUsers.assignAll(list);
    } catch (e) {
      print("Admin failed fetching users: $e");
    }
  }

  // Update User attributes
  Future<void> updateUser(int id, {String? name, String? role, String? plan, String? status}) async {
    try {
      final db = await _dbHelper.database;
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (role != null) updates['role'] = role;
      if (plan != null) updates['plan'] = plan;
      if (status != null) updates['status'] = status;

      if (updates.isEmpty) return;

      await db.update(
        'users',
        updates,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      await fetchUsers();
      Get.snackbar("User Updated", "Successfully modified user attributes.");
    } catch (e) {
      print("Admin failed updating user: $e");
    }
  }

  // Load Payment Logs
  Future<void> fetchPaymentHistory() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> logs = await db.rawQuery('''
        SELECT p.*, u.name as user_name FROM payment_history p
        INNER JOIN users u ON p.user_id = u.id
        ORDER BY p.date DESC
      ''');
      paymentLogs.assignAll(logs);
    } catch (e) {
      print("Admin failed fetching billing logs: $e");
    }
  }

  // Edit Subscription price
  void editPremiumPrice(double price) {
    premiumPlanPrice.value = price;
    Get.snackbar("Billing Changed", "Updated Premium tier price to \$${price.toStringAsFixed(2)}");
  }

  // Simulated metrics updating
  void _startSimulatedDiagnostics() {
    simulatedErrorLogs.assignAll([
      "WARNING: Chrono24 API connection latency is higher than expected (420ms)",
      "ERROR: Image Search API response code 503 (Service Temporarily Unavailable)",
      "INFO: Database index optimizing completed successfully",
      "WARNING: Volatility tracker cron executed with minor delay (14s)",
    ]);

    simulatedApiSpeeds.assignAll([
      {'platform': 'Chrono24', 'latency': 180, 'status': 'Healthy'},
      {'platform': 'eBay', 'latency': 90, 'status': 'Healthy'},
      {'platform': 'Grailzee', 'latency': 140, 'status': 'Healthy'},
    ]);
  }

  // Calculate platform statistics
  double get totalRevenue {
    double total = 0.0;
    for (var log in paymentLogs) {
      total += (log['amount'] as num).toDouble();
    }
    return total;
  }
}
