import 'package:flutter/material.dart';

class StateNotifier with ChangeNotifier  {
  bool _shoulPaintPlayers = false;

  get shoulPaintPlayers => _shoulPaintPlayers;

  void rebuildState() {
    _shoulPaintPlayers = true;
    notifyListeners();
  }
}
