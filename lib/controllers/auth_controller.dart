import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/db/db_helper.dart';
import '../core/prefs/pref_manager.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final PrefManager _pref = Get.find<PrefManager>();
  final DbHelper _dbHelper = DbHelper();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final activeId = _pref.activeUserId;
    if (activeId != null) {
      isLoading.value = true;
      try {
        final db = await _dbHelper.database;
        final List<Map<String, dynamic>> maps = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [activeId],
        );
        if (maps.isNotEmpty) {
          final user = UserModel.fromMap(maps.first);
          if (user.isActive) {
            currentUser.value = user;
            // Keep pref in sync
            await _pref.setActiveUserRole(user.role);
            await _pref.setActiveUserPlan(user.plan);
          } else {
            // User deactivated, logout
            await logout();
          }
        } else {
          await logout();
        }
      } catch (e) {
        print("Error loading user session: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Dummy Login: Type name, choose role/plan. 
  // It checks if user exists in SQLite, creates one if not, and sets session.
  Future<bool> login(String name, String role, String plan) async {
    if (name.trim().isEmpty) name = "Guest User";
    isLoading.value = true;
    // Simulate premium watch-vault sync/auth timing delay
    await Future.delayed(const Duration(seconds: 2));
    try {
      final db = await _dbHelper.database;
      
      // Look for user by name and role
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'name = ? AND role = ?',
        whereArgs: [name, role],
      );

      UserModel user;
      if (maps.isNotEmpty) {
        user = UserModel.fromMap(maps.first);
        // If the plan changed during login selection, update it in DB
        if (user.plan != plan) {
          await db.update(
            'users',
            {'plan': plan},
            where: 'id = ?',
            whereArgs: [user.id],
          );
          user = UserModel(
            id: user.id,
            name: user.name,
            role: user.role,
            plan: plan,
            status: user.status,
          );
        }
      } else {
        // Create new user in DB
        final newUser = UserModel(
          name: name,
          role: role,
          plan: plan,
          status: 'active',
        );
        final id = await db.insert('users', newUser.toMap());
        user = UserModel(
          id: id,
          name: name,
          role: role,
          plan: plan,
          status: 'active',
        );
      }

      if (!user.isActive) {
        Get.snackbar("Access Denied", "This user account has been deactivated.");
        return false;
      }

      currentUser.value = user;
      await _pref.setActiveUserId(user.id);
      await _pref.setActiveUserName(user.name);
      await _pref.setActiveUserRole(user.role);
      await _pref.setActiveUserPlan(user.plan);
      return true;
    } catch (e) {
      print("Error in login: $e");
      Get.snackbar("Login Error", "Could not complete login: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    currentUser.value = null;
    await _pref.clearSession();
    Get.offAllNamed('/login');
  }

  // Upgrade Plan
  Future<void> upgradePlan() async {
    final user = currentUser.value;
    if (user == null || user.id == null) return;
    
    isLoading.value = true;
    try {
      final db = await _dbHelper.database;
      await db.update(
        'users',
        {'plan': 'paid'},
        where: 'id = ?',
        whereArgs: [user.id],
      );
      
      // Update local state
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        role: user.role,
        plan: 'paid',
        status: user.status,
      );
      currentUser.value = updatedUser;
      await _pref.setActiveUserPlan('paid');
      
      // Insert simulated payment log
      final nowStr = DateTime.now().toIso8601String().substring(0, 10);
      await db.insert('payment_history', {
        'user_id': user.id,
        'amount': 29.99,
        'date': nowStr,
        'plan_name': 'paid',
      });
      
      Get.snackbar("Success", "Upgraded to Premium Plan successfully!");
    } catch (e) {
      print("Upgrade error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Downgrade Plan
  Future<void> downgradePlan() async {
    final user = currentUser.value;
    if (user == null || user.id == null) return;
    
    isLoading.value = true;
    try {
      final db = await _dbHelper.database;
      await db.update(
        'users',
        {'plan': 'free'},
        where: 'id = ?',
        whereArgs: [user.id],
      );
      
      // Update local state
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        role: user.role,
        plan: 'free',
        status: user.status,
      );
      currentUser.value = updatedUser;
      await _pref.setActiveUserPlan('free');
      
      Get.snackbar("Success", "Switched to Standard Plan successfully!", backgroundColor: const Color(0xFF002952), colorText: Colors.white);
    } catch (e) {
      print("Downgrade error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
