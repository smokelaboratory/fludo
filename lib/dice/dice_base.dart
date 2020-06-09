import 'dart:math';

import 'package:flutter/material.dart';

class DiceBasePainter extends CustomPainter {
  double _startAngle;

  DiceBasePainter(this._startAngle);

  @override
  void paint(Canvas canvas, Size size) {
    var radius = size.width;

    var center = Offset(size.width / 2, size.width / 2);
    var acrAngle = 30 * pi / 180;

    for (int arcIndex = 0; arcIndex < 12; arcIndex++) {
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          _startAngle,
          acrAngle,
          false,
          Paint()
            ..color = arcIndex % 2 == 0 ? Colors.orange : Colors.white
            ..strokeWidth = 7
            ..style = PaintingStyle.stroke);

      _startAngle += acrAngle;
    }

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.orangeAccent
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
