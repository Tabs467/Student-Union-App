import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/Question.dart';
import 'package:student_union_app/models/Quiz.dart';
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

  // Initialise quiz properties to default values
  Quiz currentQuiz = Quiz(
    id: '',
    quizTitle: '',
    quizEnded: false,
    questionCount: 10,
    isActive: true,
    currentQuestion: 1,
    creationDate: Timestamp(0, 0),
  );

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

  // The stream that will listen to the Quiz document that is marked as
  // currently active
  late Stream<QuerySnapshot> _quizzes;

  // On the first build of the widget tree retrieve the current question's
  // number, question count and whether the quiz has ended
  @override
  initState() {
    super.initState();

    // Set the stream to listen to the Quiz document that is marked as
    // currently active
    _quizzes = _database.getActiveQuiz();

    retrieveCurrentQuestionNumber();
  }


  // Rebuild the widget tree and update the current question number,
  // question count and quiz ended variables to their current values in the
  // database
  // And reset the user's selected answer if the question number
  // increases
  retrieveCurrentQuestionNumber() {
    setState(() {
      _quizzes.forEach((field) {
        field.docs.asMap().forEach((index, data) {

          Quiz retrievedQuiz = _database.quizFromSnapshot(data);

          currentQuiz.questionCount = retrievedQuiz.questionCount;
          currentQuiz.quizEnded = retrievedQuiz.quizEnded;
          currentQuiz.id = retrievedQuiz.id;

          // Reset selected answer each time a new question is loaded
          if (currentQuiz.currentQuestion! < retrievedQuiz.currentQuestion!) {
            selectedAnswer = Answer.none;
          }

          currentQuiz.currentQuestion = retrievedQuiz.currentQuestion;
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
          stream: _database.getActiveQuiz(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text(
                  'Something went wrong retrieving the quiz');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SpinKitRing(
                color: Colors.white,
                size: 50.0,
              );
            }

            // Add the retrieved quiz to a Quiz object and update the current
            // Quiz object to reflect the values in the database
            // And reset the user's selected answer if the question number
            // increases
            snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;

              Quiz retrievedQuiz = _database.quizFromSnapshot(data);

              currentQuiz.quizEnded = retrievedQuiz.quizEnded;
              currentQuiz.id = retrievedQuiz.id;
              currentQuiz.questionCount = retrievedQuiz.questionCount;

              // Reset selected answer each time a new question is loaded
              if (currentQuiz.currentQuestion! < retrievedQuiz.currentQuestion!) {
                selectedAnswer = Answer.none;
              }

              currentQuiz.currentQuestion = retrievedQuiz.currentQuestion;
            });

            // If all the quizzes questions have not been displayed
            if (currentQuiz.currentQuestion! <= currentQuiz.questionCount!) {
              return StreamBuilder<QuerySnapshot>(
                // Set the stream to listen to the Question document whose
                // contained question is part of the current quiz and
                // whose question number is the current position in the quiz
                  stream: _database.getCurrentQuestion(
                      currentQuiz.id!,
                      currentQuiz.currentQuestion!
                  ),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                          'Something went wrong retrieving the question');
                    }
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SpinKitRing(
                        color: Colors.white,
                        size: 50.0,
                      );
                    }

                    // Build the question and answer Widgets depending on
                    // which answer the user has currently selected
                    // So that the currently selected answer is highlighted
                    return _buildAnswers(snapshot);
                  });
            }
            // If the quiz has ended display the end of quiz leaderboard
            else {
              return EndLeaderboard(quizID: currentQuiz.id!);
            }
          }),
    );
  }


  // Build the question and answer Widgets with answer A as the selected answer
  RawScrollbar _buildAnswers(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return RawScrollbar(
      isAlwaysShown: true,
      thumbColor: const Color.fromRGBO(22, 66, 139, 1),
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

                  Question currentQuestion = _database.questionFromSnapshot(data);

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
                                child: Text(
                                  'Q' +
                                      currentQuestion.questionNumber.toString() +
                                      ': ' +
                                      currentQuestion.questionText!,
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
                            padding: const EdgeInsets.fromLTRB(15.0, 7.5, 15.0, 5.0),
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
                                    'A: ' + currentQuestion.answerA!,
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
                            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
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
                                    'B: ' + currentQuestion.answerB!,
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
                            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
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
                                    'C: ' + currentQuestion.answerC!,
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
                            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
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
                                    'D: ' + currentQuestion.answerD!,
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
