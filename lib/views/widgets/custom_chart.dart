import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';

class PriceTrendChart extends StatefulWidget {
  final List<double> dataPoints;
  final double averagePrice;

  const PriceTrendChart({
    super.key,
    required this.dataPoints,
    required this.averagePrice,
  });

  @override
  State<PriceTrendChart> createState() => _PriceTrendChartState();
}

class _PriceTrendChartState extends State<PriceTrendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawController;
  late Animation<double> _drawAnimation;

  String _selectedPeriod = '1Y';
  int? _touchedIndex;
  Offset? _touchPosition;

  final List<String> _periods = ['7D', '1M', '3M', '6M', '1Y', 'ALL'];

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeOutCubic,
    );
    _drawController.forward();
  }

  @override
  void dispose() {
    _drawController.dispose();
    super.dispose();
  }

  List<double> get _activePoints {
    if (widget.dataPoints.isEmpty) return [];
    final len = widget.dataPoints.length;
    switch (_selectedPeriod) {
      case '7D':
        return widget.dataPoints.sublist(max(0, len - 3));
      case '1M':
        return widget.dataPoints.sublist(max(0, len - 4));
      case '3M':
        return widget.dataPoints.sublist(max(0, len - 5));
      case '6M':
        return widget.dataPoints.sublist(max(0, len - 7));
      default:
        return widget.dataPoints;
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
      _touchedIndex = null;
      _touchPosition = null;
    });
    _drawController.reset();
    _drawController.forward();
  }

  String _formatPrice(double val) {
    return '\$${val.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    )}';
  }

  List<String> _getDateLabels() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case '7D':
        return List.generate(3, (i) {
          final d = now.subtract(Duration(days: (2 - i) * 2));
          return '${d.day} ${_monthAbbr(d.month)}';
        });
      case '1M':
        return List.generate(4, (i) {
          final d = now.subtract(Duration(days: (3 - i) * 7));
          return '${d.day} ${_monthAbbr(d.month)}';
        });
      case '3M':
        return [_monthAbbr(now.month - 2), _monthAbbr(now.month - 1), _monthAbbr(now.month)];
      case '6M':
        return List.generate(4, (i) {
          final m = now.month - 6 + (i * 2);
          return _monthAbbr(m);
        });
      case '1Y':
        return ['Jan', 'Apr', 'Jul', 'Oct', _monthAbbr(now.month)];
      default:
        return ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];
    }
  }

  String _monthAbbr(int m) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[((m - 1) % 12 + 12) % 12];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor),
        ),
        child: Center(
          child: Text(
            "No pricing trend data available",
            style: TextStyle(color: context.textSecondaryColor),
          ),
        ),
      );
    }

    final points = _activePoints;
    final labels = _getDateLabels();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkTheme ? 0.25 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Price Trend",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.chipBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline_rounded, size: 16, color: context.textSecondaryColor),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Period chips
          SizedBox(
            height: 34.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _periods.map((p) {
                  final isActive = _selectedPeriod == p;
                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: GestureDetector(
                      onTap: () => _onPeriodChanged(p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: isActive ? context.primaryNav : context.chipBg,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: isActive ? Colors.white : context.textSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Chart area
          SizedBox(
            height: 180,
            child: _AnimBuilder(
              listenable: _drawAnimation,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (ctx, constraints) {
                    return GestureDetector(
                      onPanUpdate: (details) {
                        final box = ctx.findRenderObject() as RenderBox;
                        final local = box.globalToLocal(details.globalPosition);
                        final step = constraints.maxWidth / (points.length - 1);
                        int idx = (local.dx / step).round().clamp(0, points.length - 1);
                        setState(() {
                          _touchedIndex = idx;
                          _touchPosition = local;
                        });
                      },
                      onPanEnd: (_) {
                        setState(() {
                          _touchedIndex = null;
                          _touchPosition = null;
                        });
                      },
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _AnimatedChartPainter(
                          points: points,
                          progress: _drawAnimation.value,
                          touchedIndex: _touchedIndex,
                          isDark: context.isDarkTheme,
                          themePrimary: context.primaryNav,
                          gridColor: context.isDarkTheme ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          dashColor: context.isDarkTheme ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                        ),
                        child: _touchedIndex != null && _touchPosition != null
                            ? _buildTooltip(context, constraints, points)
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Date labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((l) => Text(
              l,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(BuildContext context, BoxConstraints constraints, List<double> points) {
    if (_touchedIndex == null || _touchedIndex! >= points.length) {
      return const SizedBox.shrink();
    }

    final val = points[_touchedIndex!];
    final step = constraints.maxWidth / (points.length - 1);
    final x = _touchedIndex! * step;

    final minVal = points.reduce(min) * 0.95;
    final maxVal = points.reduce(max) * 1.05;
    final range = maxVal - minVal;
    final pctY = range == 0 ? 0.5 : (val - minVal) / range;
    final y = 180.0 - (pctY * 180.0);

    return Stack(
      children: [
        Positioned(
          left: (x - 60).clamp(0.0, constraints.maxWidth - 120),
          top: (y - 52).clamp(0.0, 130),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.isDarkTheme ? const Color(0xFF334155) : const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatPrice(val),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Animated chart painter with draw-in effect
class _AnimatedChartPainter extends CustomPainter {
  final List<double> points;
  final double progress;
  final int? touchedIndex;
  final bool isDark;
  final Color themePrimary;
  final Color gridColor;
  final Color dashColor;

  _AnimatedChartPainter({
    required this.points,
    required this.progress,
    required this.isDark,
    required this.themePrimary,
    required this.gridColor,
    required this.dashColor,
    this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    double minVal = points.reduce(min) * 0.95;
    double maxVal = points.reduce(max) * 1.05;
    double range = maxVal - minVal;
    if (range == 0) range = 1;

    final widthStep = size.width / (points.length - 1);

    // Map data to coordinates
    List<Offset> coords = [];
    for (int i = 0; i < points.length; i++) {
      final pctY = (points[i] - minVal) / range;
      final y = size.height - (pctY * size.height);
      final x = i * widthStep;
      coords.add(Offset(x, y));
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Build cubic bezier path
    final path = Path();
    path.moveTo(coords[0].dx, coords[0].dy);

    for (int i = 0; i < coords.length - 1; i++) {
      final p0 = coords[i];
      final p1 = coords[i + 1];
      final cx1 = p0.dx + (p1.dx - p0.dx) * 0.4;
      final cy1 = p0.dy;
      final cx2 = p0.dx + (p1.dx - p0.dx) * 0.6;
      final cy2 = p1.dy;
      path.cubicTo(cx1, cy1, cx2, cy2, p1.dx, p1.dy);
    }

    // Gradient fill under curve
    final fillPath = Path.from(path);
    fillPath.lineTo(coords.last.dx, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          themePrimary.withValues(alpha: 0.15 * progress),
          themePrimary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Main trend line
    final linePaint = Paint()
      ..color = themePrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
    canvas.restore();

    // End-point glow dot (animated)
    if (progress > 0.95) {
      final lastPt = coords.last;
      final dotOpacity = ((progress - 0.95) / 0.05).clamp(0.0, 1.0);

      // Outer glow
      final glowPaint = Paint()
        ..color = themePrimary.withValues(alpha: 0.15 * dotOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(lastPt, 14, glowPaint);

      // Mid ring
      glowPaint.color = themePrimary.withValues(alpha: 0.3 * dotOpacity);
      canvas.drawCircle(lastPt, 8, glowPaint);

      // Core dot
      glowPaint.color = themePrimary.withValues(alpha: dotOpacity);
      canvas.drawCircle(lastPt, 5, glowPaint);

      // White inner
      final whiteDot = Paint()
        ..color = Colors.white.withValues(alpha: dotOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(lastPt, 2.5, whiteDot);
    }

    // Touched vertical line + dot
    if (touchedIndex != null && touchedIndex! < coords.length) {
      final pt = coords[touchedIndex!];

      // Dashed vertical line
      final dashPaint = Paint()
        ..color = dashColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      double dashY = 0;
      while (dashY < size.height) {
        canvas.drawLine(
          Offset(pt.dx, dashY),
          Offset(pt.dx, (dashY + 4).clamp(0, size.height)),
          dashPaint,
        );
        dashY += 8;
      }

      // Touch indicator
      final touchGlow = Paint()
        ..color = themePrimary.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, 16, touchGlow);

      touchGlow.color = themePrimary;
      canvas.drawCircle(pt, 6, touchGlow);

      final whiteCore = Paint()..color = Colors.white..style = PaintingStyle.fill;
      canvas.drawCircle(pt, 3, whiteCore);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedChartPainter old) =>
      old.progress != progress || old.touchedIndex != touchedIndex;
}

// Helper: AnimatedBuilder alias
class _AnimBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const _AnimBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  }) : super();

  @override
  Widget build(BuildContext context) => builder(context, child);

  Animation<double> get animation => listenable as Animation<double>;
}
