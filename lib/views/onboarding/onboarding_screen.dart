import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';
import '../../core/theme/app_colors.dart';

import '../widgets/watch_background.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: controller.skip,
            child: const Text(
              "Skip",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: WatchBackground(
        showGears: true,
        showDialTicks: false,
        isDark: false,
        child: SafeArea(
          child: Column(
            children: [
              // Slide Content
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  children: [
                    _buildMarketplacesSlide(),
                    _buildTrendsSlide(),
                    _buildTrackingSlide(),
                  ],
                ),
              ),
  
              // Pager Indicator & Next Button Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
              child: Column(
                children: [
                  // Indicators
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.totalPages,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: controller.currentPage.value == index ? 24 : 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: controller.currentPage.value == index
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Obx(
                        () => Text(
                          controller.currentPage.value ==
                                  controller.totalPages - 1
                              ? "Get Started"
                              : "Next",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // SLIDE 1: Search Marketplaces
  Widget _buildMarketplacesSlide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: 280,
                height: 380,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Phone Outline Framework
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 4),
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            // Search bar mockup
                            Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Inner grid placeholder
                            Expanded(
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 0.8,
                                    ),
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Floating Product 1: eBay Watch (Tilted Slightly Counter-Clockwise)
                    Positioned(
                      top: 15,
                      left: -40,
                      child: Transform.rotate(
                        angle: -0.1, // tilt left
                        child: _buildFloatingCard(
                          platform: "eBay",
                          platformColor: AppColors.ebay,
                          watchName: "Classic Silver",
                          price: "\$4,250",
                          imageUrl:
                              "assets/images/4.jpg",
                        ),
                      ),
                    ),
                    // Floating Product 2: Grailzee Watch (Tilted Slightly Clockwise)
                    Positioned(
                      top: 120,
                      right: -35,
                      child: Transform.rotate(
                        angle: 0.08, // tilt right
                        child: _buildFloatingCard(
                          platform: "Grailzee",
                          platformColor: AppColors.grailzee,
                          watchName: "Gold Chrono",
                          price: "\$12,800",
                          imageUrl:
                              "assets/images/rolex_watch.png",
                        ),
                      ),
                    ),
                    // Floating Product 3: Chrono24 Watch (Tilted Counter-Clockwise)
                    Positioned(
                      bottom: 40,
                      left: -20,
                      child: Transform.rotate(
                        angle: -0.06, // tilt left
                        child: _buildFloatingCard(
                          platform: "Chrono24",
                          platformColor: AppColors.chrono24,
                          watchName: "Steel Dress",
                          price: "\$8,900",
                          imageUrl:
                              "assets/images/5.png",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Text(
            "Search marketplaces",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "Find luxury watches in one place.",
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // SLIDE 2: Compare Prices & Market Index
  Widget _buildTrendsSlide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 380,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with index name and percent
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "MARKET INDEX",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Luxury 50",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "+12.4%",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Graph Area & Overlap Watch Card
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Vector Trend Line graph
                          Positioned.fill(
                            child: CustomPaint(painter: MiniTrendPainter()),
                          ),

                          // Overlapping details cards
                          // 1. GMT watch thumbnail card left
                          Positioned(
                            top: 10,
                            left: -10,
                            child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      "assets/images/rolex_watch.png",
                                      height: 60,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "GMT-Master II",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    "\$18,450",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 2. High Price label
                          Positioned(
                            top: 12,
                            right: 0,
                            child: _buildValueIndicator("High", "\$42,500"),
                          ),

                          // 3. Avg Price label
                          Positioned(
                            top: 95,
                            left: 100,
                            child: _buildValueIndicator(
                              "Avg. Market",
                              "\$36,800",
                            ),
                          ),

                          // 4. Low Price label
                          Positioned(
                            bottom: 60,
                            left: 0,
                            child: _buildValueIndicator("Low", "\$31,200"),
                          ),

                          // 5. New Peak bottom banner
                          Positioned(
                            bottom: -5,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      "assets/images/5.png",
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "New Peak",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          "\$28,450",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(
                                    "↗12.4%",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Text(
            "Compare prices",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "See market trends instantly.",
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // SLIDE 3: Never Miss the Right Listing (Using local assets rolex_watch.png)
  Widget _buildTrackingSlide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: 380,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Concentric Circular Faint Background Rings (Matching mockup screenshot)
                    Positioned.fill(
                      child: CustomPaint(painter: ConcentricCircularPainter()),
                    ),

                    // High-quality local image of Rolex Watch
                    SizedBox(
                      height: 400,
                      child: Image.asset(
                        'assets/images/rolex_watch.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.watch_outlined,
                              size: 150,
                              color: AppColors.primary,
                            ),
                      ),
                    ),

                    // New Listing Alert Badge (Top Right)
                    Positioned(
                      top: 40,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "NEW LISTING",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Market Index Drop Badge (Top Left)
                    Positioned(
                      top: 60,
                      left: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "MARKET INDEX",
                              style: TextStyle(
                                fontSize: 8,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "-\$550",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "4.2%",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Volatility low indicator (Bottom Left)
                    Positioned(
                      bottom: 80,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 3 dots representation
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "VOLATILITY LOW",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Live tracking overlay details (Bottom Right)
                    Positioned(
                      bottom: 50,
                      right: 10,
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "LIVE TRACKING",
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Submariner",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              "124060",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Text(
            "Never miss the right listing",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "Track saved every listings.",
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Common floating card maker for marketplace items
  Widget _buildFloatingCard({
    required String platform,
    required Color platformColor,
    required String watchName,
    required String price,
    required String imageUrl,
  }) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badged header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: platformColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                platform,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: platformColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imageUrl,
              height: 70,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          // Price
          Text(
            price,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          // Name skeleton lines
          Container(height: 4, width: 60, color: Colors.grey.shade200),
          const SizedBox(height: 2),
          Container(height: 4, width: 40, color: Colors.grey.shade200),
        ],
      ),
    );
  }

  // Small badge helper
  Widget _buildValueIndicator(String label, String val) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            val,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Onboarding Slide 2 Line Chart
class MiniTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accent.withOpacity(0.15),
          AppColors.accent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    // Smooth Bezier cubic line
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.75,
      size.width * 0.45,
      size.height * 0.45,
      size.width * 0.60,
      size.height * 0.52,
    );
    path.cubicTo(
      size.width * 0.75,
      size.height * 0.58,
      size.width * 0.85,
      size.height * 0.35,
      size.width,
      size.height * 0.38,
    );

    // Draw the gradient fill under curve
    final pathFill = Path.from(path);
    pathFill.lineTo(size.width, size.height * 0.85);
    pathFill.lineTo(0, size.height * 0.85);
    pathFill.close();
    canvas.drawPath(pathFill, paintFill);

    // Draw the line itself
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Onboarding Slide 3 Concentric Rings Background (Matching mockup screenshot)
class ConcentricCircularPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9)
          .withOpacity(0.8) // very faint gray-blue lines
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw 3 concentric rings extending outward
    canvas.drawCircle(center, 70, paint);
    canvas.drawCircle(center, 110, paint);
    canvas.drawCircle(center, 150, paint);
  }

  @override
  bool shouldRepaint(covariant ConcentricCircularPainter oldDelegate) => false;
}
