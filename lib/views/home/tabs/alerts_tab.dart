import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/alert_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/alert_model.dart';
import '../../widgets/watch_background.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  final AlertController _alertController = Get.find<AlertController>();
  
  // Active selected category matching the mockup: 'price_drop', 'new_listing', 'saved_search_update'
  String _selectedCategory = 'price_drop';

  void _triggerTestAlert() {
    _alertController.triggerSimulatedPriceDropAlert(
      "Rolex Submariner 124060",
      14800,
      13900,
    );
    Get.snackbar(
      "Alert Mocked", 
      "Simulated a price drop from \$14,800 to \$13,900. Badge updated!", 
      snackPosition: SnackPosition.TOP,
      backgroundColor: context.surfaceBg.withValues(alpha: 0.9),
      colorText: context.textPrimaryColor,
    );
  }

  // Parse alert message structure to visual fields for mockup matching
  _AlertDetails _getAlertDetails(AlertModel alert) {
    final msg = alert.message;
    
    // Default fallback
    String title = "Watch Alert";
    String imageUrl = "assets/images/8.png";
    String platform = "CHRONO24";
    String timeLabel = "2H AGO";
    String tag = "ALERT";
    double? originalPrice;
    double price = 14250.0;
    bool isPriceDrop = alert.type == 'price_drop';

    // Check specific pre-seeded cases to match mockup exactly
    if (msg.contains("Daytona")) {
      return _AlertDetails(
        title: "Rolex Daytona 116500LN",
        imageUrl: "assets/images/7.png",
        platform: "CHRONO24",
        timeLabel: "2H AGO",
        tag: "-5% DROP",
        originalPrice: 32450.0,
        price: 30820.0,
        isPriceDrop: true,
      );
    } else if (msg.contains("Nautilus")) {
      return _AlertDetails(
        title: "Patek Philippe Nautilus 5711/1A",
        imageUrl: "assets/images/2.png",
        platform: "EBAY LUXURY",
        timeLabel: "4H AGO",
        tag: "JUST LISTED",
        price: 142000.0,
        isPriceDrop: false,
      );
    } else if (msg.contains("Speedmaster Sapphire") || msg.contains("Speedmaster Hesalite") || msg.contains("Speedmaster")) {
      return _AlertDetails(
        title: "Omega Speedmaster Sapphire",
        imageUrl: "assets/images/1.png",
        platform: "WATCHFINDER",
        timeLabel: "8H AGO",
        tag: "-8% DROP",
        originalPrice: 6800.0,
        price: 6250.0,
        isPriceDrop: true,
      );
    }

    // Dynamic parsing for simulated alerts
    try {
      if (alert.type == 'price_drop') {
        final regExp = RegExp(r"dropped from \$(\d+) to \$(\d+)");
        final match = regExp.firstMatch(msg);
        if (match != null) {
          originalPrice = double.tryParse(match.group(1) ?? "");
          price = double.tryParse(match.group(2) ?? "") ?? 0.0;
        }
        
        final titleReg = RegExp(r"Alert: (.*?) price dropped");
        final tMatch = titleReg.firstMatch(msg);
        if (tMatch != null) {
          title = tMatch.group(1) ?? "Watch Model";
        }
        
        if (msg.toLowerCase().contains("chrono24")) platform = "CHRONO24";
        if (msg.toLowerCase().contains("ebay")) platform = "EBAY";
        if (msg.toLowerCase().contains("grailzee")) platform = "GRAILZEE";
        
        if (originalPrice != null && originalPrice > 0) {
          final pct = (((originalPrice - price) / originalPrice) * 100).round();
          tag = "-$pct% DROP";
        }
      } else {
        final priceReg = RegExp(r"for \$([0-9,]+)");
        final pMatch = priceReg.firstMatch(msg);
        if (pMatch != null) {
          price = double.tryParse(pMatch.group(1)?.replaceAll(",", "") ?? "") ?? 0.0;
        }
        
        final titleReg = RegExp(r"Alert: (.*?) posted");
        final tMatch = titleReg.firstMatch(msg);
        if (tMatch != null) {
          title = tMatch.group(1) ?? "Watch Model";
        }
        tag = "JUST LISTED";
        if (msg.toLowerCase().contains("grailzee")) platform = "GRAILZEE";
        if (msg.toLowerCase().contains("chrono24")) platform = "CHRONO24";
        if (msg.toLowerCase().contains("ebay")) platform = "EBAY";
      }
      
      // Select image based on brand keywords
      final lower = title.toLowerCase();
      if (lower.contains("rolex")) {
        if (lower.contains("gmt")) imageUrl = "assets/images/5.png";
        else if (lower.contains("daytona")) imageUrl = "assets/images/7.png";
        else imageUrl = "assets/images/rolex_watch.png";
      } else if (lower.contains("omega")) {
        imageUrl = "assets/images/1.png";
      } else if (lower.contains("patek")) {
        imageUrl = "assets/images/2.png";
      } else if (lower.contains("audemars") || lower.contains("royal oak")) {
        imageUrl = "assets/images/6.jpg";
      } else if (lower.contains("cartier")) {
        imageUrl = "assets/images/7.png";
      }
    } catch (_) {
      // ignore
    }

    return _AlertDetails(
      title: title,
      imageUrl: imageUrl,
      platform: platform,
      timeLabel: "JUST NOW",
      tag: tag,
      originalPrice: originalPrice,
      price: price == 0 ? 13900 : price,
      isPriceDrop: isPriceDrop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text("Alerts Feed", style: TextStyle(color: context.textPrimaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all_rounded, color: context.primaryNav),
            onPressed: () {
              _alertController.markAllAsRead();
              Get.snackbar(
                "Updated", 
                "All alerts marked as read.", 
                backgroundColor: context.surfaceBg.withValues(alpha: 0.9), 
                colorText: context.textPrimaryColor,
              );
            },
            tooltip: "Mark all as read",
          ),
        ],
      ),
      body: WatchBackground(
        showGears: false,
        showDialTicks: true,
        child: Column(
          children: [
            // Testing / Simulation Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              color: context.cardBg.withValues(alpha: 0.85),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Alert Testing:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textSecondaryColor),
                  ),
                  TextButton.icon(
                    onPressed: _triggerTestAlert,
                    icon: const Icon(Icons.bolt, size: 14, color: AppColors.warning),
                    label: Text(
                      "Trigger Price Drop Scan", 
                      style: TextStyle(fontSize: 12, color: context.primaryNav, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            // Top Filters Chips matching mockup
            _buildCategoryFilters(),
            
            // Scrollable alerts feed list
            Expanded(
              child: Obx(() {
                if (_alertController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter local alerts based on selected category
                final list = _alertController.alertsList.where((alert) {
                  if (_selectedCategory == 'price_drop') return alert.type == 'price_drop';
                  if (_selectedCategory == 'new_listing') return alert.type == 'new_listing';
                  return alert.type == 'saved_search_update' || (alert.type != 'price_drop' && alert.type != 'new_listing');
                }).toList();

                if (list.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final alert = list[index];
                    return _buildVisualAlertCard(alert);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Horizontal chips matching mockup category selector
  Widget _buildCategoryFilters() {
    final categories = [
      {"label": "Price Drops", "id": "price_drop"},
      {"label": "New Listings", "id": "new_listing"},
      {"label": "Search Updates", "id": "saved_search_update"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat["id"];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat["id"]!;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? context.primaryNav : context.chipBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cat["label"]!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : context.textSecondaryColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: context.textSecondaryColor),
            const SizedBox(height: 16),
            Text(
              "No matches found here",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              "Any alerts matching this category filter will be loaded dynamically.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.textSecondaryColor, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // Premium watch alerts card matching the mockup designs
  Widget _buildVisualAlertCard(AlertModel alert) {
    final details = _getAlertDetails(alert);
    final isNewListing = alert.type == 'new_listing';

    return Card(
      color: context.cardBg,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDarkTheme ? 0.2 : 0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Watch Image with Floating Tag
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 2.1,
                  child: Image.asset(
                    details.imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                
                // Floating status tag (e.g. -5% DROP green, JUST LISTED blue)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isNewListing ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isNewListing) ...[
                          const Icon(Icons.trending_down, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          details.tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Middle Section: Information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata: Source + Time
                  Text(
                    "${details.platform} • ${details.timeLabel}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.textSecondaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Watch Title
                  Text(
                    details.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Price comparison display
                  Row(
                    children: [
                      if (details.isPriceDrop && details.originalPrice != null) ...[
                        Text(
                          "\$${details.originalPrice!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textSecondaryColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        "\$${details.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.primaryNav,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Actions Row: Blue View button + Dismiss [X] button
                  Row(
                    children: [
                      // View deal / View listing button
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!alert.isRead) {
                                _alertController.markAsRead(alert.id!);
                              }
                              Get.snackbar(
                                "Redirecting", 
                                "Redirecting to external deal listing link...",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: context.surfaceBg.withValues(alpha: 0.9),
                                colorText: context.textPrimaryColor,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryNav,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isNewListing ? "VIEW LISTING" : "VIEW DEAL",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Dismiss Action Button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(color: context.borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close_rounded, color: context.textSecondaryColor, size: 18),
                          onPressed: () {
                            _alertController.deleteAlert(alert.id!);
                            Get.snackbar(
                              "Alert Dismissed",
                              "Notification removed from feed.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: context.surfaceBg.withValues(alpha: 0.9),
                              colorText: context.textPrimaryColor,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Inner helper class mapping alert UI elements
class _AlertDetails {
  final String title;
  final String imageUrl;
  final String platform;
  final String timeLabel;
  final String tag;
  final double? originalPrice;
  final double price;
  final bool isPriceDrop;

  _AlertDetails({
    required this.title,
    required this.imageUrl,
    required this.platform,
    required this.timeLabel,
    required this.tag,
    this.originalPrice,
    required this.price,
    required this.isPriceDrop,
  });
}
