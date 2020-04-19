import 'package:fludo/colors.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class BoardPainter extends CustomPainter {
  double _unitSize, _homeStartOffset, _homeSize, _canvasCenter;

  Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    _unitSize = size.width / 15;
    _homeStartOffset = _unitSize * 9;
    _homeSize = _unitSize * 6;
    _canvasCenter = size.width / 2;

    _drawHome(canvas, size);

    _drawDestination(canvas, size);

    _drawSteps(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
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
    var innerHomeSize = _homeSize - 2 * _unitSize;

    _fillPaint.color = Colors.white;
    var innerHome1 = Rect.fromLTWH(home1.left + _unitSize,
        home1.top + _unitSize, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome1, _fillPaint);
    canvas.drawRect(innerHome1, _strokePaint);

    var innerHome2 = Rect.fromLTWH(home2.left + _unitSize,
        home2.top + _unitSize, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome2, _fillPaint);
    canvas.drawRect(innerHome2, _strokePaint);

    var innerHome3 = Rect.fromLTWH(home3.left + _unitSize,
        home3.top + _unitSize, innerHomeSize, innerHomeSize);
    canvas.drawRect(innerHome3, _fillPaint);
    canvas.drawRect(innerHome3, _strokePaint);

    var innerHome4 = Rect.fromLTWH(home4.left + _unitSize,
        home4.top + _unitSize, innerHomeSize, innerHomeSize);
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
            pos * _unitSize, verticalOffset, _unitSize, _unitSize);

        if (pos == 1) canvas.drawRect(unit, _fillPaint);

        canvas.drawRect(unit, _strokePaint);
      }

      verticalOffset += _unitSize;
      for (int pos = 0; pos < 6; pos++) {
        var unit = Rect.fromLTWH(
            pos * _unitSize, verticalOffset, _unitSize, _unitSize);

        if (pos > 0) canvas.drawRect(unit, _fillPaint);

        canvas.drawRect(unit, _strokePaint);
      }

      verticalOffset += _unitSize;
      for (int pos = 0; pos < 6; pos++) {
        var unit = Rect.fromLTWH(
            pos * _unitSize, verticalOffset, _unitSize, _unitSize);

        if (pos == 2) {
          var safeSpotRadius = _unitSize / 4;
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
 * | R | G |
 * |___|___|
 * |   |   |
 * |_B_|_Y_|
 */
