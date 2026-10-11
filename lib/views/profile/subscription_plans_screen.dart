import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../../controllers/auth_controller.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> with SingleTickerProviderStateMixin {
  final AuthController _auth = Get.find<AuthController>();
  
  late AnimationController _sparklineController;
  final List<double> _sparklineValues = [12.0, 24.0, 15.0, 36.0, 22.0, 48.0];

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _sparklineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sparklineController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(String plan) async {
    final user = _auth.currentUser.value;
    if (user == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Premium sync delay simulation
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (plan == 'paid') {
        if (user.plan == 'paid') {
          Get.snackbar(
            "Plan Active", 
            "You are already subscribed to the Elite Plan.", 
            backgroundColor: context.primaryNav, 
            colorText: context.isDarkTheme ? AppColors.backgroundDark : Colors.white
          );
        } else {
          await _auth.upgradePlan();
          Get.back();
        }
      } else {
        if (user.plan == 'free') {
          Get.snackbar(
            "Plan Active", 
            "You are already on the Standard Plan.", 
            backgroundColor: context.primaryNav, 
            colorText: context.isDarkTheme ? AppColors.backgroundDark : Colors.white
          );
        } else {
          await _auth.downgradePlan();
          Get.back();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Subscription Plans",
          style: TextStyle(color: context.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Obx(() {
            final user = _auth.currentUser.value;
            final isPremium = user?.plan == 'paid';

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title Header Entrance
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, -20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          "Choose Your Precision",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Elevate your collection strategy with institutional-grade watch market intelligence.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondaryColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 1. Standard Plan Card (Slides in from Left)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(-40 * (1 - value), 0),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: _buildStandardCard(isPremium),
                  ),
                  const SizedBox(height: 24),

                  // 2. Elite Plan Card (Slides in from Right)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(40 * (1 - value), 0),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: _buildEliteCard(!isPremium),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
          
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Card(
                  color: context.cardBg,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(context.primaryNav),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Calibrating Vault...",
                          style: TextStyle(
                            fontSize: 13, 
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStandardCard(bool isPremiumActive) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkTheme ? 0.25 : 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ENTRY TIER",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: context.textSecondaryColor,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "\$0",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "FOREVER",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textSecondaryColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Standard",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // Features
          _buildCheckRow("5 Monthly Reference Searches", true, isDark: context.isDarkTheme),
          _buildCheckRow("3 Months Historical Indexing", true, isDark: context.isDarkTheme),
          _buildCheckRow("AI Image Recognition Search", false, isDark: context.isDarkTheme),
          
          const SizedBox(height: 24),

          // Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: isPremiumActive ? () => _handleAction('free') : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.primaryNav.withValues(alpha: isPremiumActive ? 1.0 : 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isPremiumActive ? "Switch to Standard" : "Current Plan",
                style: TextStyle(
                  color: context.primaryNav.withValues(alpha: isPremiumActive ? 1.0 : 0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEliteCard(bool isUpgradeActive) {
    final Color cardColor = context.isDarkTheme ? const Color(0xFF1E3A8A) : const Color(0xFF002952);
    final Color btnBg = context.isDarkTheme ? AppColors.accent : Colors.white;
    final Color btnFg = context.isDarkTheme ? AppColors.backgroundDark : const Color(0xFF002952);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "RECOMMENDED",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "\$29.99",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "MONTHLY",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Elite Collector",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Features list
          _buildCheckRow("Unlimited Reference Searches", true, isDark: true),
          _buildCheckRow("All Time Historical Indexing", true, isDark: true),
          _buildCheckRow("AI Image Recognition Search", true, isDark: true),
          
          // Custom anim row: Market Sparklines & Trends
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Color(0xFF60A5FA)),
                    const SizedBox(width: 10),
                    const Text(
                      "Market Sparklines & Trends",
                      style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 26.0, top: 4.0, bottom: 4.0),
                  child: CustomPaint(
                    size: const Size(80, 24),
                    painter: SparklineBarPainter(
                      values: _sparklineValues,
                      animationValue: _sparklineController,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          _buildCheckRow("Auction Results Integration", true, isDark: true),
          _buildCheckRow("Personalized Portfolio Analytics", true, isDark: true),
          
          const SizedBox(height: 24),

          // Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isUpgradeActive ? () => _handleAction('paid') : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBg,
                foregroundColor: btnFg,
                disabledBackgroundColor: btnBg.withValues(alpha: 0.3),
                disabledForegroundColor: btnFg.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                isUpgradeActive ? "Upgrade to Elite" : "Current Plan",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String text, bool isChecked, {required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.cancel_outlined,
            size: 16,
            color: isChecked
                ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
                : (isDark ? Colors.white30 : Colors.grey.shade300),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isChecked 
                  ? (isDark ? Colors.white : const Color(0xFF1E293B))
                  : (isDark ? Colors.white30 : Colors.grey.shade400),
              fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw animating sparkline bars underneath the item
class SparklineBarPainter extends CustomPainter {
  final List<double> values;
  final Animation<double> animationValue;

  SparklineBarPainter({required this.values, required this.animationValue}) : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Beautiful gradient and soft glow on each bar
    final double barSpacing = 4.0;
    final int barCount = values.length;
    final double totalSpacing = barSpacing * (barCount - 1);
    final double barWidth = (size.width - totalSpacing) / barCount;
    final double maxValue = values.reduce(max);

    for (int i = 0; i < barCount; i++) {
      final double val = values[i];
      // Animating the height slightly to make it feel alive!
      final double waveFactor = 0.8 + 0.2 * sin(animationValue.value * 2 * pi + i);
      final double finalVal = val * waveFactor;
      
      final double barHeight = (finalVal / maxValue) * size.height;
      final double left = i * (barWidth + barSpacing);
      final double top = size.height - barHeight;

      final rect = Rect.fromLTWH(left, top, barWidth, barHeight);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2.5));

      // Draw shadow/glow
      final glowPaint = Paint()
        ..color = const Color(0xFF60A5FA).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawRRect(rrect.inflate(1.5), glowPaint);

      // Draw gradient fill
      final paint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF60A5FA),
            Color(0x3360A5FA),
          ],
        ).createShader(rect);

      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklineBarPainter oldDelegate) => true;
}
