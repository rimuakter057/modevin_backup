import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/prefs/pref_manager.dart';

class OnboardingController extends GetxController {
  final PrefManager _pref = Get.find<PrefManager>();
  final PageController pageController = PageController();
  
  final RxInt currentPage = 0.obs;
  final int totalPages = 3;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  void skip() {
    finishOnboarding();
  }

  Future<void> finishOnboarding() async {
    await _pref.setCompletedOnboarding(true);
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
