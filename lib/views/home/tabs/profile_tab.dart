import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/watch_background.dart';
import '../../profile/subscription_plans_screen.dart';
import '../../profile/notifications_screen.dart';
import '../../profile/account_settings_screen.dart';
import '../../profile/my_listings_screen.dart';
import '../../../core/db/db_helper.dart';
import '../../../core/prefs/pref_manager.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthController _auth = Get.find<AuthController>();
  final WatchSearchController _search = Get.find<WatchSearchController>();
  final DbHelper _dbHelper = DbHelper();
  
  bool _emailAlerts = true;
  bool _darkMode = false;
  String _selectedCurrency = "USD (\$)";

  @override
  void initState() {
    super.initState();
    _darkMode = Get.find<PrefManager>().isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: context.primaryNav,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.primaryNav),
          onPressed: () {
            // Navigate to Home Tab (index 0)
            final parentState = context.findAncestorStateOfType();
            if (parentState != null && parentState.mounted) {
              try {
                (parentState as dynamic).setState(() {
                  (parentState as dynamic)._currentIndex = 0;
                });
              } catch (_) {}
            }
          },
        ),
      ),
      body: WatchBackground(
        showGears: false,
        showDialTicks: true,
        child: Obx(() {
          final user = _auth.currentUser.value;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool isPremium = user.plan == 'paid';
          final String planTitle = isPremium ? "Elite Annual" : "Standard Free";
          final String avatarPath = "assets/images/alexander_avatar.png";

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Staggered Entrance - Avatar & Header
                StaggeredEntrance(
                  index: 0,
                  child: Column(
                    children: [
                      ProfileGearBehindAvatar(
                        child: Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(45),
                                child: Image.asset(
                                  avatarPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: context.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                    child: Icon(Icons.person, color: context.primaryNav, size: 40),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3.5),
                                decoration: BoxDecoration(
                                  color: context.primaryNav,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.name.toLowerCase().contains("alexander") 
                            ? "a.thorne@chronodata.io" 
                            : "${user.name.toLowerCase().replaceAll(' ', '')}@watchwise.com",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Star badge pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.primaryNav,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text(
                              "ELITE COLLECTOR",
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Staggered Entrance - Current Plan Card
                StaggeredEntrance(
                  index: 1,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.borderColor, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.015),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "CURRENT PLAN",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: context.textSecondaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isPremium ? "RENEWING JUN 2026" : "FREE ACCOUNT",
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: context.isDarkMode ? const Color(0xFF5C93E6) : const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          planTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.primaryNav,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPremium 
                              ? "Access to real-time market insights, vault insurance, and priority concierge sourcing."
                              : "Unlock advanced filters, alerts, historical charts, and image-based searches by upgrading.",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.textSecondaryColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InteractivePressScale(
                          onTap: () => Get.to(() => const SubscriptionPlansScreen()),
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: context.primaryNav,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "MANAGE PLAN",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        if (isPremium) ...[
                          const SizedBox(height: 10),
                          Center(
                            child: InteractivePressScale(
                              onTap: () => _showBillingHistoryBottomSheet(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: Text(
                                  "VIEW BILLING HISTORY",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryNav,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Staggered Entrance - Stats Row
                StaggeredEntrance(
                  index: 2,
                  child: Row(
                    children: [
                      // Vault stat card
                      Expanded(
                        child: InteractivePressScale(
                          onTap: () {
                            Get.snackbar(
                              "The Vault", 
                              "Opening secure watch vault portfolio...",
                              backgroundColor: context.primaryNav,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.borderColor),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.lock_rounded, size: 14, color: context.isDarkMode ? const Color(0xFF5C93E6) : const Color(0xFF2563EB)),
                                    const SizedBox(width: 6),
                                    Text(
                                      "THE VAULT",
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: context.textSecondaryColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "24",
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.primaryNav),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Timepieces",
                                  style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Activity stat card
                      Expanded(
                        child: InteractivePressScale(
                          onTap: () => Get.to(() => const ActivityNotificationsScreen()),
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.borderColor),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.history_rounded, size: 14, color: context.isDarkMode ? const Color(0xFF5C93E6) : const Color(0xFF2563EB)),
                                          const SizedBox(width: 6),
                                          Text(
                                            "ACTIVITY",
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: context.textSecondaryColor),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "12",
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.primaryNav),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Last 30 Days",
                                        style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.textSecondaryColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 4. Staggered Entrance - Preferences Section
                StaggeredEntrance(
                  index: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          "APP PREFERENCES",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Material(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.borderColor),
                          ),
                        child: Column(
                          children: [
                            // Email Alerts
                            InteractivePressScale(
                              onTap: () {
                                setState(() {
                                  _emailAlerts = !_emailAlerts;
                                });
                              },
                              child: ListTile(
                                leading: Icon(Icons.notifications_none_rounded, color: context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                                title: Text(
                                  "Email Alerts",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimaryColor),
                                ),
                                trailing: Switch.adaptive(
                                  value: _emailAlerts,
                                  activeColor: context.primaryNav,
                                  onChanged: (val) {
                                    setState(() {
                                      _emailAlerts = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16, color: context.borderColor),
                            // Dark Mode
                            InteractivePressScale(
                              onTap: () {
                                final nextVal = !_darkMode;
                                setState(() {
                                  _darkMode = nextVal;
                                });
                                final pref = Get.find<PrefManager>();
                                pref.setDarkMode(nextVal);
                                Get.changeThemeMode(nextVal ? ThemeMode.dark : ThemeMode.light);
                                Get.snackbar(
                                  "Theme Changed",
                                  nextVal ? "Dark mode active." : "Light mode active.",
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              child: ListTile(
                                leading: Icon(Icons.dark_mode_outlined, color: context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                                title: Text(
                                  "Dark Mode",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimaryColor),
                                ),
                                trailing: Switch.adaptive(
                                  value: _darkMode,
                                  activeColor: context.primaryNav,
                                  onChanged: (val) {
                                    setState(() {
                                      _darkMode = val;
                                    });
                                    final pref = Get.find<PrefManager>();
                                    pref.setDarkMode(val);
                                    Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                                    Get.snackbar(
                                      "Theme Changed",
                                      val ? "Dark mode active." : "Light mode active.",
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16, color: context.borderColor),
                            // Preferred Currency
                            InteractivePressScale(
                              onTap: () => _showCurrencyPicker(context),
                              child: ListTile(
                                leading: Icon(Icons.payments_outlined, color: context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                                title: Text(
                                  "Preferred Currency",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimaryColor),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedCurrency,
                                      style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.chevron_right_rounded, color: context.textSecondaryColor),
                                  ],
                                ),
                              ),
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16, color: context.borderColor),
                            // Privacy & Security
                            InteractivePressScale(
                              onTap: () => Get.to(() => const AccountSettingsScreen()),
                              child: ListTile(
                                leading: Icon(Icons.shield_outlined, color: context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                                title: Text(
                                  "Privacy & Security",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimaryColor),
                                ),
                                trailing: Icon(Icons.chevron_right_rounded, color: context.textSecondaryColor),
                              ),
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16, color: context.borderColor),
                            // My Listings
                            InteractivePressScale(
                              onTap: () => Get.to(() => const MyListingsScreen()),
                              child: ListTile(
                                leading: Icon(Icons.sell_outlined, color: context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                                title: Text(
                                  "My Listings",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimaryColor),
                                ),
                                trailing: Icon(Icons.chevron_right_rounded, color: context.textSecondaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 5. Staggered Entrance - Danger Zone
                StaggeredEntrance(
                  index: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          "DANGER ZONE",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.isDarkMode ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              InteractivePressScale(
                                onTap: _auth.logout,
                                child: const ListTile(
                                  leading: Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
                                  title: Text(
                                    "Log Out",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                  ),
                                ),
                              ),
                              Divider(height: 1, indent: 16, endIndent: 16, color: context.isDarkMode ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2)),
                              InteractivePressScale(
                                onTap: _showDeleteAccountConfirm,
                                child: const ListTile(
                                  leading: Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                                  title: Text(
                                    "Delete Account",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 6. Staggered Entrance - Version Footer
                const StaggeredEntrance(
                  index: 5,
                  child: Text(
                    "CHRONO/DATA v2.4.0 • BUILT FOR PRECISION",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showBillingHistoryBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.isDarkMode ? const Color(0xFF334155) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Billing History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.primaryNav),
            ),
            const SizedBox(height: 20),
            _buildBillingRow(context, "June 10, 2026", "Elite Annual Plan Upgrade", "\$29.99"),
            Divider(height: 24, color: context.borderColor),
            _buildBillingRow(context, "May 10, 2026", "Elite Annual Plan Renewal", "\$29.99"),
            Divider(height: 24, color: context.borderColor),
            _buildBillingRow(context, "April 10, 2026", "Elite Annual Plan Renewal", "\$29.99"),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingRow(BuildContext context, String date, String desc, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              desc,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
            ),
          ],
        ),
        Text(
          price,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: context.primaryNav),
        ),
      ],
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final List<Map<String, String>> currencies = [
      {"code": "USD", "symbol": "\$", "name": "United States Dollar"},
      {"code": "EUR", "symbol": "€", "name": "Euro"},
      {"code": "GBP", "symbol": "£", "name": "British Pound"},
      {"code": "JPY", "symbol": "¥", "name": "Japanese Yen"},
      {"code": "AUD", "symbol": "A\$", "name": "Australian Dollar"},
    ];

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Preferred Currency",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.primaryNav),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currencies.length,
                itemBuilder: (ctx, index) {
                  final curr = currencies[index];
                  final displayVal = "${curr['code']} (${curr['symbol']})";
                  final isSelected = _selectedCurrency == displayVal;
                  return ListTile(
                    title: Text(
                      "${curr['name']} (${curr['code']})",
                      style: TextStyle(color: context.textPrimaryColor),
                    ),
                    trailing: isSelected 
                        ? Icon(Icons.check_circle_rounded, color: context.isDarkMode ? const Color(0xFF5C93E6) : const Color(0xFF2563EB))
                        : Text(curr['symbol']!, style: TextStyle(color: context.textSecondaryColor, fontWeight: FontWeight.bold)),
                    onTap: () {
                      setState(() {
                        _selectedCurrency = displayVal;
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirm() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to permanently delete your watch collector profile, search history, alerts, and saved content? This action is irreversible.",
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Get.back(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Delete"),
            onPressed: () async {
              Get.back();
              await _deleteAccountFromDb();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccountFromDb() async {
    final user = _auth.currentUser.value;
    if (user == null || user.id == null) return;

    try {
      final db = await _dbHelper.database;
      final userId = user.id!;
      
      // Perform cascading deletes in SQLite
      await db.delete('users', where: 'id = ?', whereArgs: [userId]);
      await db.delete('bookmarks', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('saved_searches', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('alerts', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('payment_history', where: 'user_id = ?', whereArgs: [userId]);

      Get.snackbar(
        "Account Deleted",
        "Your account and secure data logs have been purged.",
        snackPosition: SnackPosition.BOTTOM,
      );

      // Trigger logout process
      await _auth.logout();
    } catch (e) {
      print("Delete account error: $e");
    }
  }
}

// Stateful dual mechanical gear rotation animator
class ProfileGearBehindAvatar extends StatefulWidget {
  final Widget child;
  const ProfileGearBehindAvatar({super.key, required this.child});

  @override
  State<ProfileGearBehindAvatar> createState() => _ProfileGearBehindAvatarState();
}

class _ProfileGearBehindAvatarState extends State<ProfileGearBehindAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Large counter-clockwise steel gear
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: -_controller.value * 2 * pi,
              child: CustomPaint(
                size: const Size(136, 136),
                painter: MechanicalGearPainter(
                  color: const Color(0xFF94A3B8).withOpacity(0.12), // Faint steel gray
                  radius: 65,
                  teethCount: 36,
                  strokeWidth: 1.0,
                ),
              ),
            );
          },
        ),
        // 2. Medium clockwise golden gear
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * pi,
              child: CustomPaint(
                size: const Size(136, 136),
                painter: MechanicalGearPainter(
                  color: const Color(0xFFD97706).withOpacity(0.14), // Faint luxury gold
                  radius: 52,
                  teethCount: 26,
                  strokeWidth: 1.3,
                ),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

// Reusable Mechanical Gear Custom Painter
class MechanicalGearPainter extends CustomPainter {
  final Color color;
  final double radius;
  final int teethCount;
  final double strokeWidth;

  MechanicalGearPainter({
    required this.color,
    required this.radius,
    required this.teethCount,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw outer ring
    canvas.drawCircle(center, radius, paint);
    // Draw inner ring
    canvas.drawCircle(center, radius - 6, paint);
    // Draw core hub ring
    canvas.drawCircle(center, 9, paint);

    // Draw clock spokes (6 spokes)
    final spokes = 6;
    for (int i = 0; i < spokes; i++) {
      final angle = i * pi / 3;
      canvas.drawLine(
        Offset(center.dx + 9 * cos(angle), center.dy + 9 * sin(angle)),
        Offset(center.dx + (radius - 6) * cos(angle), center.dy + (radius - 6) * sin(angle)),
        paint,
      );
    }

    // Draw gear teeth
    final path = Path();
    for (int i = 0; i < teethCount; i++) {
      final angle = i * 2 * pi / teethCount;
      final x1 = center.dx + radius * cos(angle - 0.04);
      final y1 = center.dy + radius * sin(angle - 0.04);
      final x2 = center.dx + (radius + 4.5) * cos(angle - 0.02);
      final y2 = center.dy + (radius + 4.5) * sin(angle - 0.02);
      final x3 = center.dx + (radius + 4.5) * cos(angle + 0.02);
      final y3 = center.dy + (radius + 4.5) * sin(angle + 0.02);
      final x4 = center.dx + radius * cos(angle + 0.04);
      final y4 = center.dy + radius * sin(angle + 0.04);

      path.moveTo(x1, y1);
      path.lineTo(x2, y2);
      path.lineTo(x3, y3);
      path.lineTo(x4, y4);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MechanicalGearPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.teethCount != teethCount ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// Springy Scale-on-Press feedback widget
class InteractivePressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const InteractivePressScale({super.key, required this.child, this.onTap});

  @override
  State<InteractivePressScale> createState() => _InteractivePressScaleState();
}

class _InteractivePressScaleState extends State<InteractivePressScale> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () => _controller.forward(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// Staggered vertical fade-in entrance transition
class StaggeredEntrance extends StatelessWidget {
  final Widget child;
  final int index;
  const StaggeredEntrance({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
