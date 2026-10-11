import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/watch_background.dart';
import '../watch_detail_screen.dart';
import '../../../models/watch_model.dart';
import '../tabs/map_tab.dart';
import '../../search/image_search_screen.dart';
import '../traders_collections_screen.dart';
import '../../profile/my_listings_screen.dart';

class HomeTab extends StatefulWidget {
  final Function(int)? onTabChangeRequested;

  const HomeTab({super.key, this.onTabChangeRequested});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  final AuthController _auth = Get.find<AuthController>();
  final WatchSearchController _search = Get.find<WatchSearchController>();

  late AnimationController _fadeInController;
  late Animation<double> _fadeAnimation;

  // Staggered entrance for the dual marketplace banners
  late AnimationController _bannerEntranceController;
  late Animation<double> _banner1Slide;
  late Animation<double> _banner1Fade;
  late Animation<double> _banner2Slide;
  late Animation<double> _banner2Fade;

  // Continuous glow pulse on banners to keep them highlighted
  late AnimationController _glowPulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    );

    // Banner entrance: total 900ms, banner1 starts at 0ms, banner2 at 200ms
    _bannerEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _banner1Slide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _bannerEntranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _banner1Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bannerEntranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _banner2Slide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _bannerEntranceController,
        curve: const Interval(0.22, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    _banner2Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bannerEntranceController,
        curve: const Interval(0.22, 0.7, curve: Curves.easeOut),
      ),
    );

    // Start banner entrance after a short delay so user sees them animate in
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bannerEntranceController.forward();
    });

    // Continuous gentle glow pulse
    _glowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.55).animate(
      CurvedAnimation(parent: _glowPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _bannerEntranceController.dispose();
    _glowPulseController.dispose();
    super.dispose();
  }

  // Navigate to visual Image Search Screen
  void _showImageSearchMockDialog() {
    Get.to(() => const ImageSearchScreen());
  }

  void _onBrandSelect(String brand) {
    _search.executeSearch(brand);
    widget.onTabChangeRequested?.call(1); // Navigate to Search tab
  }

  @override
  Widget build(BuildContext context) {
    final String username = _auth.currentUser.value?.name ?? "Alexander";

    return Scaffold(
      body: WatchBackground(
        showDialTicks: true,
        showGears: false,
        child: SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header with greeting and avatar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Good Morning,",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                              Text(
                                username,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: context.textPrimaryColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notification Bell
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications_none_rounded, color: context.textPrimaryColor, size: 28),
                              onPressed: () => widget.onTabChangeRequested?.call(3), // Navigate to Alerts
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // Profile Avatar
                        GestureDetector(
                          onTap: () => widget.onTabChangeRequested?.call(4), // Navigate to Profile
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: const AssetImage(
                              "assets/images/8.png",
                            ),
                            backgroundColor: context.borderColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Search Text Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GestureDetector(
                      onTap: () => widget.onTabChangeRequested?.call(1),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.borderColor, width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: context.textSecondaryColor),
                            const SizedBox(width: 12),
                            Text(
                              "Search brands, models...",
                              style: TextStyle(color: context.textSecondaryColor, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Search by Image Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: InkWell(
                      onTap: _showImageSearchMockDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: context.chipBg.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt_rounded, color: context.primaryNav),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Search by image",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimaryColor),
                                  ),
                                  Text(
                                    "Find visually similar listings",
                                    style: TextStyle(fontSize: 10, color: context.textSecondaryColor),
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
                  const SizedBox(height: 24),

                  // 4. Feature Card (Editor's Pick)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 210,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage(
                                  "assets/images/1.png",
                                ),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                          ),
                        ),
                        // Dark overlay gradient
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 210,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                        // Info Text inside Banner
                        Positioned(
                          left: 20,
                          bottom: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Editor's Pick",
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Submariner Date 41mm",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Ref. 126610LN • Unworn 2024",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Brand Selection Chips (horizontal scrollable)
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildBrandChip(context, "Rolex"),
                        _buildBrandChip(context, "Omega"),
                        _buildBrandChip(context, "AP"),
                        _buildBrandChip(context, "Cartier"),
                        _buildBrandChip(context, "Patek Philippe"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 6. Market Insights Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Market Insights",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.primaryNav,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Insights Lists
                  _buildInsightTile(context, "Most Searched", "Daytona 116500LN", "Rolex", "\$28,500", "+2.4%", Colors.green),
                  _buildInsightTile(context, "Biggest Drop", "Royal Oak 15500ST", "Audemars Piguet", "\$39,200", "-1.8%", Colors.red),
                  _buildInsightTile(context, "Trending Upward", "Nautilus 5711/1A", "Patek Philippe", "\$125,000", "+5.2%", Colors.green),
                  const SizedBox(height: 28),

                  // 7. Watch Radar quick entry
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: InkWell(
                      onTap: () {
                        // Open map view in a separate screen route
                        Get.to(() => Scaffold(
                          appBar: AppBar(title: const Text("Radar Finder"), elevation: 0.5),
                          body: const MapTab(),
                        ));
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.primaryNav,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.radar_rounded, color: Colors.white, size: 32),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Watch Radar Finder",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    "Locate Authorized Dealers & Service Centers",
                                    style: TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.8), size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 8. Dual P2P Marketplace Banners (Traders Collections & Sell Watch)
                  AnimatedBuilder(
                    animation: Listenable.merge([_bannerEntranceController, _glowPulseController]),
                    builder: (context, _) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          children: [
                            // Banner 1: Traders Collections — animated entrance
                            Expanded(
                              child: Transform.translate(
                                offset: Offset(0, _banner1Slide.value),
                                child: Opacity(
                                  opacity: _banner1Fade.value,
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => const TradersCollectionsScreen());
                                    },
                                    borderRadius: BorderRadius.circular(20.r),
                                    child: Container(
                                      height: 165.h,
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF002952), Color(0xFF0F3E6C)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: const Color(0xFFCA8A04).withValues(alpha: _glowAnimation.value),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFCA8A04).withValues(alpha: _glowAnimation.value * 0.35),
                                            blurRadius: 14 + (_glowAnimation.value * 8),
                                            spreadRadius: _glowAnimation.value * 2,
                                            offset: const Offset(0, 4),
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF002952).withValues(alpha: 0.15),
                                            blurRadius: 10,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(6.w),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFCA8A04).withValues(alpha: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.storefront_rounded, color: const Color(0xFFEAB308), size: 20.w),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "Traders Collections",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            "Buy directly from private collectors.",
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.7),
                                              fontSize: 10.sp,
                                              height: 1.3,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Browse",
                                                  style: TextStyle(color: const Color(0xFFEAB308), fontWeight: FontWeight.bold, fontSize: 10.sp),
                                                ),
                                                SizedBox(width: 4.w),
                                                Icon(Icons.arrow_forward_rounded, color: const Color(0xFFEAB308), size: 10.w),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // Banner 2: Sell / List Watch — animated entrance (staggered)
                            Expanded(
                              child: Transform.translate(
                                offset: Offset(0, _banner2Slide.value),
                                child: Opacity(
                                  opacity: _banner2Fade.value,
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => const MyListingsScreen());
                                    },
                                    borderRadius: BorderRadius.circular(20.r),
                                    child: Container(
                                      height: 165.h,
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFCA8A04), Color(0xFFF59E0B)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: context.primaryNav.withValues(alpha: 0.15 + _glowAnimation.value * 0.25),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFF59E0B).withValues(alpha: _glowAnimation.value * 0.3),
                                            blurRadius: 14 + (_glowAnimation.value * 8),
                                            spreadRadius: _glowAnimation.value * 2,
                                            offset: const Offset(0, 4),
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFFCA8A04).withValues(alpha: 0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(6.w),
                                            decoration: BoxDecoration(
                                              color: context.primaryNav.withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.add_circle_outline_rounded, color: context.primaryNav, size: 20.w),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "Sell Your Watch",
                                            style: TextStyle(
                                              color: context.primaryNav,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            "List your timepieces instantly in seconds.",
                                            style: TextStyle(
                                              color: context.primaryNav.withValues(alpha: 0.7),
                                              fontSize: 10.sp,
                                              height: 1.3,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: context.primaryNav.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "List Now",
                                                  style: TextStyle(color: context.primaryNav, fontWeight: FontWeight.bold, fontSize: 10.sp),
                                                ),
                                                SizedBox(width: 4.w),
                                                Icon(Icons.arrow_forward_rounded, color: context.primaryNav, size: 10.w),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // 8. Recommended section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recommended For You",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.primaryNav),
                        ),
                        TextButton(
                          onPressed: () => widget.onTabChangeRequested?.call(1),
                          child: Text("View All", style: TextStyle(color: context.primaryNav, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Horizontal layout recommended
                  SizedBox(
                    height: 250,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildRecommendWatchCard(
                          context,
                          WatchModel(
                            brand: "Omega",
                            model: "Seamaster Diver",
                            title: "Seamaster Diver Professional Blue",
                            price: 8200.0,
                            year: 2022,
                            condition: "New",
                            location: "Germany",
                            platform: "Chrono24",
                            id: 991,
                            isSold: false,
                            timestamp: "",
                          ),
                          "41mm",
                          "assets/images/3.jpg",
                        ),
                        const SizedBox(width: 16),
                        _buildRecommendWatchCard(
                          context,
                          WatchModel(
                            brand: "Cartier",
                            model: "Tank Must",
                            title: "Tank Must Extra-Large WSTA0040",
                            price: 3900.0,
                            year: 2023,
                            condition: "Vintage",
                            location: "USA",
                            platform: "eBay",
                            id: 992,
                            isSold: false,
                            timestamp: "",
                          ),
                          "38mm",
                          "assets/images/7.png",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandChip(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: OutlinedButton(
        onPressed: () => _onBrandSelect(label),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.borderColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          foregroundColor: context.textPrimaryColor,
        ),
        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInsightTile(
    BuildContext context,
    String badge,
    String watchName,
    String brand,
    String price,
    String percent,
    Color percentColor,
  ) {
    final bool isUp = percent.startsWith("+");
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: context.textSecondaryColor, letterSpacing: 0.8),
              ),
              const SizedBox(height: 4),
              Text(
                watchName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
              ),
              Text(
                brand,
                style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: context.textPrimaryColor),
              ),
              Row(
                children: [
                  Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 14, color: percentColor),
                  const SizedBox(width: 4),
                  Text(
                    percent,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: percentColor),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRecommendWatchCard(BuildContext context, WatchModel watch, String size, String imageUrl) {
    return InkWell(
      onTap: () => Get.to(() => WatchDetailScreen(watch: watch)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor, width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.asset(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: context.cardBg, shape: BoxShape.circle),
                      child: Icon(Icons.favorite_border_rounded, size: 14, color: context.textSecondaryColor),
                    ),
                  ),
                ],
              ),
            ),
            // Specs
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? const Color(0xFF1E3A8A) : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          size,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: context.isDarkMode ? const Color(0xFF93C5FD) : Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? const Color(0xFF78350F) : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${watch.year}",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: context.isDarkMode ? const Color(0xFFFDE68A) : Colors.amber.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    watch.brand,
                    style: TextStyle(fontSize: 10, color: context.textSecondaryColor, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    watch.model,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${watch.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.primaryNav),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
