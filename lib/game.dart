import 'package:fludo/board.dart';
import 'package:fludo/players.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FludoGame extends StatefulWidget {
  @override
  _FludoGameState createState() => _FludoGameState();
}

class _FludoGameState extends State<FludoGame> with TickerProviderStateMixin {
  AnimationController _forwardAnimCont;
  AnimationController _reverseAnimCont;
  Animation<Rect> _anim;

  int currentPost = 0;
  List<Rect> track;

  @override
  void initState() {
    super.initState();

    _reverseAnimCont =
        AnimationController(vsync: this, duration: Duration(milliseconds: 10));
    _forwardAnimCont =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    _anim = Tween<Rect>().animate(_forwardAnimCont);

    SystemChrome.setEnabledSystemUIOverlays([]);

    _forwardAnimCont.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _forwardAnimCont.reset();
        _anim = Tween(begin: track[currentPost], end: track[--currentPost])
            .animate(_forwardAnimCont);
        _forwardAnimCont.forward();
      }
    });
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
          child: Stack(
            children: <Widget>[
              SizedBox.expand(
                child: CustomPaint(
                  painter: BoardPainter(),
                ),
              ),
              SizedBox.expand(
                child: AnimatedBuilder(
                  builder: (_, child) => CustomPaint(
                      painter: PlayersPainter(_anim.value, (list) {
                    track = list;
                    currentPost = 56;

                    _anim = Tween(
                            begin: track[currentPost],
                            end: track[--currentPost])
                        .animate(_forwardAnimCont);
                    _forwardAnimCont.forward();
                  })),
                  animation: _anim,
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
