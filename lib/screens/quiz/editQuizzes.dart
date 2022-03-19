import 'editQuiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/Quiz.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/database.dart';

class EditQuizzes extends StatefulWidget {
  const EditQuizzes({Key? key}) : super(key: key);

  @override
  _EditQuizzesState createState() => _EditQuizzesState();
}

// Widget to display the list of the quizzes stored in the Quizzes collection
// ordered by most recent creationDate
// Along with buttons to edit and delete them
// (the delete button also has a confirmation pop-up)
// And also a button that leads to a screen to create a new quiz
class _EditQuizzesState extends State<EditQuizzes> {
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
                    child: buildTabTitle('Edit Quizzes', 40),
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
                        String questionCount = quiz.questionCount!.toString();
                        if (quiz.questionCount == 1) {
                          questionCount += " Question";
                        } else {
                          questionCount += " Questions";
                        }


                        // Display the quiz if the quiz document is not the one
                        // used to represent that there are no
                        // quizzes currently active
                        if (quiz.id != "cy7RWIJ3VGIXlHSM1Il8") {
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
                                  const SizedBox(height: 25.0),
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
                                      child: const Text('Edit Quiz'),
                                      // If the edit quiz button on a quiz is
                                      // tapped navigate the user to the
                                      // EditQuiz Widget with the quiz details
                                      // passed as parameters
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditQuiz(quizID: quiz.id!,
                                                  quizTitle: quiz.quizTitle!,
                                                    dateCreated: date,
                                                    questionCount: quiz.questionCount!.toString()),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
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
                                      child: const Text('Delete Quiz'),
                                      // If the delete quiz button is tapped
                                      // display the deleteAlert pop-up
                                      onPressed: () async {
                                        showDeleteAlertDialog(context, quiz.id!);
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
                      child: const Text('Create New Quiz'),
                      // When tapped navigate the user to the createQuiz screen
                      onPressed: () async {
                        Navigator.pushNamed(context, '/quiz/admin/createQuiz');
                      },
                    ),
                  ),
                ]);
          }),
    );
  }
}

// The delete quiz confirmation pop-up Widget
showDeleteAlertDialog(context, id) {
  final DatabaseService _database = DatabaseService();

  // If the user taps "Yes", delete all question documents related to
  // the quiz and the quiz document itself
  // Then close the pop-up
  Widget yesButton = TextButton(
    child: const Text("Yes"),
    onPressed: () async {
      await _database.deleteQuiz(id);
      Navigator.of(context).pop();
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
    content: const Text(
        "Deleting this quiz will also delete all of the questions contained"
            " within it! Are you sure you want to continue?"),
    actions: [
      yesButton,
      cancelButton,
    ],
  );

  // The function to build the delete alert dialog box
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
