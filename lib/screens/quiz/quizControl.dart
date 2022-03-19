import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/MultipleChoiceQuestion.dart';
import 'package:student_union_app/models/NearestWinsQuestion.dart';
import 'package:student_union_app/models/Question.dart';
import 'package:student_union_app/models/Quiz.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/services/database.dart';
import 'activeQuizLeaderboard.dart';
import 'adminEndLeaderboard.dart';

class QuizControl extends StatefulWidget {
  const QuizControl({Key? key}) : super(key: key);

  @override
  _QuizControlState createState() => _QuizControlState();
}

// Widget to allow admins to control the flow of and host the Pub Quiz
class _QuizControlState extends State<QuizControl> {
  final DatabaseService _database = DatabaseService();

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

  // Rebuild the widget tree and update the current quizID, question number,
  // question count and quiz ended variables to their current values in the
  // database
  retrieveCurrentQuestionNumber() {
    setState(() {
      _quizzes.forEach((field) {
        field.docs.asMap().forEach((index, data) {
          Quiz retrievedQuiz = _database.quizFromSnapshot(data);

          currentQuiz.questionCount = retrievedQuiz.questionCount;
          currentQuiz.quizEnded = retrievedQuiz.quizEnded;
          currentQuiz.id = retrievedQuiz.id;
          currentQuiz.currentQuestion = retrievedQuiz.currentQuestion;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: StreamBuilder<QuerySnapshot>(
          // Set the stream to listen to the Quiz document that is marked as
          // currently active
          stream: _database.getActiveQuiz(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong loading the quiz');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SpinKitRing(
                color: Colors.white,
                size: 50.0,
              );
            }

            // Add the retrieved quiz to a map and update the current
            // question number and other values to reflect the
            // values stored in the database
            snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              Quiz retrievedQuiz = _database.quizFromSnapshot(data);

              currentQuiz.id = retrievedQuiz.id;
              currentQuiz.currentQuestion = retrievedQuiz.currentQuestion;
              currentQuiz.quizEnded = retrievedQuiz.quizEnded;
            });

            return StreamBuilder<QuerySnapshot>(
                // Set the stream to listen to the Question document whose
                // contained question is part of the current quiz and
                // whose question number is the current position in the quiz
                stream: _database.getCurrentQuestion(
                    currentQuiz.id!, currentQuiz.currentQuestion!),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                        'Something went wrong loading the question');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SpinKitRing(
                      color: Colors.white,
                      size: 50.0,
                    );
                  }

                  // If all the quizzes questions have not been displayed
                  if (currentQuiz.currentQuestion! <=
                      currentQuiz.questionCount!) {
                    // Display the current question along with its answers
                    // and correct answer
                    // And a button to display the leaderboard
                    // Also display the End Quiz and Next Question buttons
                    return buildAnswersAndButtons(snapshot, context);
                  }
                  // Otherwise if the quiz has ended
                  else {
                    // Display the End of Quiz Leaderboard along with an
                    // extra button that ends the quiz
                    return Scaffold(
                        backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
                        appBar: buildAppBar(context, 'Quiz'),
                        body: AdminEndLeaderboard(quizID: currentQuiz.id!
                    ));
                  }
                });
          }),
    );
  }

  // Display the current question along with its answers
  // and correct answer
  // And a button to display the leaderboard
  // Also display the End Quiz and Next Question buttons
  Scaffold buildAnswersAndButtons(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot, BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),

      body: Builder(
        builder: (context) {
          return Column(
            children: [
              Expanded(
                child: RawScrollbar(
                  isAlwaysShown: true,
                  thumbColor: const Color.fromRGBO(22, 66, 139, 1),
                  thickness: 7.5,
                  child: ListView(
                      children: snapshot.data!.docs.map((
                          DocumentSnapshot document) {
                        Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;

                        // Retrieve the question to determine the question type
                        Question retrievedQuestion = _database.questionFromSnapshot(data);

                        // If the question is a multiple choice question
                         if (retrievedQuestion.questionType == "MCQ") {

                           // Cast the Question as a Multiple Choice Question
                           MultipleChoiceQuestion currentQuestion = _database
                               .multipleChoiceQuestionFromSnapshot(data);

                           // Display the current MCQ along with its answers
                           // And the Leaderboard button
                           return Container(
                             color: const Color.fromRGBO(244, 175, 20, 1.0),
                             child: IntrinsicWidth(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.stretch,
                                 children: [
                                   Padding(
                                     padding: const EdgeInsets.all(8),
                                     child: Card(
                                       color: const Color.fromRGBO(
                                           22, 66, 139, 1),
                                       elevation: 20,
                                       shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(
                                             30),
                                         side: const BorderSide(
                                             color: Colors.white70, width: 1),
                                       ),
                                       child: Padding(
                                         padding: const EdgeInsets.all(16.0),
                                         child: Center(
                                           child: Text(
                                             'Q' +
                                                 currentQuestion.questionNumber
                                                     .toString() +
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
                                   ),
                                   Padding(
                                     padding:
                                     const EdgeInsets.fromLTRB(
                                         15.0, 7.5, 15.0, 5.0),
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
                                   Padding(
                                     padding:
                                     const EdgeInsets.fromLTRB(
                                         15.0, 0.0, 15.0, 5.0),
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
                                   Padding(
                                     padding:
                                     const EdgeInsets.fromLTRB(
                                         15.0, 0.0, 15.0, 5.0),
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
                                   Padding(
                                     padding:
                                     const EdgeInsets.fromLTRB(
                                         15.0, 0.0, 15.0, 5.0),
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
                                   Padding(
                                     padding: const EdgeInsets.all(16),
                                     child: Card(
                                       color: const Color.fromRGBO(
                                           244, 140, 20, 1),
                                       elevation: 20,
                                       shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(
                                             30),
                                         side: const BorderSide(
                                             color: Colors.yellow, width: 3),
                                       ),
                                       child: Padding(
                                         padding: const EdgeInsets.all(10.0),
                                         child: Center(
                                           child: Text(
                                             'Correct Answer: ' +
                                                 currentQuestion.correctAnswer!
                                                     .toUpperCase(),
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
                                     padding: const EdgeInsets.fromLTRB(
                                         16.0, 0.0, 16.0, 16.0),
                                     child: Card(
                                       color: const Color.fromRGBO(
                                           22, 66, 139, 1),
                                       elevation: 20,
                                       shape: const RoundedRectangleBorder(
                                         side: BorderSide(
                                             color: Colors.white, width: 2.0),
                                       ),
                                       child: InkWell(
                                         // When tapped, toggle the Drawer
                                         // containing the leaderboard
                                         onTap: () {
                                           Scaffold.of(context).openDrawer();
                                         },
                                         child: const Padding(
                                           padding: EdgeInsets.all(10.0),
                                           child: Center(
                                             child: Text(
                                               'Leaderboard',
                                               style: TextStyle(
                                                 fontWeight: FontWeight.bold,
                                                 fontSize: 30,
                                                 color: Colors.white,
                                               ),
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
                         }


                         // If the question is a nearest wins question
                         else if (retrievedQuestion.questionType == "NWQ") {

                           // Cast the Question as a Nearest Wins Question
                           NearestWinsQuestion currentQuestion = _database
                               .nearestWinsQuestionFromSnapshot(data);

                           // Display the current NWQ along with its answer
                           // And the Leaderboard button
                           return Container(
                             color: const Color.fromRGBO(244, 175, 20, 1.0),
                             child: IntrinsicWidth(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.stretch,
                                 children: [
                                   Padding(
                                     padding: const EdgeInsets.all(8),
                                     child: Card(
                                       color: const Color.fromRGBO(
                                           22, 66, 139, 1),
                                       elevation: 20,
                                       shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(
                                             30),
                                         side: const BorderSide(
                                             color: Colors.white70, width: 1),
                                       ),
                                       child: Padding(
                                         padding: const EdgeInsets.all(16.0),
                                         child: Center(
                                           child: Text(
                                             'Q' +
                                                 currentQuestion.questionNumber
                                                     .toString() +
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
                                   ),
                                   Padding(
                                     padding: const EdgeInsets.all(16),
                                     child: Card(
                                       color: const Color.fromRGBO(
                                           244, 140, 20, 1),
                                       elevation: 20,
                                       shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(
                                             30),
                                         side: const BorderSide(
                                             color: Colors.yellow, width: 3),
                                       ),
                                       child: Padding(
                                         padding: const EdgeInsets.all(10.0),
                                         child: Center(
                                           child: Text(
                                             'Correct Answer: ' +
                                                 currentQuestion.correctAnswer!
                                                     .toString(),
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
                                     padding: const EdgeInsets.fromLTRB(
                                         16.0, 0.0, 16.0, 16.0),
                                     child: Card(
                                       color: const Color.fromRGBO(
                                           22, 66, 139, 1),
                                       elevation: 20,
                                       shape: const RoundedRectangleBorder(
                                         side: BorderSide(
                                             color: Colors.white, width: 2.0),
                                       ),
                                       child: InkWell(
                                         // When tapped, toggle the Drawer
                                         // containing the leaderboard
                                         onTap: () {
                                           Scaffold.of(context).openDrawer();
                                         },
                                         child: const Padding(
                                           padding: EdgeInsets.all(10.0),
                                           child: Center(
                                             child: Text(
                                               'Leaderboard',
                                               style: TextStyle(
                                                 fontWeight: FontWeight.bold,
                                                 fontSize: 30,
                                                 color: Colors.white,
                                               ),
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
                         }


                         // If the question type cannot be determined, output the
                         // following error message
                         else {
                           return const Text('Question Type Not Set');
                         }
                      }).toList()),
                ),
              ),
              Container(
                color: const Color.fromRGBO(244, 140, 20, 1),
                height: 75,
                child: Card(
                    margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: InkWell(
                      // When tapped open the End Quiz confirmation dialogue
                      // box
                      onTap: () {
                        showEndQuizDialog(context, currentQuiz.id!);
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
                              currentQuiz.id!,
                              currentQuiz.currentQuestion!,
                              currentQuiz.questionCount!);
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
      ),



      // Drawer contains the leaderboard of the active quiz
      // StreamBuilder used here since the quiz ID needs to be passed to the
      // ActiveQuizLeaderboard Widget
      drawer: StreamBuilder<QuerySnapshot>(
        // Set the stream to listen to the Quiz document that is marked as
        // currently active
          stream: _database.getActiveQuiz(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text(
                  'Something went wrong retrieving the quiz');
            }
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const SpinKitRing(
                color: Colors.white,
                size: 50.0,
              );
            }

            // Add the retrieved quiz to a Quiz object and update the current
            // Quiz object to reflect the values in the database
            snapshot.data!.docs
                .map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;

              Quiz retrievedQuiz =
              _database.quizFromSnapshot(data);

              currentQuiz.id = retrievedQuiz.id;
              currentQuiz.questionCount =
                  retrievedQuiz.questionCount;
            });

            return ActiveQuizLeaderboard(quizID: currentQuiz.id!);
          }),

      // Drawer can also be opened by swiping to the right
      // And closed by swiping to the left
      drawerEdgeDragWidth: 500.0,
    );
  }
}


// The End Quiz pop-up Widget
showEndQuizDialog(context, quizID) {
  final DatabaseService _database = DatabaseService();

  // If the user taps "Yes", end the quiz
  // Then close the pop-up
  // Then navigate back to the quiz admin main menu
  Widget yesButton = TextButton(
    child: const Text("Yes"),
    onPressed: () async {

      // End the quiz
      // In this case the quiz would be ending early so there is no
      // winning score to put into the endQuiz function
      _database.endQuiz(quizID, 0);

      // Close the pop-up
      Navigator.of(context).pop();

      // Navigate back to the quiz admin main menu
      Navigator.pushReplacementNamed(context, '/quiz/admin');
    },
  );

  // If the user taps "Cancel", just close the pop-up
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // The alert dialog box
  AlertDialog alert = AlertDialog(
    title: const Text("Warning!"),
    content: const Text("Are you sure you want to end the quiz?"),
    actions: [
      yesButton,
      cancelButton,
    ],
  );

  // The function to build the End Quiz dialog box
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}