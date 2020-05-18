import 'package:fludo/util/colors.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class BoardPainter extends CustomPainter {
  Function(List<List<List<Rect>>>) trackCalculationListener;

  BoardPainter({@required this.trackCalculationListener});

  double _stepSize, _homeStartOffset, _homeSize, _canvasCenter;
  List<List<Offset>> _homeSpotsList = List();

  Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    _stepSize = size.width / 15;
    _homeStartOffset = _stepSize * 9;
    _homeSize = _stepSize * 6;
    _canvasCenter = size.width / 2;

    _drawHome(canvas, size);

    _drawDestination(canvas, size);

    _drawSteps(canvas, size);

    _calculatePlayerTracks();

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void _calculatePlayerTracks() {
    Rect prevRect;
    Offset prevOffset;

    /**
     * Player 1 track
     */
    List<Rect> playerOneTrack = List();
    for (int stepIndex = 0; stepIndex < 57; stepIndex++) {
      if (stepIndex == 0) {
        var offset = _stepSize / 2;
        prevOffset = Offset(_stepSize + offset, _homeSize + offset);
      } else if (stepIndex < 5 ||
          stepIndex > 50 ||
          stepIndex > 18 && stepIndex < 24 ||
          stepIndex > 10 && stepIndex < 13)
        prevOffset = Offset(prevRect.center.dx + _stepSize, prevRect.center.dy);
      else if (stepIndex == 5)
        prevOffset = Offset(
            prevRect.center.dx + _stepSize, prevRect.center.dy - _stepSize);
      else if (stepIndex < 11 ||
          stepIndex > 38 && stepIndex < 44 ||
          stepIndex == 50)
        prevOffset = Offset(prevRect.center.dx, prevRect.center.dy - _stepSize);
      else if (stepIndex < 18 ||
          stepIndex > 31 && stepIndex < 37 ||
          stepIndex > 18 && stepIndex < 26)
        prevOffset = Offset(prevRect.center.dx, prevRect.center.dy + _stepSize);
      else if (stepIndex == 18)
        prevOffset = Offset(
            prevRect.center.dx + _stepSize, prevRect.center.dy + _stepSize);
      else if (stepIndex < 31 ||
          stepIndex > 31 && stepIndex < 39 ||
          stepIndex > 44 && stepIndex < 50)
        prevOffset = Offset(prevRect.center.dx - _stepSize, prevRect.center.dy);
      else if (stepIndex == 31)
        prevOffset = Offset(
            prevRect.center.dx - _stepSize, prevRect.center.dy + _stepSize);
      else if (stepIndex == 44)
        prevOffset = Offset(
            prevRect.center.dx - _stepSize, prevRect.center.dy - _stepSize);

      prevRect = Rect.fromCenter(
          center: prevOffset, width: _stepSize, height: _stepSize);
      playerOneTrack.add(prevRect);
    }

    /**
     * Player 2 track
     */
    List<Rect> playerTwoTrack = List();

    playerTwoTrack.addAll(playerOneTrack.sublist(13, 51));
    prevRect = playerTwoTrack.last;
    playerTwoTrack.add(Rect.fromCenter(
        center: Offset(prevRect.center.dx, prevRect.center.dy - _stepSize),
        width: _stepSize,
        height: _stepSize));
    playerTwoTrack.addAll(playerOneTrack.sublist(0, 12));

    for (int stepIndex = 0; stepIndex < 6; stepIndex++) {
      prevRect = playerTwoTrack.last;
      playerTwoTrack.add(Rect.fromCenter(
          center: Offset(prevRect.center.dx, prevRect.center.dy + _stepSize),
          width: _stepSize,
          height: _stepSize));
    }

    /**
     * Player 3 track
     */
    List<Rect> playerThreeTrack = List();

    playerThreeTrack.addAll(playerTwoTrack.sublist(13, 51));
    prevRect = playerThreeTrack.last;
    playerThreeTrack.add(Rect.fromCenter(
        center: Offset(prevRect.center.dx + _stepSize, prevRect.center.dy),
        width: _stepSize,
        height: _stepSize));
    playerThreeTrack.addAll(playerTwoTrack.sublist(0, 12));

    for (int stepIndex = 0; stepIndex < 6; stepIndex++) {
      prevRect = playerThreeTrack.last;
      playerThreeTrack.add(Rect.fromCenter(
          center: Offset(prevRect.center.dx - _stepSize, prevRect.center.dy),
          width: _stepSize,
          height: _stepSize));
    }

    /**
     * Player 4 track
     */
    List<Rect> playerFourTrack = List();

    playerFourTrack.addAll(playerThreeTrack.sublist(13, 51));
    prevRect = playerFourTrack.last;
    playerFourTrack.add(Rect.fromCenter(
        center: Offset(prevRect.center.dx, prevRect.center.dy + _stepSize),
        width: _stepSize,
        height: _stepSize));
    playerFourTrack.addAll(playerThreeTrack.sublist(0, 12));

    for (int stepIndex = 0; stepIndex < 6; stepIndex++) {
      prevRect = playerFourTrack.last;
      playerFourTrack.add(Rect.fromCenter(
          center: Offset(prevRect.center.dx, prevRect.center.dy - _stepSize),
          width: _stepSize,
          height: _stepSize));
    }

    /**
     * Add spots with tracks
     */
    List<List<List<Rect>>> _playerTracks = List();
    for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
      List<List<Rect>> playerTrack = List();

      for (int spotIndex = 0;
          spotIndex < _homeSpotsList[playerIndex].length;
          spotIndex++) {
        List<Rect> track = List();

        track.add(Rect.fromCenter(
            center: _homeSpotsList[playerIndex][spotIndex],
            width: _stepSize,
            height: _stepSize));

        switch (playerIndex) {
          case 0:
            track.addAll(playerOneTrack);
            break;
          case 1:
            track.addAll(playerTwoTrack);
            break;
          case 2:
            track.addAll(playerThreeTrack);
            break;
          case 3:
            track.addAll(playerFourTrack);
            break;
          default:
        }

        playerTrack.add(track);
      }
      _playerTracks.add(playerTrack);
    }

    trackCalculationListener(_playerTracks);
  }

  void _drawHome(Canvas canvas, Size size) {
    /**
     * Draw home base
     */
    _fillPaint.color = AppColors.home1;
    var home1 = Rect.fromLTWH(0, 0, _homeSize, _homeSize);
    canvas.drawRect(home1, _fillPaint);
    canvas.drawRect(home1, _strokePaint);

    _fillPaint.color = AppColors.home2;
    var home2 = Rect.fromLTWH(_homeStartOffset, 0, _homeSize, _homeSize);
    canvas.drawRect(home2, _fillPaint);
    canvas.drawRect(home2, _strokePaint);

    _fillPaint.color = AppColors.home3;
    var home3 =
        Rect.fromLTWH(_homeStartOffset, _homeStartOffset, _homeSize, _homeSize);
    canvas.drawRect(home3, _fillPaint);
    canvas.drawRect(home3, _strokePaint);

    _fillPaint.color = AppColors.home4;
    var home4 = Rect.fromLTWH(0, _homeStartOffset, _homeSize, _homeSize);
    canvas.drawRect(home4, _fillPaint);
    canvas.drawRect(home4, _strokePaint);

    /**
     * Draw inner home
     */
    var innerHomeSize = _homeSize - 2 * _stepSize;

    _fillPaint.color = Colors.white;
    var innerHome1 = Rect.fromLTWH(home1.left + _stepSize,
        home1.top + _stepSize, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome1, _fillPaint);
    canvas.drawRect(innerHome1, _strokePaint);

    var innerHome2 = Rect.fromLTWH(home2.left + _stepSize,
        home2.top + _stepSize, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome2, _fillPaint);
    canvas.drawRect(innerHome2, _strokePaint);

    var innerHome3 = Rect.fromLTWH(home3.left + _stepSize,
        home3.top + _stepSize, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome3, _fillPaint);
    canvas.drawRect(innerHome3, _strokePaint);

    var innerHome4 = Rect.fromLTWH(home4.left + _stepSize,
        home4.top + _stepSize, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome4, _fillPaint);
    canvas.drawRect(innerHome4, _strokePaint);

    /**
     * Draw spawn spots
     */
    _drawSpawnSpots(canvas, innerHome1, AppColors.home1);
    _drawSpawnSpots(canvas, innerHome2, AppColors.home2);
    _drawSpawnSpots(canvas, innerHome3, AppColors.home3);
    _drawSpawnSpots(canvas, innerHome4, AppColors.home4);
  }

  void _drawSpawnSpots(Canvas canvas, Rect innerHome, Color color) {
    List<Offset> spotList = List();

    _fillPaint.color = color;
    var spotOffsetOne = innerHome.width / 4;
    var spotOffsetTwo = 3 * spotOffsetOne;
    double spotRadius = spotOffsetOne / 2;

    canvas.save();
    canvas.translate(innerHome.left, innerHome.top);

    var spot1 = Offset(spotOffsetOne, spotOffsetOne);
    canvas.drawCircle(spot1, spotRadius, _fillPaint);
    canvas.drawCircle(spot1, spotRadius, _strokePaint);

    var spot2 = Offset(spotOffsetTwo, spotOffsetOne);
    canvas.drawCircle(spot2, spotRadius, _fillPaint);
    canvas.drawCircle(spot2, spotRadius, _strokePaint);

    var spot3 = Offset(spotOffsetOne, spotOffsetTwo);
    canvas.drawCircle(spot3, spotRadius, _fillPaint);
    canvas.drawCircle(spot3, spotRadius, _strokePaint);

    var spot4 = Offset(spotOffsetTwo, spotOffsetTwo);
    canvas.drawCircle(spot4, spotRadius, _fillPaint);
    canvas.drawCircle(spot4, spotRadius, _strokePaint);

    canvas.restore();

    /**
     * Spots coordinate calculation
     */
    var left = innerHome.left + spotOffsetOne;
    var right = innerHome.left + spotOffsetTwo;
    var up = innerHome.top + spotOffsetOne;
    var down = innerHome.top + spotOffsetTwo;

    spotList.add(Offset(left, up));
    spotList.add(Offset(right, up));
    spotList.add(Offset(right, down));
    spotList.add(Offset(left, down));

    _homeSpotsList.add(spotList);
  }

  void _drawDestination(Canvas canvas, Size size) {
    _fillPaint.color = AppColors.home1;
    var redDestination = Path()
      ..moveTo(_canvasCenter, _canvasCenter)
      ..lineTo(_homeSize, _homeStartOffset)
      ..lineTo(_homeSize, _homeSize)
      ..close();
    canvas.drawPath(redDestination, _fillPaint);
    canvas.drawPath(redDestination, _strokePaint);

    _fillPaint.color = AppColors.home2;
    var greenDestination = Path()
      ..moveTo(_canvasCenter, _canvasCenter)
      ..lineTo(_homeSize, _homeSize)
      ..lineTo(_homeStartOffset, _homeSize)
      ..close();
    canvas.drawPath(greenDestination, _fillPaint);
    canvas.drawPath(greenDestination, _strokePaint);

    _fillPaint.color = AppColors.home3;
    var yellowDestination = Path()
      ..moveTo(_canvasCenter, _canvasCenter)
      ..lineTo(_homeStartOffset, _homeSize)
      ..lineTo(_homeStartOffset, _homeStartOffset)
      ..close();
    canvas.drawPath(yellowDestination, _fillPaint);
    canvas.drawPath(yellowDestination, _strokePaint);

    _fillPaint.color = AppColors.home4;
    var blueDestination = Path()
      ..moveTo(_canvasCenter, _canvasCenter)
      ..lineTo(_homeSize, _homeStartOffset)
      ..lineTo(_homeStartOffset, _homeStartOffset)
      ..close();
    canvas.drawPath(blueDestination, _fillPaint);
    canvas.drawPath(blueDestination, _strokePaint);
  }

  void _drawSteps(Canvas canvas, Size size) {
    double verticalOffset;

    var arrowPaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int homeIndex = 0; homeIndex < 4; homeIndex++) {
      verticalOffset = _homeSize;
      switch (homeIndex) {
        case 0:
          _fillPaint.color = AppColors.home1;
          break;
        case 1:
          _fillPaint.color = AppColors.home2;
          break;
        case 2:
          _fillPaint.color = AppColors.home3;
          break;
        default:
          _fillPaint.color = AppColors.home4;
          break;
      }

      for (int pos = 0; pos < 6; pos++) {
        var unit = Rect.fromLTWH(
            pos * _stepSize, verticalOffset, _stepSize, _stepSize);

        if (pos == 1) canvas.drawRect(unit, _fillPaint);

        canvas.drawRect(unit, _strokePaint);
      }

      verticalOffset += _stepSize;
      for (int pos = 0; pos < 6; pos++) {
        var unit = Rect.fromLTWH(
            pos * _stepSize, verticalOffset, _stepSize, _stepSize);

        if (pos > 0)
          canvas.drawRect(unit, _fillPaint);
        else {
          var arrowPadding = unit.width / 4;
          var arrowWingGap = arrowPadding / 1.5;
          var arrowTip =
              Offset(unit.right - arrowPadding, unit.bottom - unit.height / 2);
          arrowPaint..color = _fillPaint.color;

          canvas.drawPath(
              Path()
                ..moveTo(unit.left + arrowPadding, arrowTip.dy)
                ..lineTo(arrowTip.dx, arrowTip.dy)
                ..lineTo(arrowTip.dx - arrowWingGap, arrowTip.dy - arrowWingGap)
                ..moveTo(arrowTip.dx - arrowWingGap, arrowTip.dy + arrowWingGap)
                ..lineTo(arrowTip.dx, arrowTip.dy),
              arrowPaint);
        }

        canvas.drawRect(unit, _strokePaint);
      }

      verticalOffset += _stepSize;
      for (int pos = 0; pos < 6; pos++) {
        var unit = Rect.fromLTWH(
            pos * _stepSize, verticalOffset, _stepSize, _stepSize);
  
        if (pos == 2) {
          var safeSpotRadius = _stepSize / 4;
          _fillPaint.color = AppColors.safeSpot;
          canvas.drawCircle(unit.center, safeSpotRadius, _fillPaint);
          canvas.drawCircle(unit.center, safeSpotRadius, _strokePaint);
        }

        canvas.drawRect(unit, _strokePaint);
      }

      canvas.translate(_canvasCenter, _canvasCenter);
      canvas.rotate(pi / 2);
      canvas.translate(-_canvasCenter, -_canvasCenter);
    }
  }
}

/**
 * Board layout :
 * _________
 * | 0 | 1 |
 * |___|___|
 * |   |   |
 * |_3_|_2_|
 */
