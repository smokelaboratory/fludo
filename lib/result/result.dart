import 'package:flutter/material.dart';

class ResultPainter extends CustomPainter {
  List<int> _ranks;

  ResultPainter(this._ranks);

  @override
  void paint(Canvas canvas, Size size) {
    var stepSize = size.width / 15;
    var homeStartOffset = stepSize * 9;
    var homeSize = stepSize * 6;

    for (int playerIndex = 0; playerIndex < _ranks.length; playerIndex++) {
      var rank = _ranks[playerIndex];
      if (rank != 0) {
        double left, top;
        switch (playerIndex) {
          case 0:
            left = 0;
            top = 0;
            break;
          case 1:
            left = homeStartOffset;
            top = 0;
            break;
          case 2:
            left = homeStartOffset;
            top = homeStartOffset;
            break;
          default:
            left = 0;
            top = homeStartOffset;
        }
        _drawRank(canvas, Rect.fromLTWH(left, top, homeSize, homeSize), rank);
      }
    }
  }

  _drawRank(Canvas canvas, Rect rect, int rank) {
    canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black54);

    var rankTextPainter = TextPainter(
        text: TextSpan(
          text: _getRankText(rank),
          style: TextStyle(
              fontSize: 50.0,
              color: Colors.white,
              fontFamily: "LuckiestGuy",
              height: 1.5),
        ),
        textDirection: TextDirection.ltr)
      ..layout();

    rankTextPainter.paint(
        canvas,
        Offset(rect.center.dx - rankTextPainter.width / 2,
            rect.center.dy - rankTextPainter.height / 2));
  }

  String _getRankText(int rank) {
    String suffix;

    switch (rank) {
      case 1:
        suffix = "st";
        break;
      case 2:
        suffix = "nd";
        break;
      case 3:
        suffix = "rd";
        break;
      default:
        suffix = "th";
    }

    return "$rank$suffix";
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) => false; //to pass touches to layer beneath
}
