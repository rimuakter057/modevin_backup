import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/map_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/org_marker_model.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with SingleTickerProviderStateMixin {
  final MapController _mapController = Get.put(MapController());
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    // Rotate sweep once every 4 seconds
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBg,
      appBar: AppBar(
        title: const Text("Radar Finder", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.splashBg,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              _radarController.forward(from: 0);
              _radarController.repeat();
              _mapController.deselect();
              Get.snackbar("Scanning Radar", "Updating local watch provider nodes...", colorText: Colors.white, snackPosition: SnackPosition.TOP);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Subheader details
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Organizations Map: Service Centers & Authorized Dealers near you",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Radar area
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double radius = min(constraints.maxWidth, constraints.maxHeight) / 2;
                      return Stack(
                        children: [
                          // Radial lines and rotating sweeping glow
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _radarController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: RadarSweepPainter(_radarController.value * 2 * pi),
                                );
                              },
                            ),
                          ),
                          
                          // Intersecting pins
                          ..._mapController.providers.map((prov) => _buildRadarPin(prov, radius)),
                          
                          // Core center pulse
                          Center(
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(color: Colors.white54, blurRadius: 10, spreadRadius: 2)
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          // Selection Detail Panel (Overlay Card at bottom)
          Obx(() {
            final prov = _mapController.selectedProvider.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: prov == null ? 0 : 155,
              width: double.infinity,
              curve: Curves.easeInOut,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: prov == null 
                  ? const SizedBox() 
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prov.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: prov.type == 'service_center' 
                                      ? Colors.blue.shade50 
                                      : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  prov.type == 'service_center' ? "Repair Hub" : "Retailer",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: prov.type == 'service_center' 
                                        ? Colors.blue.shade700 
                                        : Colors.amber.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(prov.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(prov.phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              const Spacer(),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onPressed: () {
                                  Get.snackbar("Dialing Center", "Calling ${prov.name}...");
                                },
                                icon: const Icon(Icons.call_rounded, size: 14),
                                label: const Text("Call", style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            );
          }),
        ],
      ),
    );
  }

  // Draw a pin relative to radar width/height
  Widget _buildRadarPin(OrgMarkerModel prov, double radius) {
    // Position coordinates based on center + dx/dy offsets
    final double left = radius + (prov.dx * radius) - 16;
    final double top = radius + (prov.dy * radius) - 16;

    return Positioned(
      left: left,
      top: top,
      child: Obx(() {
        final isSelected = _mapController.selectedProvider.value?.id == prov.id;
        return GestureDetector(
          onTap: () {
            _mapController.selectProvider(prov);
          },
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dot glow ring
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 24 : 14,
                  height: isSelected ? 24 : 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: prov.type == 'service_center' 
                        ? AppColors.accent.withOpacity(0.4) 
                        : Colors.amber.withOpacity(0.4),
                  ),
                ),
                // Core point
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: prov.type == 'service_center' 
                        ? AppColors.accent 
                        : Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Custom Painter for Radar Sweep & Radial Rings
class RadarSweepPainter extends CustomPainter {
  final double sweepAngle;

  RadarSweepPainter(this.sweepAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;

    final ringsPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw Concentric Rings
    canvas.drawCircle(center, maxRadius, ringsPaint);
    canvas.drawCircle(center, maxRadius * 0.75, ringsPaint);
    canvas.drawCircle(center, maxRadius * 0.50, ringsPaint);
    canvas.drawCircle(center, maxRadius * 0.25, ringsPaint);

    // Draw Cross-hair lines
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), ringsPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), ringsPaint);

    // Draw sweeping green glow sector path
    final sweepPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: 2 * pi,
        colors: [
          Colors.transparent,
          AppColors.accent.withOpacity(0.2),
          AppColors.accent.withOpacity(0.0),
        ],
        stops: const [0.0, 0.95, 1.0],
        transform: GradientRotation(sweepAngle - 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawCircle(center, maxRadius, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant RadarSweepPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle;
  }
}
