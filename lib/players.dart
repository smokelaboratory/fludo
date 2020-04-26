import 'package:fludo/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayersPainter extends CustomPainter {
  Rect rect;
  Function(List<Rect>) click;

  PlayersPainter(this.rect, this.click);

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

    _calculatePlayerTracks();

    // _anim = Tween(begin: _playerTracks[0][0], end: _playerTracks[0][0])
    // .animate(_animCont);

    _drawPlayerShape(
        canvas,
        rect ?? Rect.fromLTWH(0, 0, _playerSize, _playerSize),
        AppColors.player1);

    // for (int i = 0; i < _playerTracks[2].length; i++)
    // _drawPlayerShape(canvas, _playerTracks[2][i], AppColors.player1);
  }

  void _calculatePlayerTracks() {
    // canvas.save();
    for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
      List<Rect> playerTrack = List();

      Rect prevRect;
      Offset prevOffset;
      for (int stepIndex = 0; stepIndex < 57; stepIndex++) {
        if (stepIndex == 0) {
          var offset = _stepSize / 2;
          prevOffset = Offset(_stepSize + offset, _homeSize + offset);
        } else if (stepIndex < 5 ||
            stepIndex > 50 ||
            stepIndex > 18 && stepIndex < 24 ||
            stepIndex > 10 && stepIndex < 13)
          prevOffset =
              Offset(prevRect.center.dx + _stepSize, prevRect.center.dy);
        else if (stepIndex == 5)
          prevOffset = Offset(
              prevRect.center.dx + _stepSize, prevRect.center.dy - _stepSize);
        else if (stepIndex < 11 ||
            stepIndex > 38 && stepIndex < 44 ||
            stepIndex == 50)
          prevOffset =
              Offset(prevRect.center.dx, prevRect.center.dy - _stepSize);
        else if (stepIndex < 18 ||
            stepIndex > 31 && stepIndex < 37 ||
            stepIndex > 18 && stepIndex < 26)
          prevOffset =
              Offset(prevRect.center.dx, prevRect.center.dy + _stepSize);
        else if (stepIndex == 18)
          prevOffset = Offset(
              prevRect.center.dx + _stepSize, prevRect.center.dy + _stepSize);
        else if (stepIndex < 31 ||
            stepIndex > 31 && stepIndex < 39 ||
            stepIndex > 44 && stepIndex < 50)
          prevOffset =
              Offset(prevRect.center.dx - _stepSize, prevRect.center.dy);
        else if (stepIndex == 31)
          prevOffset = Offset(
              prevRect.center.dx - _stepSize, prevRect.center.dy + _stepSize);
        else if (stepIndex == 44)
          prevOffset = Offset(
              prevRect.center.dx - _stepSize, prevRect.center.dy - _stepSize);

        prevRect = Rect.fromCenter(
            center: prevOffset, width: _stepSize, height: _stepSize);
        playerTrack.add(prevRect);
      }

      // canvas.translate(_canvasCenter, _canvasCenter);
      // canvas.rotate(pi / 2);
      // canvas.translate(-_canvasCenter, -_canvasCenter);

      _playerTracks.add(playerTrack);
    }
    // canvas.restore();
  }

  @override
  bool hitTest(Offset position) {
    click(_playerTracks[0]);
    return super.hitTest(position);
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
}
