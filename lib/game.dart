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
  bool _provideFreeTurn = false;

  int _stepCounter = 0,
      _diceNumber = 0,
      _currentTurn = 0,
      _selectedPawnIndex,
      _maxTrackIndex = 57;
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
                    if (_diceNumber == 0) {
                      _diceNumber = 1 + Random().nextInt(6);
                      print(_diceNumber);
                      _checkDiceResultValidity();
                    }
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
          var clickedPawnIndex =
              _pawnCurrentStepInfo[_currentTurn][pawnIndex].key;

          if (clickedPawnIndex == 0) {
            if (_diceNumber == 6)
              _diceNumber = 1; //to move pawn out of the house when 6 is rolled
            else
              break;  //disallow pawn selection because 6 is not rolled and the pawn is in house
          } else if (clickedPawnIndex + _diceNumber > _maxTrackIndex)
            break; //disallow pawn selection because dice number is more than step left

          _highlightAnimCont.reset();
          _selectedPawnIndex = pawnIndex;

          _movePawn();

          break;
        }
    }
  }

  _checkDiceResultValidity() {
    List<Rect> validPawnsToPlay = List();

    _pawnCurrentStepInfo[_currentTurn].forEach((stepInfo) {
      if (stepInfo.key != 0) {
        if (stepInfo.key + _diceNumber <= _maxTrackIndex)
          validPawnsToPlay.add(stepInfo.value);
      } else if (_diceNumber == 6) validPawnsToPlay.add(stepInfo.value);
    });

    if (validPawnsToPlay.length == 0)
      _changeTurn();
    else
      _provideFreeTurn = _diceNumber == 6;
  }

  _movePawn() {
    //update current step info in the [_pawnCurrentStepInfo] list
    var currentIndex = min(
        _pawnCurrentStepInfo[_currentTurn][_selectedPawnIndex].key +
            (_stepCounter == 0 ? 0 : 1),
        _maxTrackIndex); //condition to avoid adding 1 for 1st step
    var currentStepInfo = MapEntry(currentIndex,
        _playerTracks[_currentTurn][_selectedPawnIndex][currentIndex]);
    _pawnCurrentStepInfo[_currentTurn][_selectedPawnIndex] = currentStepInfo;

    if (_stepCounter != _diceNumber) {
      //animate one step ahead
      var animCont = _playerAnimContList[_currentTurn][_selectedPawnIndex];
      _playerAnimList[_currentTurn][_selectedPawnIndex] = Tween(
              begin: currentStepInfo.value.center,
              end: _playerTracks[_currentTurn][_selectedPawnIndex]
                      [min(currentIndex + 1, _maxTrackIndex)]
                  .center)
          .animate(CurvedAnimation(
              parent: animCont,
              curve: Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
      animCont.forward(from: 0.0);
    } else {
      if (currentIndex == _maxTrackIndex)
        _provideFreeTurn =
            true; //provide free turn as player reached destination

      _changeTurn();

      _highlightAnimCont.repeat(reverse: true);
    }
  }

  _changeTurn() {
    _diceNumber = 0;

    _stepCounter = 0; //reset step counter for next turn

    if (!_provideFreeTurn)
      _currentTurn =
          (_currentTurn + 1) % 4; //change turn after animation completes
  }
}
