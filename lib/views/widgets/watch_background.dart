import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';

class WatchBackground extends StatelessWidget {
  final Widget child;
  final bool? isDark;
  final bool showGears;
  final bool showDialTicks;

  const WatchBackground({
    super.key,
    required this.child,
    this.isDark,
    this.showGears = true,
    this.showDialTicks = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool resolvedIsDark = isDark ?? (Theme.of(context).brightness == Brightness.dark);
    return Stack(
      children: [
        // Premium watch face background painter
        Positioned.fill(
          child: Container(
            color: resolvedIsDark ? const Color(0xFF0F172A) : Colors.white,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: WatchThemePainter(
              isDark: resolvedIsDark,
              showGears: showGears,
              showDialTicks: showDialTicks,
            ),
          ),
        ),
        // Subtle Lottie gears rotating overlay
        if (showGears)
          Positioned(
            top: -40,
            right: -40,
            child: IgnorePointer(
              child: Opacity(
                opacity: resolvedIsDark ? 0.05 : 0.035,
                child: Lottie.asset(
                  'assets/animations/gears.json',
                  width: 240,
                  height: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}

class WatchThemePainter extends CustomPainter {
  final bool isDark;
  final bool showGears;
  final bool showDialTicks;

  WatchThemePainter({
    required this.isDark,
    required this.showGears,
    required this.showDialTicks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Color lineColor = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.4)
        : const Color(0xFF002952).withValues(alpha: 0.035);
    
    final Color accentLineColor = isDark
        ? const Color(0xFF5C93E6).withValues(alpha: 0.08)
        : const Color(0xFF5C93E6).withValues(alpha: 0.08);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final boldPaint = Paint()
      ..color = lineColor.withValues(alpha: isDark ? 0.3 : 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final accentPaint = Paint()
      ..color = accentLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Center offset of the main dial pattern (typically off-center for elegance)
    final mainDialCenter = Offset(size.width * 0.1, size.height * 0.4);

    // 1. Draw elegant Guilloche Concentric Rings
    for (int i = 1; i <= 28; i++) {
      final double radius = i * 28.0;
      canvas.drawCircle(mainDialCenter, radius, linePaint);
      if (i % 5 == 0) {
        canvas.drawCircle(mainDialCenter, radius, boldPaint);
      }
    }

    // 2. Draw Watch Face Dial Ticks (Hour and Minute index markers) around a circle
    if (showDialTicks) {
      final double dialRadius = size.width * 0.55;
      final Offset dialCenter = Offset(size.width * 0.8, size.height * 0.85);
      
      canvas.drawCircle(dialCenter, dialRadius, linePaint);
      canvas.drawCircle(dialCenter, dialRadius - 8, accentPaint);

      for (int i = 0; i < 60; i++) {
        final double angle = i * (2 * pi / 60);
        final double startDist = dialRadius - (i % 5 == 0 ? 12.0 : 6.0);
        final double endDist = dialRadius;
        
        final Offset start = Offset(
          dialCenter.dx + startDist * cos(angle),
          dialCenter.dy + startDist * sin(angle),
        );
        final Offset end = Offset(
          dialCenter.dx + endDist * cos(angle),
          dialCenter.dy + endDist * sin(angle),
        );
        
        canvas.drawLine(
          start,
          end,
          i % 5 == 0 ? boldPaint : linePaint,
        );
      }
    }

    // 3. Draw interlocked mechanical gears (cogs) in background corner
    if (showGears) {
      // Big Gear in top-right
      final gear1Center = Offset(size.width * 0.9, size.height * 0.15);
      _drawSubtleGear(canvas, gear1Center, 70.0, 20, linePaint, boldPaint);

      // Interlocking Gear top-right smaller
      final gear2Center = Offset(size.width * 0.9 - 105.0, size.height * 0.15 + 40.0);
      _drawSubtleGear(canvas, gear2Center, 45.0, 14, linePaint, boldPaint);
    }
  }

  void _drawSubtleGear(
    Canvas canvas,
    Offset center,
    double radius,
    int teethCount,
    Paint linePaint,
    Paint boldPaint,
  ) {
    canvas.drawCircle(center, radius, linePaint);
    canvas.drawCircle(center, radius - 10, linePaint);
    canvas.drawCircle(center, 8, linePaint);

    // Draw Spokes
    for (int i = 0; i < 4; i++) {
      final double angle = i * pi / 2;
      canvas.drawLine(
        Offset(center.dx + 8 * cos(angle), center.dy + 8 * sin(angle)),
        Offset(center.dx + (radius - 10) * cos(angle), center.dy + (radius - 10) * sin(angle)),
        linePaint,
      );
    }

    // Draw teeth
    for (int i = 0; i < teethCount; i++) {
      final double angle = i * 2 * pi / teethCount;
      final double toothHeight = 6.0;
      final double toothWidth = 0.08;

      final p1 = Offset(
        center.dx + radius * cos(angle - toothWidth),
        center.dy + radius * sin(angle - toothWidth),
      );
      final p2 = Offset(
        center.dx + (radius + toothHeight) * cos(angle - toothWidth * 0.6),
        center.dy + (radius + toothHeight) * sin(angle - toothWidth * 0.6),
      );
      final p3 = Offset(
        center.dx + (radius + toothHeight) * cos(angle + toothWidth * 0.6),
        center.dy + (radius + toothHeight) * sin(angle + toothWidth * 0.6),
      );
      final p4 = Offset(
        center.dx + radius * cos(angle + toothWidth),
        center.dy + radius * sin(angle + toothWidth),
      );

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..lineTo(p4.dx, p4.dy)
        ..close();

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant WatchThemePainter oldDelegate) => false;
}
