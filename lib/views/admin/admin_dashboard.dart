import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  final AdminController _admin = Get.put(AdminController());
  final AuthController _auth = Get.find<AuthController>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text("Admin Management"),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.dashboard_outlined),
          onPressed: () {
            // Quick bypass to test User View as Admin
            Get.toNamed('/home');
          },
          tooltip: "Go to Client Home View",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            onPressed: _auth.logout,
            tooltip: "Logout Admin Session",
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.primaryNav,
          unselectedLabelColor: context.textSecondaryColor,
          indicatorColor: context.primaryNav,
          isScrollable: true,
          tabs: const [
            Tab(text: "Platform Control", icon: Icon(Icons.toggle_on_rounded)),
            Tab(text: "User Management", icon: Icon(Icons.people_alt_rounded)),
            Tab(text: "Billing & Plans", icon: Icon(Icons.payments_rounded)),
            Tab(text: "System Health", icon: Icon(Icons.insights_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlatformControlTab(),
          _buildUserManagementTab(),
          _buildBillingTab(),
          _buildDiagnosticsTab(),
        ],
      ),
    );
  }

  // TAB 1: Platform Control
  Widget _buildPlatformControlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Marketplaces Configurations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.primaryNav)),
          const SizedBox(height: 8),
          Text("Globally enable or disable watch source listings on the platform indices.", style: TextStyle(fontSize: 13, color: context.textSecondaryColor)),
          const SizedBox(height: 16),
          
          Obx(() => Card(
            color: context.cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: context.borderColor)),
            child: Column(
              children: [
                _buildSwitchListTile(
                  "Integrate Chrono24 Indices",
                  "Include Chrono24 active/sold search feeds.",
                  _admin.chrono24Active.value,
                  _admin.toggleChrono24,
                ),
                const Divider(height: 1),
                _buildSwitchListTile(
                  "Integrate eBay Listings",
                  "Include eBay watch search feeds.",
                  _admin.ebayActive.value,
                  _admin.toggleEbay,
                ),
                const Divider(height: 1),
                _buildSwitchListTile(
                  "Integrate Grailzee Feeds",
                  "Include Grailzee collector search feeds.",
                  _admin.grailzeeActive.value,
                  _admin.toggleGrailzee,
                ),
              ],
            ),
          )),
          const SizedBox(height: 32),
          
          Text("Global Feature Toggles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.primaryNav)),
          const SizedBox(height: 16),
          Obx(() => Card(
            color: context.cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: context.borderColor)),
            child: Column(
              children: [
                _buildSwitchListTile(
                  "Image-Based Searching",
                  "Enable camera mock scanner globally.",
                  _admin.imageSearchActive.value,
                  _admin.toggleImageSearch,
                ),
                const Divider(height: 1),
                _buildSwitchListTile(
                  "In-App Sponsor Ads",
                  "Show banner ads layout for Free tier accounts.",
                  _admin.adsActive.value,
                  _admin.toggleAds,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSwitchListTile(String title, String desc, bool current, Function(bool) onChange) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      value: current,
      activeColor: context.primaryNav,
      onChanged: onChange,
    );
  }

  // TAB 2: User Management
  Widget _buildUserManagementTab() {
    return Obx(() {
      if (_admin.allUsers.isEmpty) {
        return const Center(child: Text("No registered user rows found."));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _admin.allUsers.length,
        itemBuilder: (context, idx) {
          final user = _admin.allUsers[idx];
          return _buildUserManagementCard(user);
        },
      );
    });
  }

  Widget _buildUserManagementCard(UserModel user) {
    final bool isUserActive = user.isActive;
    return Card(
      color: context.cardBg,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.primaryNav.withValues(alpha: 0.1),
                  child: Text(user.name.substring(0, 1).toUpperCase(), style: TextStyle(color: context.primaryNav, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text("Role: ${user.role} | Tier: ${user.plan}", style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
                    ],
                  ),
                ),
                // Active/Inactive badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUserActive
                        ? (context.isDarkTheme ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50)
                        : (context.isDarkTheme ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isUserActive ? "Active" : "Banned",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUserActive
                          ? (context.isDarkTheme ? Colors.green.shade300 : Colors.green.shade700)
                          : (context.isDarkTheme ? Colors.red.shade300 : Colors.red.shade700),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Change Role
                TextButton.icon(
                  onPressed: () {
                    final nextRole = user.role == 'admin' ? 'user' : 'admin';
                    _admin.updateUser(user.id!, role: nextRole);
                  },
                  icon: const Icon(Icons.admin_panel_settings_rounded, size: 14),
                  label: Text(user.role == 'admin' ? "Make User" : "Make Admin", style: const TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 8),
                // Toggle Plan
                TextButton.icon(
                  onPressed: () {
                    final nextPlan = user.plan == 'paid' ? 'free' : 'paid';
                    _admin.updateUser(user.id!, plan: nextPlan);
                  },
                  icon: const Icon(Icons.star_rounded, size: 14),
                  label: Text(user.plan == 'paid' ? "Downgrade" : "Upgrade Plan", style: const TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 8),
                // Block/Unblock toggle
                TextButton(
                  onPressed: () {
                    final nextStatus = isUserActive ? 'inactive' : 'active';
                    _admin.updateUser(user.id!, status: nextStatus);
                  },
                  child: Text(
                    isUserActive ? "Deactivate" : "Activate",
                    style: TextStyle(fontSize: 11, color: isUserActive ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // TAB 3: Billing & Pricing Configurations
  Widget _buildBillingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pricing Structure Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.primaryNav)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPriceEditCard("Premium Plan (/mo)", _admin.premiumPlanPrice, _admin.editPremiumPrice),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceEditCard("VIP Index (/mo)", _admin.vipPlanPrice, (val) => _admin.vipPlanPrice.value = val),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Billing & Payments History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.primaryNav)),
              Obx(() => Text(
                    "Total Revenue: \$${_admin.totalRevenue.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.success),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (_admin.paymentLogs.isEmpty) {
              return const Center(child: Text("No billing transactions logged."));
            }

            return Card(
              color: context.cardBg,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: context.borderColor)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _admin.paymentLogs.length,
                separatorBuilder: (context, _) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final log = _admin.paymentLogs[idx];
                  return ListTile(
                    leading: Icon(Icons.receipt_long_rounded, color: context.textSecondaryColor),
                    title: Text(log['user_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text("Date: ${log['date']}", style: const TextStyle(fontSize: 11)),
                    trailing: Text(
                      "+\$${log['amount']}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 14),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceEditCard(String title, RxDouble state, Function(double) onSave) {
    return Card(
      color: context.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: context.borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 10, color: context.textSecondaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("\$", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Expanded(
                  child: Obx(() => Text(
                        state.value.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                ),
                IconButton(
                  icon: Icon(Icons.edit_rounded, size: 16, color: context.primaryNav),
                  onPressed: () {
                    // Show prompt dialog to adjust billing
                    _showPriceEditDialog(title, state, onSave);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showPriceEditDialog(String label, RxDouble state, Function(double) onSave) {
    final textEdit = TextEditingController(text: state.value.toStringAsFixed(2));
    Get.dialog(
      AlertDialog(
        title: Text("Adjust $label"),
        content: TextField(
          controller: textEdit,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Price (USD)"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(textEdit.text);
              if (val != null && val >= 0) {
                onSave(val);
                Get.back();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // TAB 4: Diagnostics & Health (Simulated logs)
  Widget _buildDiagnosticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Server Hardware Usage", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.primaryNav)),
          const SizedBox(height: 12),
          
          // Diagnostics grid cards
          Row(
            children: [
              Expanded(
                child: _buildMetricDiagnosticsCard(
                  "CPU Usage", 
                  "${_admin.cpuUsage.value}%", 
                  Icons.developer_board_rounded,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricDiagnosticsCard(
                  "RAM Allocated", 
                  "${_admin.ramUsage.value}%", 
                  Icons.memory_rounded,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricDiagnosticsCard(
                  "Active Sessions", 
                  "${_admin.activeSessions.value}", 
                  Icons.lan_rounded,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // API feeds speeds
          const Text("Marketplaces Connection Diagnostics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Card(
            color: context.cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: context.borderColor)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _admin.simulatedApiSpeeds.length,
              separatorBuilder: (context, _) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final speed = _admin.simulatedApiSpeeds[idx];
                return ListTile(
                  title: Text(speed['platform'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text("Latency: ${speed['latency']}ms", style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.isDarkTheme ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      speed['status'] as String,
                      style: TextStyle(
                        color: context.isDarkTheme ? Colors.green.shade300 : Colors.green.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Error events
          const Text("Live System Error Log Events", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
          const SizedBox(height: 8),
          Card(
            color: Colors.grey.shade900,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _admin.simulatedErrorLogs.map((log) {
                  Color textClr = Colors.grey;
                  if (log.contains("ERROR")) textClr = Colors.red.shade300;
                  if (log.contains("WARNING")) textClr = Colors.orange.shade300;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      log,
                      style: TextStyle(fontFamily: 'Courier', fontSize: 11, color: textClr),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricDiagnosticsCard(String label, String val, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.primaryNav)),
          Text(label, style: TextStyle(fontSize: 9, color: context.textSecondaryColor)),
        ],
      ),
    );
  }
}
