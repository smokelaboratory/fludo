import 'package:fludo/board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FludoGame extends StatefulWidget {
  @override
  _FludoGameState createState() => _FludoGameState();
}

class _FludoGameState extends State<FludoGame> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        color: Colors.white,
        margin: const EdgeInsets.all(20),
        child: AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: BoardPainter(),
          ),
        ),
      )),
    );
  }
}
