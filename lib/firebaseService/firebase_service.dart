import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // get the reference of Collection
  CollectionReference highScore =
      FirebaseFirestore.instance.collection('highScore');

  // Add a Score
  Future<void> addScore(String name, int score) async {
    await FirebaseFirestore.instance
        .collection("highScore")
        .add({'name': name, 'score': score});
  }

  // Get the top 10 highest score
  Stream<QuerySnapshot> getHightestScore() {
    return highScore.orderBy('score', descending: true).limit(10).snapshots();
  }
}
