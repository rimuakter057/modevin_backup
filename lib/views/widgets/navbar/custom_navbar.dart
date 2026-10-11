import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../controllers/alert_controller.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AlertController alertController = Get.find<AlertController>();

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkTheme ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: context.borderColor,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_filled, Icons.home_outlined, "Home"),
              _buildNavItem(context, 1, Icons.search_rounded, Icons.search_rounded, "Search"),
              _buildNavItem(context, 2, Icons.favorite_rounded, Icons.favorite_border_rounded, "Saved"),
              _buildNavItem(context, 3, Icons.notifications_rounded, Icons.notifications_none_rounded, "Alerts", badgeController: alertController),
              _buildNavItem(context, 4, Icons.person_rounded, Icons.person_outline_rounded, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label, {
    AlertController? badgeController,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    color: isSelected ? context.primaryNav : context.textSecondaryColor,
                    size: 24,
                  ),
                ),
                if (badgeController != null)
                  Obx(() {
                    final count = badgeController.unreadCount.value;
                    if (count <= 0) return const SizedBox();
                    return Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? context.primaryNav : context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
