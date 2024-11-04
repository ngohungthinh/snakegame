import 'package:flutter/material.dart';

class Pixel extends StatelessWidget {
  final String type;
  const Pixel({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Color? color;
    switch (type) {
      case "snake":
        color = Colors.white;
      case "blank":
        color = Colors.grey[900];
      case "food":
        color = Colors.amber[900];
      default:
        color = Colors.deepPurple;
    }
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      margin: const EdgeInsets.all(1),
    );
  }
}
