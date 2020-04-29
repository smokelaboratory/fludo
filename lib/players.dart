import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayersPainter extends CustomPainter {
  List<Rect> playerCurrentSpots;
  Color playerColor;

  PlayersPainter(
      {@required this.playerCurrentSpots,
      @required this.playerColor});

  double _playerSize, _playerInnerSize, _stepSize;
  Paint _playerPaint = Paint()..style = PaintingStyle.fill;
  Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    _stepSize = size.width / 15;
    _playerSize = _stepSize / 3;
    _playerInnerSize = _playerSize / 2;

    print(playerCurrentSpots);
    for (int index = 0; index < playerCurrentSpots.length; index++)
      _drawPlayerShape(
          canvas,
          playerCurrentSpots[index] ??
              Rect.fromLTWH(0, 0, _playerSize, _playerSize),
          playerColor);
  }

  void _drawPlayerShape(Canvas canvas, Rect rect, Color color) {
    _playerPaint.color = color;
    canvas.drawCircle(rect.center, _playerSize, _playerPaint);
    canvas.drawCircle(rect.center, _playerSize, _strokePaint);

    _playerPaint.color = Colors.white;
    canvas.drawCircle(rect.center, _playerInnerSize, _playerPaint);
    canvas.drawCircle(rect.center, _playerInnerSize, _strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) {
    return false; //to pass through click below the painter
  }
}
