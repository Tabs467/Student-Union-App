import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_union_app/services/database.dart';
import 'endLeaderboard.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';


class ActiveQuiz extends StatefulWidget {
  const ActiveQuiz({Key? key}) : super(key: key);

  @override
  _ActiveQuizState createState() => _ActiveQuizState();
}

class _ActiveQuizState extends State<ActiveQuiz> {
  // Initialise quiz variables to standard values
  String quizID = '';
  int currentQuestionNumber = 1;
  int questionCount = 10;
  bool quizEnded = false;
  bool anyQuizActive = false;

  // Selected answer state
  Answer selectedAnswer = Answer.none;

  // Set which answer the user has currently selected
  _selectAnswer(String answer) {
    if (answer == "a") {
      selectedAnswer = Answer.A;
    } else if (answer == "b") {
      selectedAnswer = Answer.B;
    } else if (answer == "c") {
      selectedAnswer = Answer.C;
    } else if (answer == "d") {
      selectedAnswer = Answer.D;
    }
  }

  final DatabaseService _database = DatabaseService();

  _submitAnswer(String answer) async {
    await _database.submitAnswer(answer);
  }

  // On the first build of the widget tree retrieve the current question's
  // number, question count and whether the quiz has ended
  @override
  initState() {
    super.initState();
    retrieveCurrentQuestionNumber();
  }

  // Set the stream to listen to the Quiz document that is marked as
  // currently active
  final Stream<QuerySnapshot> _quizzes = FirebaseFirestore.instance
      .collection('Quizzes')
      .where('isActive', isEqualTo: true)
      .snapshots();

  // Rebuild the widget tree and update the current question number,
  // question count and quiz ended variables to their current values in the
  // database
  retrieveCurrentQuestionNumber() {
    setState(() {
      _quizzes.forEach((field) {
        field.docs.asMap().forEach((index, data) {
          currentQuestionNumber = data['currentQuestion'];
          questionCount = data['questionCount'];
          quizEnded = data['quizEnded'];
          quizID = data['id'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),
      body: StreamBuilder<QuerySnapshot>(
        // Set the stream to listen to the Quiz document that is marked as
        // currently active
          stream: FirebaseFirestore.instance
              .collection('Quizzes')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text(
                  'Something went wrong retrieving the quiz');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading the quiz...');
            }

            // Add the retrieved quiz to a map and update the current
            // question number to reflect the value in the database
            snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              currentQuestionNumber = data['currentQuestion'];
              quizEnded = data['quizEnded'];
              quizID = data['id'];
            });

            // If the quiz hasn't ended retrieve the current question
            if (!quizEnded) {
              return StreamBuilder<QuerySnapshot>(
                // Set the stream to listen to the Question document whose
                // contained question is part of the current quiz and
                // whose question number is the current position in the quiz
                  stream: FirebaseFirestore.instance
                      .collection('Questions')
                      .where('quizID', isEqualTo: quizID)
                      .where('questionNumber',
                      isEqualTo: currentQuestionNumber)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                          'Something went wrong retrieving the question');
                    }
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text('Loading the question...');
                    }

                    // Build the question and answer Widgets depending on
                    // which answer the user has currently selected
                    // So that the currently selected answer is highlighted
                    return _buildAnswers(snapshot);
                  });
            }
            // If the quiz has ended display the end of quiz leaderboard
            else {
              return EndLeaderboard(quizID: quizID);
            }
          }),
    );
  }


  // Build the question and answer Widgets with answer A as the selected answer
  RawScrollbar _buildAnswers(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return RawScrollbar(
      isAlwaysShown: true,
      thumbColor: const Color.fromRGBO(22, 66, 139, 1),
      //radius: Radius.circular(20),
      thickness: 7.5,

      // Display the current question along with its answers
      child: Column(
        children: [
          Expanded(
            child: ListView(
                children:
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
                  return Container(
                    color: const Color.fromRGBO(244, 175, 20, 1.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Card(
                            color: const Color.fromRGBO(22, 66, 139, 1),
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                  color: Colors.white70, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Q' +
                                    data['questionNumber'].toString() +
                                    ': ' +
                                    data['questionText'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: Card(
                            color: Colors.red[900],
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                              side: BorderSide(
                                  color: (selectedAnswer == Answer.A) ? Colors
                                      .yellowAccent : Colors.white70,
                                  width: 1),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _submitAnswer("a");
                                  _selectAnswer("a");
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Text(
                                  'A: ' + data['answerA'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: Card(
                            color: Colors.blue[900],
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                              side: BorderSide(
                                  color: (selectedAnswer == Answer.B) ? Colors
                                      .yellowAccent : Colors.white70,
                                  width: 1),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _submitAnswer("b");
                                  _selectAnswer("b");
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Text(
                                  'B: ' + data['answerB'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: Card(
                            color: Colors.green[900],
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                              side: BorderSide(
                                  color: (selectedAnswer == Answer.C) ? Colors
                                      .yellowAccent : Colors.white70,
                                  width: 1),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _submitAnswer("c");
                                  _selectAnswer("c");
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Text(
                                  'C: ' + data['answerC'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: Card(
                            color: Colors.yellow[900],
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                              side: BorderSide(
                                  color: (selectedAnswer == Answer.D) ? Colors
                                      .yellowAccent : Colors.white70,
                                  width: 1),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _submitAnswer("d");
                                  _selectAnswer("d");
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Text(
                                  'D: ' + data['answerD'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
          ),
        ],
      ),
    );
  }
}

enum Answer {
  none,
  A,
  B,
  C,
  D,
}
