import 'dart:math';

import 'package:fludo/board.dart';
import 'package:fludo/overlay_surface.dart';
import 'package:fludo/colors.dart';
import 'package:fludo/players.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fludo/state_notifier.dart';

class FludoGame extends StatefulWidget {
  @override
  _FludoGameState createState() => _FludoGameState();
}

class _FludoGameState extends State<FludoGame> with TickerProviderStateMixin {
  Animation<Color> _highlightAnim;
  AnimationController _highlightAnimCont;
  List<List<AnimationController>> _playerAnimContList = List();
  List<List<Animation<Offset>>> _playerAnimList = List();
  List<Color> bgColors = [Colors.cyan[600], Colors.cyan, Colors.cyan[400]];

  int _stepCounter = 0, _diceNumber = 0, _currentTurn = 0, _selectedPawnIndex;
  List<List<List<Rect>>> _playerTracks;
  List<List<MapEntry<int, Rect>>> _pawnCurrentStepInfo =
      List(); //step index, rect
  StateNotifier _stateNotifier;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays([]); //full screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]); //force portrait mode

    _stateNotifier = StateNotifier();

    _highlightAnimCont =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    _highlightAnim = ColorTween(begin: Colors.transparent, end: Colors.black38)
        .animate(_highlightAnimCont);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();

      _stateNotifier.rebuildState();

      _highlightAnimCont.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => _stateNotifier,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
                child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.transparent.withOpacity(0.15),
                        BlendMode.dstATop),
                    image: AssetImage(
                      "images/bg.jpg",
                    ),
                  ),
                  gradient: LinearGradient(
                      colors: [...bgColors, ...bgColors.reversed])),
            )),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: <Widget>[
                          SizedBox.expand(
                            child: CustomPaint(
                              painter: BoardPainter(
                                  trackCalculationListener: (playerTracks) {
                                _playerTracks = playerTracks;
                              }),
                            ),
                          ),
                          SizedBox.expand(
                              child: AnimatedBuilder(
                            animation: _highlightAnim,
                            builder: (_, __) => CustomPaint(
                              painter: OverlaySurface(
                                  highlightColor: _highlightAnim.value,
                                  selectedHomeIndex: _currentTurn,
                                  clickOffset: (clickOffset) {
                                    _handleClick(clickOffset);
                                  }),
                            ),
                          )),
                          Consumer<StateNotifier>(builder: (_, notifier, __) {
                            if (notifier.shoulPaintPlayers)
                              return SizedBox.expand(
                                child: Stack(
                                  children: _buildPawnWidgets(),
                                ),
                              );
                            else
                              return Container();
                          })
                        ],
                      ),
                    ),
                  ),
                  RaisedButton(onPressed: () {
                    _diceNumber = 1 + Random().nextInt(6);
                  })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPawnWidgets() {
    List<Widget> playerPawns = List();

    for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
      Color playerColor;
      switch (playerIndex) {
        case 0:
          playerColor = AppColors.player1;
          break;
        case 1:
          playerColor = AppColors.player2;
          break;
        case 2:
          playerColor = AppColors.player3;
          break;
        default:
          playerColor = AppColors.player4;
      }
      for (int pawnIndex = 0; pawnIndex < 4; pawnIndex++)
        playerPawns.add(SizedBox.expand(
          child: AnimatedBuilder(
            builder: (_, child) => CustomPaint(
                painter: PlayersPainter(
                    playerCurrentSpot:
                        _playerAnimList[playerIndex][pawnIndex].value,
                    playerColor: playerColor)),
            animation: _playerAnimList[playerIndex][pawnIndex],
          ),
        ));
    }

    return playerPawns;
  }

  _initData() {
    for (int playerIndex = 0;
        playerIndex < _playerTracks.length;
        playerIndex++) {
      List<Animation<Offset>> currentPlayerAnimList = List();
      List<AnimationController> currentPlayerAnimContList = List();
      List<MapEntry<int, Rect>> currentStepInfoList = List();

      for (int pawnIndex = 0;
          pawnIndex < _playerTracks[playerIndex].length;
          pawnIndex++) {
        AnimationController currentAnimCont = AnimationController(
            duration: Duration(milliseconds: 250), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _stepCounter++;
              _movePawn();
            }
          });

        currentPlayerAnimContList.add(currentAnimCont);
        currentPlayerAnimList.add(Tween(
                begin: _playerTracks[playerIndex][pawnIndex][0].center,
                end: _playerTracks[playerIndex][pawnIndex][1].center)
            .animate(currentAnimCont));
        currentStepInfoList
            .add(MapEntry(0, _playerTracks[playerIndex][pawnIndex][0]));
      }
      _playerAnimContList.add(currentPlayerAnimContList);
      _playerAnimList.add(currentPlayerAnimList);
      _pawnCurrentStepInfo.add(currentStepInfoList);
    }
  }

  _handleClick(Offset clickOffset) {
    if (_diceNumber != 0) if (_stepCounter == 0) {
      for (int pawnIndex = 0;
          pawnIndex < _pawnCurrentStepInfo[_currentTurn].length;
          pawnIndex++)
        if (_pawnCurrentStepInfo[_currentTurn][pawnIndex]
            .value
            .contains(clickOffset)) {
          _highlightAnimCont.reset();
          _selectedPawnIndex = pawnIndex;

          _movePawn();

          break;
        }
    }
  }

  _movePawn() {
    //update current step info in the [_pawnCurrentStepInfo] list
    var currentIndex = _pawnCurrentStepInfo[_currentTurn][_selectedPawnIndex]
            .key +
        (_stepCounter == 0 ? 0 : 1); //condition to avoid adding 1 for 1st step
    var currentStepInfo = MapEntry(currentIndex,
        _playerTracks[_currentTurn][_selectedPawnIndex][currentIndex]);
    _pawnCurrentStepInfo[_currentTurn][_selectedPawnIndex] = currentStepInfo;

    if (_stepCounter != _diceNumber) {
      //animate one step ahead
      var animCont = _playerAnimContList[_currentTurn][_selectedPawnIndex];
      _playerAnimList[_currentTurn][_selectedPawnIndex] = Tween(
              begin: currentStepInfo.value.center,
              end: _playerTracks[_currentTurn][_selectedPawnIndex]
                      [currentIndex + 1]
                  .center)
          .animate(CurvedAnimation(
              parent: animCont,
              curve: Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
      animCont.forward(from: 0.0);
    } else {
      _diceNumber = 0;
      _currentTurn =
          (_currentTurn + 1) % 4; //change turn after animation completes
      _stepCounter = 0; //reset step counter for next turn

      _highlightAnimCont.repeat(reverse: true);
    }
  }
}
