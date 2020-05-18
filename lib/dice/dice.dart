import 'package:flutter/material.dart';

class DicePaint extends CustomPainter {
  int _number;

  DicePaint(this._number);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(5)),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);

    var dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    var centerComponent = size.width / 2;
    var semiCenterComponent = size.width / 3.5;
    var semiComponent = size.width - size.width / 3.5;

    switch (_number) {
      case 1:
        canvas.drawCircle(
            Offset(centerComponent, centerComponent), size.width / 8, dotPaint);
        break;
      case 2:
        var radius = size.width / 10;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        break;
      case 3:
        var radius = size.width / 12;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(centerComponent, centerComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        break;
      case 4:
        var radius = size.width / 10;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiComponent), radius, dotPaint);
        break;
      case 5:
      var radius = size.width / 12;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(Offset(semiComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(centerComponent, centerComponent), radius, dotPaint);
        break;
      case 6:
      var radius = size.width / 15;
        canvas.drawCircle(
            Offset(semiComponent, centerComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, centerComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(Offset(semiComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiComponent), radius, dotPaint);
        break;
      default:
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
