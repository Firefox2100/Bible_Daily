import "package:flutter/material.dart";
import 'dart:math';

class CurvedShape extends StatelessWidget {
  const CurvedShape({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      child: CustomPaint(
        painter: _MyPainter(),
      ),
    );
  }
}

class _MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = Colors.indigo[900]!;

    Offset circleCenter = Offset(size.width / 2, size.height);

    Offset topLeft = const Offset(0, 0);
    Offset bottomLeft = Offset(0, size.height * 0.25);
    Offset topRight = Offset(size.width, 0);
    Offset bottomRight = Offset(size.width, size.height * 0.5);

    Offset leftCurveControlPoint = Offset(circleCenter.dx * 0.5, size.height);
    Offset rightCurveControlPoint = Offset(circleCenter.dx * 1.6, size.height);

    const arcStartAngle = 200 / 180 * pi;
    final avatarLeftPointX = circleCenter.dx + cos(arcStartAngle);
    final avatarLeftPointY = circleCenter.dy + sin(arcStartAngle);
    Offset avatarLeftPoint =
    Offset(avatarLeftPointX, avatarLeftPointY); // the left point of the arc

    const arcEndAngle = -5 / 180 * pi;
    final avatarRightPointX = circleCenter.dx + cos(arcEndAngle);
    final avatarRightPointY = circleCenter.dy + sin(arcEndAngle);
    Offset avatarRightPoint = Offset(
        avatarRightPointX, avatarRightPointY); // the right point of the arc

    Path path = Path()
      ..moveTo(topLeft.dx,
          topLeft.dy) // this move isn't required since the start point is (0,0)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..quadraticBezierTo(leftCurveControlPoint.dx, leftCurveControlPoint.dy,
          avatarLeftPoint.dx, avatarLeftPoint.dy)
      ..quadraticBezierTo(rightCurveControlPoint.dx, rightCurveControlPoint.dy,
          bottomRight.dx, bottomRight.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
