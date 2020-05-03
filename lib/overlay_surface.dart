import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverlaySurface extends CustomPainter {
  Function(Offset) clickOffset;
  int selectedHomeIndex;
  Color highlightColor;
  OverlaySurface(
      {@required this.clickOffset,
      @required this.selectedHomeIndex,
      @required this.highlightColor});

  Paint _fillPaint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    var stepSize = size.width / 15;
    var homeStartOffset = stepSize * 9;
    var homeSize = stepSize * 6;

    var home;
    switch (selectedHomeIndex) {
      case 0:
        home = Rect.fromLTWH(0, 0, homeSize, homeSize);
        break;
      case 1:
       home = Rect.fromLTWH(homeStartOffset, 0, homeSize, homeSize);
        break;
      case 2:
        home =
            Rect.fromLTWH(homeStartOffset, homeStartOffset, homeSize, homeSize);
        break;
      default:
        home = Rect.fromLTWH(0, homeStartOffset, homeSize, homeSize);
    }

    _fillPaint.color = highlightColor;
    canvas.drawRect(home, _fillPaint);
  }

  @override
  bool hitTest(Offset position) {
    clickOffset(position);
    return true;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
