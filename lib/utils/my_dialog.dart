import 'package:flutter/material.dart';

class MyDialog extends StatelessWidget {
  final int score;
  final TextEditingController nameController;
  final int dataScoreLast;
  final void Function(int) submit;
  const MyDialog({super.key, required this.score, required this.nameController, required this.dataScoreLast, required this.submit});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              title: const Text(
                "Game over",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Your Score: $score",
                      style: TextStyle(
                          color: Colors.red[900], fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(),
                          focusColor: Colors.black,
                          hintText: "Enter your name to submit"),
                    ),
                  ),
                ],
              ),
              actions: [
                MaterialButton(
                  shape: Border.all(),
                  color: Colors.black,
                  onPressed: () {
                    submit(dataScoreLast);
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.amber),
                  ),
                ),
                MaterialButton(
                  shape: Border.all(),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "No submit",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                )
              ],
            );
  }
}