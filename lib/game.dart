import 'dart:math';

import 'package:fludo/board.dart';
import 'package:fludo/collision_details.dart';
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
  CollisionDetails _collisionDetails = CollisionDetails();

  int _stepCounter = 0,
      _diceNumber = 0,
      _currentTurn = 0,
      _selectedPawnIndex,
      _maxTrackIndex = 57,
      _straightSixesCounter = 0,
      _forwardStepAnimTimeInMillis = 250,
      _reverseStepAnimTimeInMillis = 60;
  List<List<List<Rect>>> _playerTracks;
  List<Rect> _safeSpots;
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
  void dispose() {
    _playerAnimContList.forEach((controllerList) {
      controllerList.forEach((controller) {
        controller.dispose();
      });
    });
    _highlightAnimCont.dispose();
    super.dispose();
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
            duration: Duration(milliseconds: _forwardStepAnimTimeInMillis),
            vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (!_collisionDetails.isReverse) _stepCounter++;
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

    /**
     * Fetch all safe spot rects
     */
    var playerTrack = _playerTracks[0][0];

    _safeSpots = [
      playerTrack[1],
      playerTrack[9],
      playerTrack[14],
      playerTrack[22],
      playerTrack[27],
      playerTrack[35],
      playerTrack[40],
      playerTrack[48]
    ];
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
              break; //disallow pawn selection because 6 is not rolled and the pawn is in house
          } else if (clickedPawnIndex + _diceNumber > _maxTrackIndex)
            break; //disallow pawn selection because dice number is more than step left

          _highlightAnimCont.reset();
          _selectedPawnIndex = pawnIndex;

          _movePawn(considerCurrentStep: true);

          break;
        }
    }
  }

  _checkDiceResultValidity() {
    var isValid = false;

    for (var stepInfo in _pawnCurrentStepInfo[_currentTurn]) {
      if (_diceNumber == 6) {
        _straightSixesCounter++;

        if (_straightSixesCounter ==
            3) //change turn in case of 3 straight sixes
          break;
        else if (stepInfo.key + _diceNumber >
            _maxTrackIndex) //ignore pawn if it can't move 6 steps
          continue;

        _provideFreeTurn = true;
        isValid = true;
        break;
      } else if (stepInfo.key != 0) {
        if (stepInfo.key + _diceNumber <= _maxTrackIndex) {
          isValid = true;
          break;
        }
      }
    }

    if (!isValid) _changeTurn();
  }

  _movePawn({bool considerCurrentStep = false}) {
    int playerIndex, pawnIndex, currentStepIndex;

    if (_collisionDetails.isReverse) {
      playerIndex = _collisionDetails.targetPlayerIndex;
      pawnIndex = _collisionDetails.pawnIndex;
      currentStepIndex = max(
          _pawnCurrentStepInfo[playerIndex][pawnIndex].key -
              (considerCurrentStep ? 0 : 1),
          0);
    } else {
      playerIndex = _currentTurn;
      pawnIndex = _selectedPawnIndex;
      currentStepIndex = min(
          _pawnCurrentStepInfo[playerIndex][pawnIndex].key +
              (considerCurrentStep
                  ? 0
                  : 1), //condition to avoid incrementing key for initial step
          _maxTrackIndex);
    }

    //update current step info in the [_pawnCurrentStepInfo] list
    var currentStepInfo = MapEntry(currentStepIndex,
        _playerTracks[playerIndex][pawnIndex][currentStepIndex]);
    _pawnCurrentStepInfo[playerIndex][pawnIndex] = currentStepInfo;

    var animCont = _playerAnimContList[playerIndex][pawnIndex];

    if (_collisionDetails.isReverse) {
      if (currentStepIndex > 0) {
        //animate one step reverse
        _playerAnimList[_collisionDetails.targetPlayerIndex]
            [_collisionDetails.pawnIndex] = Tween(
                begin: currentStepInfo.value.center,
                end: _playerTracks[_collisionDetails.targetPlayerIndex]
                        [_collisionDetails.pawnIndex][currentStepIndex - 1]
                    .center)
            .animate(animCont);
        animCont.forward(from: 0.0);
      } else {
        _playerAnimContList[playerIndex][pawnIndex].duration =
            Duration(milliseconds: _forwardStepAnimTimeInMillis);
        _collisionDetails.isReverse = false;
        _provideFreeTurn = true; //free turn for collision
        _changeTurn();
      }
    } else if (_stepCounter != _diceNumber) {
      //animate one step forward
      _playerAnimList[playerIndex][pawnIndex] = Tween(
              begin: currentStepInfo.value.center,
              end: _playerTracks[playerIndex][pawnIndex]
                      [min(currentStepIndex + 1, _maxTrackIndex)]
                  .center)
          .animate(CurvedAnimation(
              parent: animCont,
              curve: Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
      animCont.forward(from: 0.0);
    } else {
      if (_checkCollision(currentStepInfo))
        _movePawn(considerCurrentStep: true);
      else {
        if (currentStepIndex == _maxTrackIndex) {
          _pawnCurrentStepInfo[_currentTurn].removeAt(
              _selectedPawnIndex); //remove pawn info that reached destination

          if (_pawnCurrentStepInfo[_currentTurn].isNotEmpty)
            _provideFreeTurn =
                true; //if player has remaining pawns, provide free turn for reaching destination
        }

        _changeTurn();
      }
    }
  }

  bool _checkCollision(MapEntry<int, Rect> currentStepInfo) {
    var currentStepCenter = currentStepInfo.value.center;

    if (currentStepInfo.key <
        52) //no need to check if the pawn has entered destination lane
    if (!_safeSpots.any((safeSpot) {
      //avoid checking if it has landed on a safe spot
      return safeSpot.contains(currentStepCenter);
    })) {
      List<CollisionDetails> collisions = List();
      for (int playerIndex = 0;
          playerIndex < _pawnCurrentStepInfo.length;
          playerIndex++) {
        for (int pawnIndex = 0;
            pawnIndex < _pawnCurrentStepInfo[playerIndex].length;
            pawnIndex++) {
          if (playerIndex != _currentTurn ||
              pawnIndex != _selectedPawnIndex) if (_pawnCurrentStepInfo[
                  playerIndex][pawnIndex]
              .value
              .contains(currentStepCenter)) {
            collisions.add(CollisionDetails()
              ..pawnIndex = pawnIndex
              ..targetPlayerIndex = playerIndex);
          }
        }
      }

      /**
       * Check if collision is valid
       */
      if (collisions.isEmpty ||
          collisions.any((collision) {
            return collision.targetPlayerIndex == _currentTurn;
          }) ||
          collisions.length >
              1) //conditions to no collision and group collisions
        _collisionDetails.isReverse = false;
      else {
        _collisionDetails = collisions.first;
        _playerAnimContList[_collisionDetails.targetPlayerIndex]
                [_collisionDetails.pawnIndex]
            .duration = Duration(milliseconds: _reverseStepAnimTimeInMillis);

        _collisionDetails.isReverse = true;
      }
    }
    return _collisionDetails.isReverse;
  }

  _changeTurn() {
    if (_pawnCurrentStepInfo.where((playerInfo) {
          return playerInfo.isEmpty;
        }).length !=
        3) //if any 3 players have completed
    {
      _diceNumber = 0;

      _stepCounter = 0; //reset step counter for next turn
      if (!_provideFreeTurn) {
        do {
          //to ignore winners
          _currentTurn =
              (_currentTurn + 1) % 4; //change turn after animation completes
          if (_pawnCurrentStepInfo[_currentTurn].isNotEmpty) break;
        } while (true);

        _straightSixesCounter = 0;
      }

      if (!_highlightAnimCont.isAnimating)
        _highlightAnimCont.repeat(reverse: true);

      _provideFreeTurn = false;
    }
  }
}
