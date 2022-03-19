import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/Quiz.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/database.dart';

class SelectQuiz extends StatefulWidget {
  const SelectQuiz({Key? key}) : super(key: key);

  @override
  _SelectQuizState createState() => _SelectQuizState();
}

// Widget to display the list of quizzes with at least one question in order of
// most recently created
// With each list element containing a "Select Quiz" button to start the given
// quiz
class _SelectQuizState extends State<SelectQuiz> {
  final DatabaseService _database = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),

      // Set up the stream that retrieves and listens to all the quiz documents
      // inside the Quizzes collection ordered by the most recent creationDate
      body: StreamBuilder<QuerySnapshot>(
          stream: _database.getOrderedQuizzes(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong retrieving the quizzes');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SpinKitRing(
                color: Colors.white,
                size: 50.0,
              );
            }

            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 50.0),
                    child: buildTabTitle('Select Quiz', 40),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 25.0),
                      child: ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;

                            Quiz quiz = _database.quizFromSnapshot(data);

                            // Calculate DateTime from TimeStamp stored in the
                            // quiz document
                            DateTime unformattedDate = DateTime.parse(
                                quiz.creationDate!.toDate().toString());

                            // Format DateTime for output
                            String date =
                                "${unformattedDate.day.toString().padLeft(2, '0')}"
                                "/${unformattedDate.month.toString().padLeft(2, '0')}"
                                "/${unformattedDate.year.toString()}"
                                " at ${unformattedDate.hour.toString()}"
                                ":${unformattedDate.minute.toString().padLeft(2, '0')}";

                            // Concatenate am or pm depending on the
                            // time of day stored
                            if (unformattedDate.hour <= 12) {
                              date += "am";
                            } else {
                              date += "pm";
                            }


                            // Concatenate singular or plural depending on whether
                            // there is one or multiple questions
                            String questionCount = quiz.questionCount.toString();
                            if (quiz.questionCount == 1) {
                              questionCount += " Question";
                            } else {
                              questionCount += " Questions";
                            }


                            // Display the quiz if the quiz document is not the one
                            // used to represent that there are no quizzes
                            // currently active
                            // And if the quiz has more than one question
                            if (quiz.id != "cy7RWIJ3VGIXlHSM1Il8" && quiz.questionCount! > 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3.0, horizontal: 0.0),
                                child: Card(
                                  elevation: 20,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 5.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 0.0),
                                        child: Text(
                                          quiz.quizTitle!,
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 0.0),
                                        child: Text(
                                          "Created: " + date.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 0.0),
                                        child: Text(
                                          questionCount,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 0.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(200, 50),
                                            maximumSize: const Size(200, 50),
                                            primary: const Color.fromRGBO(
                                                22, 66, 139, 1),
                                          ),
                                          child: const Text('Select Quiz'),
                                          // When tapped, start the given quiz
                                          // and navigate to the QuizControl
                                          // Widget
                                          onPressed: () async {
                                            await _database.startQuiz(quiz.id!);
                                            Navigator.pushNamed(context,
                                                '/quiz/quizControl');
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }).toList()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 0.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        maximumSize: const Size(200, 50),
                        primary: const Color.fromRGBO(22, 66, 139, 1),
                      ),
                      child: const Text('Return'),
                      // When tapped, navigate the user to the Quiz Admin
                      // Main Menu
                      onPressed: () async {
                        Navigator.pushReplacementNamed(
                            context, '/quiz/admin');
                      },
                    ),
                  ),
                ]);
          }),
    );
  }
}
