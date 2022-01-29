import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/quiz/endLeaderboard.dart';
import 'package:student_union_app/services/database.dart';

import 'adminEndLeaderboard.dart';

class QuizControl extends StatefulWidget {
  const QuizControl({Key? key}) : super(key: key);

  @override
  _QuizControlState createState() => _QuizControlState();
}

class _QuizControlState extends State<QuizControl> {
  // Initialise quiz variables to standard values
  String quizID = 'i0VXURC5VW3DATZpge1T';
  int currentQuestionNumber = 1;
  int questionCount = 10;
  bool quizEnded = false;

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
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
                // Set the stream to listen to the Quiz document that is marked as
                // currently active
                stream: FirebaseFirestore.instance
                    .collection('Quizzes')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong loading the quiz');
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
                  });

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
                              'Something went wrong loading the question');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Loading the question...');
                        }

                        // If all the quizzes questions have been displayed
                        if (currentQuestionNumber <= questionCount) {
                          // Display the current question along with its answers
                          // and correct answer
                          // Also display the End Quiz and Next Question buttons
                          return buildAnswersAndButtons(snapshot, context);
                        }
                        // Otherwise if the quiz has ended
                        else {
                          // Display the End of Quiz Leaderboard along with an
                          // extra button that ends the quiz
                          return AdminEndLeaderboard(quizID: quizID);
                        }
                      });
                }),
          ),
        ],
      ),
    );
  }


  // Display the current question along with its answers
  // and correct answer
  // Also display the End Quiz and Next Question buttons
  Column buildAnswersAndButtons(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot, BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RawScrollbar(
            isAlwaysShown: true,
            thumbColor: const Color.fromRGBO(22, 66, 139, 1),
            thickness: 7.5,
            child: ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Container(
                color: const Color.fromRGBO(244, 175, 20, 1.0),
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            child: Center(
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
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 7.5, 15.0, 5.0),
                        child: Card(
                          color: Colors.red[900],
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: const BorderSide(
                                color: Colors.white70, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
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
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
                        child: Card(
                          color: Colors.blue[900],
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: const BorderSide(
                                color: Colors.white70, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
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
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
                        child: Card(
                          color: Colors.green[900],
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: const BorderSide(
                                color: Colors.white70, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
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
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
                        child: Card(
                          color: Colors.yellow[900],
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: const BorderSide(
                                color: Colors.white70, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
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
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          color: const Color.fromRGBO(244, 140, 20, 1),
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                                color: Colors.yellow, width: 3),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                'Correct Answer: ' +
                                    data['correctAnswer'].toUpperCase(),
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
                ),
              );
            }).toList()),
          ),
        ),
        Container(
          color: const Color.fromRGBO(244, 140, 20, 1),
          height: 75,
          child: Card(
              margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: InkWell(
                // When tapped call the function to end the
                // quiz
                onTap: () {
                  DatabaseService().endQuiz(quizID);
                  Navigator.pushReplacementNamed(context, '/quiz/admin');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'End Quiz',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ]),
                  ],
                ),
              )),
        ),
        Container(
          color: const Color.fromRGBO(244, 140, 20, 1),
          height: 75,
          child: Card(
              margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: InkWell(
                // When tapped retrieve the current question
                // number from the database and call the function
                // to advance the quiz to the next question
                onTap: () {
                  setState(() {
                    retrieveCurrentQuestionNumber();
                    DatabaseService().nextQuestion(
                        quizID, currentQuestionNumber, questionCount);
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Next Question',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ]),
                  ],
                ),
              )),
        ),
      ],
    );
  }
}
