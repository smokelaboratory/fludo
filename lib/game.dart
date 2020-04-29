import 'package:fludo/board.dart';
import 'package:fludo/click_surface.dart';
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
  Animation<List<Rect>> _anim;

  int currentPost = 50, _currentTurn = 0, _selectedPawnIndex;
  List<List<List<Rect>>> _playerTracks;
  List<List<Rect>> _pawns = List();
  List<List<int>> _pawnCurrentTrackIndex = List();

  @override
  void initState() {
    super.initState();

    _reverseAnimCont =
        AnimationController(vsync: this, duration: Duration(milliseconds: 15));
    _forwardAnimCont =
        AnimationController(vsync: this, duration: Duration(milliseconds:15));

    SystemChrome.setEnabledSystemUIOverlays([]);

    _forwardAnimCont.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (currentPost !=0) {
          _forwardAnimCont.reset();
          _anim = Tween(begin: [
            _playerTracks[_currentTurn][_selectedPawnIndex][currentPost],
            _playerTracks[_currentTurn][1][0],
            _playerTracks[_currentTurn][2][0],
            _playerTracks[_currentTurn][3][0]
          ], end: [
            _playerTracks[_currentTurn][_selectedPawnIndex][--currentPost],
            _playerTracks[_currentTurn][1][0],
            _playerTracks[_currentTurn][2][0],
            _playerTracks[_currentTurn][3][0]
          ]).animate(_forwardAnimCont);
          _forwardAnimCont.forward();
        }
        // else
        // _currentTurn = (_currentTurn + 1) % 4;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        //saves initial players' positions in the [_players] list
        for (int playerIndex = 0;
            playerIndex < _playerTracks.length;
            playerIndex++) {
          List<Rect> player = List();
          for (int trackIndex = 0;
              trackIndex < _playerTracks[playerIndex].length;
              trackIndex++)
            player.add(_playerTracks[playerIndex][trackIndex][0]);

          _pawnCurrentTrackIndex.add([0, 0, 0, 0]); //current position
          _pawns.add(player);
        }

        _anim = Tween<List<Rect>>(begin: _pawns[0], end: _pawns[0])
            .animate(_forwardAnimCont);
      });
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
              SizedBox.expand(child: CustomPaint(
                painter: ClickSurface(clickOffset: (clickOffset) {
                  //blink who's turn
                  _handleClick(clickOffset);
                }),
              )),
              _playerTracks == null
                  ? Container()
                  : SizedBox.expand(
                      child: AnimatedBuilder(
                        builder: (_, child) => CustomPaint(
                            painter: PlayersPainter(playerCurrentSpots: [
                          _anim.value[0],
                          _anim.value[1],
                          _anim.value[2],
                          _anim.value[3]
                        ], playerColor: AppColors.player1)),
                        animation: _anim,
                      ),
                    ),
              _playerTracks == null
                  ? Container()
                  : SizedBox.expand(
                      child: AnimatedBuilder(
                        builder: (_, child) => CustomPaint(
                            painter: PlayersPainter(playerCurrentSpots: [
                          _pawns[1][0],
                          _pawns[1][1],
                          _pawns[1][2],
                          _pawns[1][3]
                        ], playerColor: AppColors.player2)),
                        animation: _anim,
                      ),
                    ),
              _playerTracks == null
                  ? Container()
                  : SizedBox.expand(
                      child: AnimatedBuilder(
                        builder: (_, child) => CustomPaint(
                            painter: PlayersPainter(playerCurrentSpots: [
                          _pawns[2][0],
                          _pawns[2][1],
                          _pawns[2][2],
                          _pawns[2][3]
                        ], playerColor: AppColors.player3)),
                        animation: _anim,
                      ),
                    ),
              _playerTracks == null
                  ? Container()
                  : SizedBox.expand(
                      child: AnimatedBuilder(
                        builder: (_, child) => CustomPaint(
                            painter: PlayersPainter(playerCurrentSpots: [
                          _pawns[3][0],
                          _pawns[3][1],
                          _pawns[3][2],
                          _pawns[3][3]
                        ], playerColor: AppColors.player4)),
                        animation: _anim,
                      ),
                    ),
            ],
          ),
        ),
      )),
    );
  }

  _handleClick(Offset clickOffset) {
    for (int pawnIndex = 0; pawnIndex < 4; pawnIndex++)
      if (true) {
        print(_currentTurn);
        print(pawnIndex);

        _selectedPawnIndex = pawnIndex;

        _forwardAnimCont.reset();
        _anim = Tween(begin: [
          _playerTracks[_currentTurn][pawnIndex][currentPost],
          _playerTracks[_currentTurn][1][0],
          _playerTracks[_currentTurn][2][0],
          _playerTracks[_currentTurn][3][0]
        ], end: [
          _playerTracks[_currentTurn][pawnIndex][--currentPost],
          _playerTracks[_currentTurn][1][0],
          _playerTracks[_currentTurn][2][0],
          _playerTracks[_currentTurn][3][0]
        ]).animate(_forwardAnimCont);
        _forwardAnimCont.forward();

        break;
      }
  }
}
