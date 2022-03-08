import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/MultipleChoiceQuestion.dart';
import 'package:student_union_app/models/NearestWinsQuestion.dart';
import 'package:student_union_app/models/Question.dart';
import 'package:student_union_app/models/Quiz.dart';
import 'package:student_union_app/services/database.dart';
import 'activeQuizLeaderboard.dart';
import 'endLeaderboard.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';


class ActiveQuiz extends StatefulWidget {
  const ActiveQuiz({Key? key}) : super(key: key);

  @override
  _ActiveQuizState createState() => _ActiveQuizState();
}

// Widget to display the currently active question in the quiz
// (along with answer buttons) or the end leaderboard of the
// currently active quiz
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

  String nearestWinsAnswer = '';


  // Nearest Wins form state
  final _formKey = GlobalKey<FormState>();
  String error = '';


  // Retrieves the user's submitted nearest wins answer from the database
  // (If it exists)
  Future _retrieveSubmittedNearestWinsAnswer() async {
    nearestWinsAnswer = await _database.retrieveSubmittedNearestWinsAnswer() as String;
  }


  // Check whether a given string is a Numeric
  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }

    return double.tryParse(str) != null;
  }


  final DatabaseService _database = DatabaseService();

  // Submits the user's answer for a multiple choice question
  _submitMultipleChoiceAnswer(String answer) async {
    await _database.submitMultipleChoiceAnswer(answer);
  }

  // Submits the user's answer for a nearest wins question
  _submitNearestWinsAnswer(var answer) async {
    await _database.submitNearestWinsAnswer(answer);
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
    return StreamBuilder<QuerySnapshot>(
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

                // Return the Scaffold that contains the Leaderboard floating
                // action button
                // And contains the ActiveQuizLeaderboard Drawer
                // Since the Active Leaderboard should only available during the
                // quiz
                return Scaffold(
                  backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
                  appBar: buildAppBar(context, 'Quiz'),
                  body: StreamBuilder<QuerySnapshot>(
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
                      }),


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
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SpinKitRing(
                              color: Colors.white,
                              size: 50.0,
                            );
                          }

                          // Add the retrieved quiz to a Quiz object and update the current
                          // Quiz object to reflect the values in the database
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;

                            Quiz retrievedQuiz = _database.quizFromSnapshot(data);

                            currentQuiz.id = retrievedQuiz.id;
                            currentQuiz.questionCount = retrievedQuiz.questionCount;
                          });


                          return ActiveQuizLeaderboard(quizID: currentQuiz.id!);
                        }),


                    // Drawer can also be opened by swiping to the right
                    // And closed by swiping to the left
                    drawerEdgeDragWidth: 500.0,

                    // Floating action button at the bottom center of the screen to open the
                    // Active Quiz Leaderboard
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

                    // Floating action button does not appear on the End of Quiz Leaderboard
                    floatingActionButton: Builder(builder: (context) {
                      return FloatingActionButton.extended(
                        // When tapped, open the Drawer containing the Active Quiz Leaderboard
                        onPressed: () =>
                            Scaffold.of(context).openDrawer(),
                        backgroundColor:
                        const Color.fromRGBO(22, 66, 139, 1),
                        label: const Text('Leaderboard'),
                        icon: const Icon(Icons.table_rows),
                      );
                    })
                );
              }
              // If the quiz has ended, display the end of quiz leaderboard
              else {
                // And use the Scaffold that does not contain the Active Quiz
                // Leaderboard Drawer or the Floating Action Button
                return Scaffold(
                    backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
                    appBar: buildAppBar(context, 'Quiz'),
                    body: EndLeaderboard(quizID: currentQuiz.id!)
                );
              }
            });
  }


  // Build the question and answer Widgets depending on the type of question
  Widget _buildAnswers(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {

      return RawScrollbar(
        isAlwaysShown: true,
        thumbColor: const Color.fromRGBO(22, 66, 139, 1),
        thickness: 7.5,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                  children:
                  snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                    // Retrieve the question to determine the question type
                    Question retrievedQuestion = _database.questionFromSnapshot(data);

                    // If the question is a multiple choice question
                    if (retrievedQuestion.questionType == "MCQ") {

                      // Cast the Question as a Multiple Choice Question object
                      MultipleChoiceQuestion currentQuestion = _database
                          .multipleChoiceQuestionFromSnapshot(data);

                      // Display the current MCQ along with its answers
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
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    15.0, 7.5, 15.0, 5.0),
                                child: Card(
                                  color: Colors.red[900],
                                  elevation: 20,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    side: BorderSide(
                                        color: (selectedAnswer == Answer.A)
                                            ? Colors
                                            .yellowAccent
                                            : Colors.white70,
                                        width: 1),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _submitMultipleChoiceAnswer("a");
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
                                padding: const EdgeInsets.fromLTRB(
                                    15.0, 0.0, 15.0, 5.0),
                                child: Card(
                                  color: Colors.blue[900],
                                  elevation: 20,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    side: BorderSide(
                                        color: (selectedAnswer == Answer.B)
                                            ? Colors
                                            .yellowAccent
                                            : Colors.white70,
                                        width: 1),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _submitMultipleChoiceAnswer("b");
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
                                padding: const EdgeInsets.fromLTRB(
                                    15.0, 0.0, 15.0, 5.0),
                                child: Card(
                                  color: Colors.green[900],
                                  elevation: 20,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    side: BorderSide(
                                        color: (selectedAnswer == Answer.C)
                                            ? Colors
                                            .yellowAccent
                                            : Colors.white70,
                                        width: 1),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _submitMultipleChoiceAnswer("c");
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
                                padding: const EdgeInsets.fromLTRB(
                                    15.0, 0.0, 15.0, 5.0),
                                child: Card(
                                  color: Colors.yellow[900],
                                  elevation: 20,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    side: BorderSide(
                                        color: (selectedAnswer == Answer.D)
                                            ? Colors
                                            .yellowAccent
                                            : Colors.white70,
                                        width: 1),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _submitMultipleChoiceAnswer("d");
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
                    }


                    // If the question is a nearest wins question
                    else if (retrievedQuestion.questionType == "NWQ") {

                      // Cast the Question as a Nearest Wins Question
                      NearestWinsQuestion currentQuestion = _database
                          .nearestWinsQuestionFromSnapshot(data);

                      // FutureBuilder to retrieve the users possibly submitted
                      // answer
                      return FutureBuilder(
                          future: _retrieveSubmittedNearestWinsAnswer(),
                          builder: (context, snapshot) {

                            // If the user's potential answer has been retrieved
                          if (snapshot.connectionState == ConnectionState.done) {

                            // Build the question and answer form
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
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 20.0),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 0.0, horizontal: 60.0),
                                            child: TextFormField(

                                              // Initial value is set to the user's
                                              // submitted answer if it exists
                                              initialValue: (nearestWinsAnswer !=
                                                  "No Answer Submitted")
                                                  ? nearestWinsAnswer
                                                  : '',
                                              decoration: const InputDecoration(
                                                hintText:
                                                'Guess the nearest answer!',
                                              ),
                                              validator: (String? value) {

                                                // Answer cannot be empty,
                                                // must be below 17 characters,
                                                // and must be a number
                                                if (value != null &&
                                                    value.isEmpty) {
                                                  return "Answer cannot be empty!";
                                                } else if (value!.length > 17) {
                                                  return "Answer must be below 17 characters!";
                                                } else if (!_isNumeric(value)) {
                                                  return "Answer must be a number!";
                                                }
                                                return null;
                                              },
                                              onChanged: (val) {
                                                nearestWinsAnswer = val;
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 12.0),
                                          // Error text
                                          Text(
                                            error,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(200, 50),
                                              maximumSize: const Size(200, 50),

                                              // Button is highlighted if answer
                                              // has been submitted for this
                                              // question
                                              primary: (nearestWinsAnswer ==
                                                  'No Answer Submitted')
                                                  ? const Color.fromRGBO(
                                                  22, 66, 139, 1)
                                                  : Colors.yellow,
                                            ),
                                            child: Text(
                                              'Submit',
                                              style: TextStyle(

                                                // Text colour is changed if answer
                                                // has been submitted for this
                                                // question
                                                color: (nearestWinsAnswer ==
                                                    'No Answer Submitted')
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {

                                                // If a valid answer is submitted,
                                                // submit it to the database and
                                                // rebuild the Widget Tree
                                                setState(() {
                                                  _submitNearestWinsAnswer(
                                                      nearestWinsAnswer);
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Return a loading widget whilst the asynchronous function takes
                          // time to complete
                          else {
                            return const SpinKitRing(
                              color: Colors.white,
                              size: 50.0,
                            );
                          }
                      });
                    }


                    // If the question type cannot be determined, output the
                    // following error message
                    else {
                      return const Text('Question Type Not Set');
                    }

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
