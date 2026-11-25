import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// @desc 相机取景框四角（3.2.1 / 3.3.1 共用）
class ViewfinderCorners extends StatelessWidget {
  final double size;
  final Color color;

  const ViewfinderCorners({super.key, this.size = 274, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size.w, size.w),
      painter: _CornerPainter(color: color),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;

  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final arm = 44.w;
    final r = 16.w;
    final stroke = 2.5.w;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    Path corner(Offset origin, int dx, int dy) {
      final path = Path()
        ..moveTo(origin.dx + dx * arm, origin.dy)
        ..lineTo(origin.dx + dx * r, origin.dy)
        ..arcToPoint(
          Offset(origin.dx, origin.dy + dy * r),
          radius: Radius.circular(r),
          clockwise: dx * dy > 0,
        )
        ..lineTo(origin.dx, origin.dy + dy * arm);
      return path;
    }

    canvas.drawPath(corner(Offset(0, 0), 1, 1), paint);
    canvas.drawPath(corner(Offset(size.width, 0), -1, 1), paint);
    canvas.drawPath(corner(Offset(0, size.height), 1, -1), paint);
    canvas.drawPath(corner(Offset(size.width, size.height), -1, -1), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color;
}
