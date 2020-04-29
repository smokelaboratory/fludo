import 'package:flutter/cupertino.dart';

class ClickSurface extends CustomPainter {
  Function(Offset) clickOffset;
  ClickSurface({this.clickOffset});

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool hitTest(Offset position) {
    clickOffset(position);
    return true;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
