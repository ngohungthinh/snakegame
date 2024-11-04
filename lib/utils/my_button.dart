import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function() startGame;
  const MyButton({super.key, required this.startGame});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    enableFeedback: false,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    shape: RoundedRectangleBorder(
                        // side: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(3)),
                    backgroundColor: Colors.red),
                onPressed: startGame,
                child: const Text(
                  "Play",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ));
  }
}