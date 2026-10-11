import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import 'change_password_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  void _showMockDialog(BuildContext context, String title) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: context.surfaceBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: context.primaryNav),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              "This is a demonstration section for $title. In a production environment, this would load the full terms, privacy guidelines, or company details from the server API.",
              style: TextStyle(fontSize: 14.sp, color: context.textSecondaryColor, height: 1.5),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Account Settings",
          style: TextStyle(color: context.primaryNav, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.primaryNav),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: context.borderColor),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Change Password",
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: context.textSecondaryColor),
                    onTap: () => Get.to(() => const ChangePasswordScreen()),
                  ),
                  Divider(height: 1, indent: 16.w, endIndent: 16.w),
                  ListTile(
                    title: Text(
                      "Terms of Services",
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: context.textSecondaryColor),
                    onTap: () => _showMockDialog(context, "Terms of Services"),
                  ),
                  Divider(height: 1, indent: 16.w, endIndent: 16.w),
                  ListTile(
                    title: Text(
                      "Privacy Policy",
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: context.textSecondaryColor),
                    onTap: () => _showMockDialog(context, "Privacy Policy"),
                  ),
                  Divider(height: 1, indent: 16.w, endIndent: 16.w),
                  ListTile(
                    title: Text(
                      "About us",
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: context.textSecondaryColor),
                    onTap: () => _showMockDialog(context, "About us"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

