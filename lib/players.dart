import 'package:fludo/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PlayersPainter extends CustomPainter {
  List<List<Rect>> _playerTracks = List();

  double _playerSize, _playerInnerSize, _homeSize, _stepSize, _canvasCenter;
  Paint _playerPaint = Paint()..style = PaintingStyle.fill;
  Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    _stepSize = size.width / 15;
    _homeSize = _stepSize * 6;
    _canvasCenter = size.width / 2;
    _playerSize = _stepSize / 3;
    _playerInnerSize = _playerSize / 2;

    _calculatePlayerTracks(canvas);

    for (int i = 0; i < _playerTracks[0].length; i++)
      _drawPlayerShape(canvas, _playerTracks[0][i], AppColors.player2);
  }

  void _calculatePlayerTracks(Canvas canvas) {
    
    for (int playerIndex = 0; playerIndex < 3; playerIndex++) {
      List<Rect> playerTrack = List();


      canvas.translate(_canvasCenter, _canvasCenter);
      canvas.rotate(pi/2);
      canvas.translate(-_canvasCenter, -_canvasCenter);
      canvas.save();

      Rect prevRect;
      for (int stepIndex = 0; stepIndex < 11; stepIndex++) {
        if (stepIndex == 0) {
          prevRect = Rect.fromLTWH(_stepSize, _homeSize, _stepSize, _stepSize);
          playerTrack.add(prevRect);
        } else if (stepIndex < 5) {
          prevRect = Rect.fromCenter(
              center:
                  Offset(prevRect.center.dx + _stepSize, prevRect.center.dy),
              width: _stepSize,
              height: _stepSize);
          playerTrack.add(prevRect);
        } else if (stepIndex == 5) {
          prevRect = Rect.fromCenter(
              center: Offset(prevRect.center.dx + _stepSize,
                  prevRect.center.dy - _stepSize),
              width: _stepSize,
              height: _stepSize);
          playerTrack.add(prevRect);
        } else if (stepIndex < 11) {
          prevRect = Rect.fromCenter(
              center:
                  Offset(prevRect.center.dx, prevRect.center.dy - _stepSize),
              width: _stepSize,
              height: _stepSize);
          playerTrack.add(prevRect);
        } else if (stepIndex < 15) {
        } else if (stepIndex < 21) {}
      }
      _playerTracks.add(playerTrack);

    
    }
  }

  void _drawPlayers(Canvas canvas) {}

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
}
