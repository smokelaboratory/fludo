import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayersPainter extends CustomPainter {
  Offset playerCurrentSpot;
  Color playerColor;

  PlayersPainter(
      {@required this.playerCurrentSpot, @required this.playerColor});

  double _playerSize, _playerInnerSize, _stepSize;
  Paint _playerPaint = Paint()..style = PaintingStyle.fill;
  Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    _stepSize = size.width / 15;
    _playerSize = _stepSize / 3;
    _playerInnerSize = _playerSize / 2.5;

    _drawPlayerShape(canvas, playerCurrentSpot, playerColor);
  }

  void _drawPlayerShape(Canvas canvas, Offset pos, Color color) {
    _playerPaint.color = color;
    canvas.drawCircle(pos, _playerSize, _playerPaint);
    canvas.drawCircle(pos, _playerSize, _strokePaint);

    _playerPaint.color = Colors.white;
    canvas.drawCircle(pos, _playerInnerSize, _playerPaint);
    canvas.drawCircle(pos, _playerInnerSize, _strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) => false; //to pass touches to layer beneath
}
