import 'package:flutter/material.dart';

class ResultNotifier with ChangeNotifier {
  List<int> _ranks = [0, 0, 0, 0];

  get ranks => _ranks;

  void rebuildPaint(int winnerPlayerIndex) {
    var nextRank = 0;
    _ranks.forEach((rank) {
      if (rank > nextRank) nextRank = rank;
    });
    _ranks[winnerPlayerIndex] = ++nextRank;

    if (nextRank == 3)  //assign rank to last player
      _ranks[_ranks.indexWhere((rank) {
        return rank == 0;
      })] = 4;
      
    notifyListeners();
  }
}
