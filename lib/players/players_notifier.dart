import 'package:flutter/material.dart';

class PlayersNotifier with ChangeNotifier  {
  bool _shoulPaintPlayers = false;

  get shoulPaintPlayers => _shoulPaintPlayers;

  void rebuildPaint() {
    _shoulPaintPlayers = true;
    notifyListeners();
  }
}
