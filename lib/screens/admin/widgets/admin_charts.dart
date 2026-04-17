import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class AdminMiniLineChart extends StatelessWidget {
  const AdminMiniLineChart({
    super.key,
    required this.values,
    this.color = BrikolikColors.primary,
    this.height = 110,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'Aucune donnee',
            style: TextStyle(color: BrikolikColors.textHint),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _LinePainter(values: values, color: color),
      ),
    );
  }
}

class AdminMiniBarChart extends StatelessWidget {
  const AdminMiniBarChart({
    super.key,
    required this.values,
    this.color = BrikolikColors.accent,
    this.height = 140,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'Aucune donnee',
            style: TextStyle(color: BrikolikColors.textHint),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _BarPainter(values: values, color: color),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final range = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final tX = values.length == 1 ? 0.0 : (i / (values.length - 1));
      final normY = (values[i] - minV) / range;
      final x = tX * size.width;
      final y = (1 - normY) * (size.height - 10) + 5;
      points.add(Offset(x, y));
    }

    final bgPaint = Paint()
      ..color = BrikolikColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // subtle grid line
    canvas.drawLine(Offset(0, size.height - 1), Offset(size.width, size.height - 1), bgPaint);

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    final fillPath = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: 0.26),
        color.withValues(alpha: 0.03),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = gradient.createShader(Offset.zero & size)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(line, strokePaint);

    final dotPaint = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(p, 2.4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = values.reduce(math.max);
    final safeMax = maxV.abs() < 0.0001 ? 1.0 : maxV;
    final gap = 8.0;
    final barW = (size.width - (values.length - 1) * gap) / values.length;

    final gridPaint = Paint()
      ..color = BrikolikColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      gridPaint,
    );

    for (var i = 0; i < values.length; i++) {
      final v = values[i].clamp(0, safeMax);
      final h = (v / safeMax) * (size.height - 12);
      final x = i * (barW + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h - 2, barW, h),
        const Radius.circular(6),
      );
      final paint = Paint()
        ..color = color.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
