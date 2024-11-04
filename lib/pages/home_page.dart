import 'dart:async';
import 'dart:math';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/firebaseService/firebase_service.dart';
import 'package:snake_game/utils/my_button.dart';
import 'package:snake_game/utils/my_dialog.dart';
import 'package:snake_game/utils/pixel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum Direction { up, down, left, right }

class _HomePageState extends State<HomePage> {
  // grid demensions
  int rowSize = 20;
  int totalSquares = 400;

  // already Play
  bool isPlay = false;
  final TextEditingController _nameController = TextEditingController();
  final FirebaseService firebaseService = FirebaseService();

  // Detect Arrow in Web
  final focusNode = FocusNode();

  // snake position
  List<int> snakePos = [0, 1, 2];

  // food position
  int foodPos = 55;

  // direction
  Direction direction = Direction.right;
  Queue<Direction> queueRequest = Queue();

  // Score
  int score = 0;

  // Timer start game
  late Timer timer;

  //Top 10 score fetch from Firebase
  late List<Map<String, dynamic>> dataScore = [];

  @override
  void initState() {
    // If top 10 co du lieu moi, thi cập nhập lại.
    firebaseService.getHightestScore().listen((QuerySnapshot data) {
      print("aaa toi ne toi ne");
      List<DocumentSnapshot> documents = data.docs;
      dataScore = documents.map((DocumentSnapshot document) {
        return document.data() as Map<String, dynamic>;
      }).toList();

      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Nhấn nút Play để chạy game
  void startGame() {
    if (isPlay == false) {
      initalGame();
      timer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
        moveSnake();
      });
      isPlay = true;
    }
  }

  // Chuyển động của rắn sau mỗi 200 milisecond
  void moveSnake() {
    if (queueRequest.isNotEmpty) {
      direction = queueRequest.removeFirst();
      // print(diresction);
    }
    int movePos = 0;
    switch (direction) {
      case Direction.right:
        if (snakePos.last % rowSize == rowSize - 1) {
          movePos = snakePos.last - (rowSize - 1);
        } else {
          movePos = snakePos.last + 1;
        }
      case Direction.left:
        if (snakePos.last % rowSize == 0) {
          movePos = snakePos.last + rowSize - 1;
        } else {
          movePos = snakePos.last - 1;
        }
      case Direction.up:
        if (snakePos.last < rowSize) {
          movePos = snakePos.last + totalSquares - rowSize;
        } else {
          movePos = snakePos.last - rowSize;
        }
      case Direction.down:
        if (snakePos.last > totalSquares - rowSize - 1) {
          movePos = snakePos.last - totalSquares + rowSize;
        } else {
          movePos = snakePos.last + rowSize;
        }
    }

    // Lose the Game
    if (snakePos.contains(movePos)) {
      timer.cancel();
      isPlay = false;
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return MyDialog(
                score: score,
                nameController: _nameController,
                dataScoreLast: dataScore.last['score'],
                submit: (dataScoreLast) {
                  if (score >= dataScoreLast) {
                    firebaseService.addScore(_nameController.text, score);
                  }
                  Navigator.of(context).pop();
                });
          });
    }

    // Eat Food
    bool eatFood = false;
    if (movePos == foodPos) {
      score++;
      eatFood = true;

  
      do {
        foodPos = Random().nextInt(totalSquares);
      } while (snakePos.contains(foodPos) || movePos == foodPos);
    }

