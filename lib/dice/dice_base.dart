import 'package:flutter/material.dart';

class DiceBasePainter extends CustomPainter {
  final double _radius;

  DiceBasePainter(this._radius);

  @override
  void paint(Canvas canvas, Size size) {
    var center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(
        center,
        _radius,
        Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10);

    canvas.drawCircle(
        center,
        _radius,
        Paint()
          ..color = Colors.orangeAccent
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
