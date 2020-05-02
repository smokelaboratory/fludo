import 'package:fludo/board.dart';
import 'package:fludo/click_surface.dart';
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
  List<List<AnimationController>> _playerAnimContList = List();
  List<List<Animation<Offset>>> _playerAnimList = List();

  int _stepCounter = 0, _diceNumber = 5, _currentTurn = 0, _selectedPawnIndex;
  List<List<List<Rect>>> _playerTracks;
  List<List<MapEntry<int, Rect>>> _pawnCurrentStepInfo =
      List(); //step index, rect
  StateNotifier _stateNotifier;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays([]);

    _stateNotifier = StateNotifier();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int playerIndex = 0;
          playerIndex < _playerTracks.length;
          playerIndex++) {
        List<Animation<Offset>> currentPlayerAnimList = List();
        List<AnimationController> currentPlayerAnimContList = List();
        List<MapEntry<int, Rect>> currentStepInfoList = List();
        for (int pawnIndex = 0;
            pawnIndex < _playerTracks[playerIndex].length;
            pawnIndex++) {
          AnimationController aninCont = AnimationController(
              duration: Duration(milliseconds: 400), vsync: this);
          aninCont.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _stepCounter++;

              //update current step info in the [_pawnCurrentStepInfo] list
              var currentIndex =
                  _pawnCurrentStepInfo[_currentTurn][_selectedPawnIndex].key +
                      1;
              var currentStepInfo = MapEntry(
                  currentIndex,
                  _playerTracks[_currentTurn][_selectedPawnIndex]
                      [currentIndex]);
              _pawnCurrentStepInfo[_currentTurn][_selectedPawnIndex] =
                  currentStepInfo;

              if (_stepCounter != _diceNumber) {
                //animate one step ahead
                var animCont =
                    _playerAnimContList[_currentTurn][_selectedPawnIndex];
                _playerAnimList[_currentTurn][_selectedPawnIndex] = Tween(
                        begin: currentStepInfo.value.center,
                        end: _playerTracks[_currentTurn][_selectedPawnIndex]
                                [currentIndex + 1]
                            .center)
                    .animate(animCont);
                animCont.forward(from: 0.0);
              } else {
                _currentTurn = (_currentTurn + 1) %
                    4; //change turn after animation completes
                _stepCounter = 0; //reset step counter for next turn
              }
            }
          });
          currentPlayerAnimContList.add(aninCont);
          currentPlayerAnimList.add(Tween(
                  begin: _playerTracks[playerIndex][pawnIndex][0].center,
                  end: _playerTracks[playerIndex][pawnIndex][1].center)
              .animate(aninCont));
          currentStepInfoList
              .add(MapEntry(0, _playerTracks[playerIndex][pawnIndex][0]));
        }
        _playerAnimContList.add(currentPlayerAnimContList);
        _playerAnimList.add(currentPlayerAnimList);
        _pawnCurrentStepInfo.add(currentStepInfoList);
      }

      _stateNotifier.rebuildState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => _stateNotifier,
        child: Center(
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
                Consumer<StateNotifier>(builder: (_, notifier, __) {
                  if (notifier.shoulPaintPlayers)
                    return SizedBox.expand(
                      child: Stack(
                        children: _buildPlayerPawns(),
                      ),
                    );
                  else
                    return Container();
                })
              ],
            ),
          ),
        )),
      ),
    );
  }

  List<Widget> _buildPlayerPawns() {
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

  _handleClick(Offset clickOffset) {
    for (int pawnIndex = 0;
        pawnIndex < _pawnCurrentStepInfo[_currentTurn].length;
        pawnIndex++)
      if (_pawnCurrentStepInfo[_currentTurn][pawnIndex]
          .value
          .contains(clickOffset)) {
        _selectedPawnIndex = pawnIndex;

        var currentIndex =
            _pawnCurrentStepInfo[_currentTurn][_selectedPawnIndex].key;
        var currentStepInfo = MapEntry(currentIndex,
            _playerTracks[_currentTurn][_selectedPawnIndex][currentIndex]);
        _pawnCurrentStepInfo[_currentTurn][_selectedPawnIndex] =
            currentStepInfo;

          //animate one step ahead
          var animCont = _playerAnimContList[_currentTurn][_selectedPawnIndex];
          _playerAnimList[_currentTurn][_selectedPawnIndex] = Tween(
                  begin: currentStepInfo.value.center,
                  end: _playerTracks[_currentTurn][_selectedPawnIndex]
                          [currentIndex + 1]
                      .center)
              .animate(animCont);
          animCont.forward(from: 0.0);

        break;
      }
  }
}