    // Cập nhập SnakePos
    setState(() {
      // add head
      snakePos.add(movePos);

      // remove tail
      if (eatFood == false) {
        snakePos.removeAt(0);
      }
    });
  }

  // Khởi tạo lại game mới
  void initalGame() {
    snakePos = [0, 1, 2];
    foodPos = 55;
    direction = Direction.right;
    score = 0;
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    // First Right after Left
    if (details.delta.dx > 0) {
      if (queueRequest.isNotEmpty) {
        if (queueRequest.last != Direction.left &&
            queueRequest.last != Direction.right) {
          queueRequest.addLast(Direction.right);
        }
      } else {
        if (direction != Direction.left && direction != Direction.right) {
          queueRequest.addLast(Direction.right);
        }
      }
    } else {
      if (queueRequest.isNotEmpty) {
        if (queueRequest.last != Direction.left &&
            queueRequest.last != Direction.right) {
          queueRequest.addLast(Direction.left);
        }
      } else {
        if (direction != Direction.left && direction != Direction.right) {
          queueRequest.addLast(Direction.left);
        }
      }
    }
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    // first Down after Up
    if (details.delta.dy > 0) {
      if (queueRequest.isNotEmpty) {
        if (queueRequest.last != Direction.up &&
            queueRequest.last != Direction.down) {
          queueRequest.addLast(Direction.down);
        }
      } else {
        if (direction != Direction.down && direction != Direction.up) {
          queueRequest.addLast(Direction.down);
        }
      }
    } else {
      if (queueRequest.isNotEmpty) {
        if (queueRequest.last != Direction.up &&
            queueRequest.last != Direction.down) {
          queueRequest.addLast(Direction.up);
        }
      } else {
        if (direction != Direction.down && direction != Direction.up) {
          queueRequest.addLast(Direction.up);
        }
      }
    }
  }

  void onKeyEvent(KeyEvent event) {
    print('Press');
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        print('Up');
        if (queueRequest.isNotEmpty) {
          if (queueRequest.last != Direction.up &&
              queueRequest.last != Direction.down) {
            queueRequest.addLast(Direction.up);
          }
        } else {
          if (direction != Direction.down && direction != Direction.up) {
            queueRequest.addLast(Direction.up);
          }
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        print('Down');
        if (queueRequest.isNotEmpty) {
          if (queueRequest.last != Direction.up &&
              queueRequest.last != Direction.down) {
            queueRequest.addLast(Direction.down);
          }
        } else {
          if (direction != Direction.down && direction != Direction.up) {
            queueRequest.addLast(Direction.down);
          }
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        print('Left');
        if (queueRequest.isNotEmpty) {
          if (queueRequest.last != Direction.left &&
              queueRequest.last != Direction.right) {
            queueRequest.addLast(Direction.left);
          }
        } else {
          if (direction != Direction.left && direction != Direction.right) {
            queueRequest.addLast(Direction.left);
          }
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        print('Right');
        if (queueRequest.isNotEmpty) {
          if (queueRequest.last != Direction.left &&
              queueRequest.last != Direction.right) {
            queueRequest.addLast(Direction.right);
          }
        } else {
          if (direction != Direction.left && direction != Direction.right) {
            queueRequest.addLast(Direction.right);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: KeyboardListener(
          autofocus: true,
          focusNode: focusNode,
          onKeyEvent: onKeyEvent,
          child: SafeArea(
            child: Column(
              children: [
                // high scores
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Your Score",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(score.toString(),
                              style: const TextStyle(fontSize: 30))
                        ],
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        shrinkWrap: true,
                        itemCount: dataScore.length,
                        itemBuilder: (context, index) {
                          return UnconstrainedBox(
                            child: SizedBox(
                              width: 200,
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '#${index + 1}',
                                      style:
                                          const TextStyle(color: Colors.pink),
                                    ),
                                    Expanded(
                                        child: Text(
                                            '   ${dataScore[index]['name']} ')),
                                    Text(
                                      '${dataScore[index]['score']}',
                                      style:
                                          const TextStyle(color: Colors.green),
                                    ),
                                  ]),
                            ),
                          );
                        },
                      ),
                    ))
                  ],
                )),

                // game grid
                Expanded(
                  flex: 3,
                  child: Center(
                    child: SizedBox(
                      width: 412,
                      child: GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(1),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: totalSquares,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: rowSize),
                          itemBuilder: (context, index) {
                            if (snakePos.last == index) {
                              return const Pixel(type: "head");
                            } else if (snakePos.contains(index)) {
                              return const Pixel(type: 'snake');
                            } else if (index == foodPos) {
                              return const Pixel(
                                type: 'food',
                              );
                            }
                            return const Pixel(type: "blank");
                          }),
                    ),
                  ),
                ),

                //play button
                Expanded(child: Center(child: MyButton(startGame: startGame))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
