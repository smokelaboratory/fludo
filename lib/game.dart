import 'package:fludo/board.dart';
import 'package:fludo/colors.dart';
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
  List<List<List<Rect>>> _playerTracks;

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
        _anim = Tween(
                begin: _playerTracks[0][0][currentPost],
                end: _playerTracks[0][0][--currentPost])
            .animate(_forwardAnimCont);
        _forwardAnimCont.forward();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
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
                  painter:
                      BoardPainter(trackCalculationListener: (playerTracks) {
                    //rebuild player painter with provider
                    _playerTracks = playerTracks;
                  }),
                ),
              ),
              _playerTracks == null
                  ? Container()
                  : SizedBox.expand(
                      child: AnimatedBuilder(
                        builder: (_, child) => CustomPaint(
                            painter: PlayersPainter(
                                playerCurrentSpots: [
                              _playerTracks[0][0][0],
                              _playerTracks[0][1][0],
                              _playerTracks[0][2][0],
                              _playerTracks[0][3][0]
                            ],
                                playerColor: AppColors.player1,
                                boardClickListener: (clickOffset) {})),
                        animation: _anim,
                      ),
                    ),
              _playerTracks == null
                  ? Container()
                  : SizedBox.expand(
                      child: AnimatedBuilder(
                        builder: (_, child) => CustomPaint(
                            painter: PlayersPainter(
                                playerCurrentSpots: [
                              _playerTracks[1][0][0],
                              _playerTracks[1][1][0],
                              _playerTracks[1][2][0],
                              _playerTracks[1][3][0]
                            ],
                                playerColor: AppColors.player2,
                                boardClickListener: (clickOffset) {})),
                        animation: _anim,
                      ),
                    ),
              _playerTracks == null
                  ? Container()
                  : SizedBox.expand(
                      child: AnimatedBuilder(
                        builder: (_, child) => CustomPaint(
                            painter: PlayersPainter(
                                playerCurrentSpots: [
                              _playerTracks[2][0][0],
                              _playerTracks[2][1][0],
                              _playerTracks[2][2][0],
                              _playerTracks[2][3][0]
                            ],
                                playerColor: AppColors.player3,
                                boardClickListener: (clickOffset) {})),
                        animation: _anim,
                      ),
                    ),
              _playerTracks == null
                  ? Container()
                  : SizedBox.expand(
                      child: AnimatedBuilder(
                        builder: (_, child) => CustomPaint(
                            painter: PlayersPainter(
                                playerCurrentSpots: [
                              _playerTracks[3][0][0],
                              _playerTracks[3][1][0],
                              _playerTracks[3][2][0],
                              _playerTracks[3][3][0]
                            ],
                                playerColor: AppColors.player4,
                                boardClickListener: (clickOffset) {})),
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
