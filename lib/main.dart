import 'package:fludo/game.dart';
import 'package:flutter/material.dart';

void main() => runApp(Fludo());

class Fludo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FludoGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

