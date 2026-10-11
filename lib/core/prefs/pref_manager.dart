import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefManager extends GetxService {
  late SharedPreferences _prefs;

  static const String _keyOnboarded = 'onboarded';
  static const String _keyActiveUserId = 'active_user_id';
  static const String _keyActiveUserName = 'active_user_name';
  static const String _keyActiveUserRole = 'active_user_role';
  static const String _keyActiveUserPlan = 'active_user_plan';
  
  // Feature toggles controlled by admin
  static const String _keyFeatureEbay = 'feature_ebay_enabled';
  static const String _keyFeatureChrono24 = 'feature_chrono24_enabled';
  static const String _keyFeatureGrailzee = 'feature_grailzee_enabled';
  static const String _keyFeatureImageSearch = 'feature_image_search_enabled';
  static const String _keyFeatureAds = 'feature_ads_enabled';
  static const String _keyDarkMode = 'dark_mode';

  Future<PrefManager> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Onboarding
  bool get hasCompletedOnboarding => _prefs.getBool(_keyOnboarded) ?? false;
  Future<void> setCompletedOnboarding(bool completed) async {
    await _prefs.setBool(_keyOnboarded, completed);
  }

  // Session Management
  int? get activeUserId {
    final id = _prefs.getInt(_keyActiveUserId);
    return id == -1 ? null : id;
  }
  
  Future<void> setActiveUserId(int? id) async {
    await _prefs.setInt(_keyActiveUserId, id ?? -1);
  }

  String get activeUserName => _prefs.getString(_keyActiveUserName) ?? '';
  Future<void> setActiveUserName(String name) async {
    await _prefs.setString(_keyActiveUserName, name);
  }

  String get activeUserRole => _prefs.getString(_keyActiveUserRole) ?? 'user';
  Future<void> setActiveUserRole(String role) async {
    await _prefs.setString(_keyActiveUserRole, role);
  }

  String get activeUserPlan => _prefs.getString(_keyActiveUserPlan) ?? 'free';
  Future<void> setActiveUserPlan(String plan) async {
    await _prefs.setString(_keyActiveUserPlan, plan);
  }

  // Feature Toggles (Admin Controls)
  bool get ebayEnabled => _prefs.getBool(_keyFeatureEbay) ?? true;
  Future<void> setEbayEnabled(bool enabled) async {
    await _prefs.setBool(_keyFeatureEbay, enabled);
  }

  bool get chrono24Enabled => _prefs.getBool(_keyFeatureChrono24) ?? true;
  Future<void> setChrono24Enabled(bool enabled) async {
    await _prefs.setBool(_keyFeatureChrono24, enabled);
  }

  bool get grailzeeEnabled => _prefs.getBool(_keyFeatureGrailzee) ?? true;
  Future<void> setGrailzeeEnabled(bool enabled) async {
    await _prefs.setBool(_keyFeatureGrailzee, enabled);
  }

  bool get imageSearchEnabled => _prefs.getBool(_keyFeatureImageSearch) ?? true;
  Future<void> setImageSearchEnabled(bool enabled) async {
    await _prefs.setBool(_keyFeatureImageSearch, enabled);
  }

  bool get adsEnabled => _prefs.getBool(_keyFeatureAds) ?? true;
  Future<void> setAdsEnabled(bool enabled) async {
    await _prefs.setBool(_keyFeatureAds, enabled);
  }

  // Dark Mode Preference
  bool get isDarkMode => _prefs.getBool(_keyDarkMode) ?? false;
  Future<void> setDarkMode(bool enabled) async {
    await _prefs.setBool(_keyDarkMode, enabled);
  }

  // Logout clear
  Future<void> clearSession() async {
    await _prefs.remove(_keyActiveUserId);
    await _prefs.remove(_keyActiveUserName);
    await _prefs.remove(_keyActiveUserRole);
    await _prefs.remove(_keyActiveUserPlan);
  }
}
