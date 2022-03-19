import 'createQuestion.dart';
import 'editQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/MultipleChoiceQuestion.dart';
import 'package:student_union_app/models/NearestWinsQuestion.dart';
import 'package:student_union_app/models/Question.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/database.dart';

class EditQuestions extends StatefulWidget {
  final String quizID;
  final String quizTitle;
  final String questionCount;

  const EditQuestions({Key? key, required this.quizID, required this.quizTitle,
    required this.questionCount})
      : super(key: key);

  @override
  _EditQuestionsState createState() => _EditQuestionsState();
}

// Widget to display each question's information from the selected quiz
// Along with an 'Edit Question' and 'Delete Question' button per displayed
// question
// Also a 'Create Question' button is displayed at the bottom of the screen
class _EditQuestionsState extends State<EditQuestions> {
  final DatabaseService _database = DatabaseService();

  String quizID = '';
  String quizTitle = '';
  String questionCount = '';

  @override
  void initState() {
    quizID = widget.quizID;
    quizTitle = widget.quizTitle;
    questionCount = widget.questionCount;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // The title of the screen is the title of the quiz being edited
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
            child: buildTabTitle(quizTitle, 40),
          ),

          // Stream of questions contained within the quiz in order of
          // ascending question numbers
          StreamBuilder<QuerySnapshot>(
              stream: _database.getOrderedQuestions(quizID),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                      'Something went wrong retrieving the questions');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SpinKitRing(
                    color: Colors.white,
                    size: 150.0,
                  );
                }

                return Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 10.0),
                    child: ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      // Retrieve the question to determine the question type
                      Question retrievedQuestion = _database.questionFromSnapshot(data);

                      // If the question is a multiple choice question
                      if (retrievedQuestion.questionType == "MCQ") {

                        // Cast the Question as a Multiple Choice Question
                        MultipleChoiceQuestion question =
                        _database.multipleChoiceQuestionFromSnapshot(data);

                        // Display each question's number, text, and answers
                        // Also, highlight the correct answer in green
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
                                      vertical: 5.0, horizontal: 5.0),
                                  child: Text(
                                    'Q' +
                                        question.questionNumber!.toString() +
                                        ': ' +
                                        question.questionText!,
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
                                      vertical: 5.0, horizontal: 5.0),
                                  child: Text(
                                    'A: ' + question.answerA!.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: (question.correctAnswer! == 'a')
                                          ? Colors.green
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 5.0),
                                  child: Text(
                                    'B: ' + question.answerB!.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: (question.correctAnswer! == 'b')
                                          ? Colors.green
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 5.0),
                                  child: Text(
                                    'C: ' + question.answerC!.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: (question.correctAnswer! == 'c')
                                          ? Colors.green
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 0.0),
                                  child: Text(
                                    'D: ' + question.answerD!.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: (question.correctAnswer! == 'd')
                                          ? Colors.green
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),

                                // Display an Edit Question and a Delete Question
                                // button per displayed question
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 0.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(200, 50),
                                      maximumSize: const Size(200, 50),
                                      primary:
                                      const Color.fromRGBO(22, 66, 139, 1),
                                    ),
                                    child: const Text('Edit Question'),
                                    // When tapped, navigate to the EditQuestion
                                    // Widget with the question's details being
                                    // passed as a parameter
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditQuestion(
                                                  question: question
                                              ),
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
                                      primary:
                                      const Color.fromRGBO(22, 66, 139, 1),
                                    ),
                                    child: const Text('Delete Question'),
                                    // When tapped delete the question from the
                                    // quiz
                                    onPressed: () async {
                                      _database.deleteQuestion(data['id']);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                              ],
                            ),
                          ),
                        );
                      }


                      // If the question is a nearest wins question
                      else if (retrievedQuestion.questionType == "NWQ") {

                        // Cast the Question as a Nearest Wins Question
                        NearestWinsQuestion question = _database
                            .nearestWinsQuestionFromSnapshot(data);

                        // Display each question's number, text, and correct answer
                        // Also, highlight the correct answer in green
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
                                      vertical: 5.0, horizontal: 5.0),
                                  child: Text(
                                    'Q' +
                                        question.questionNumber!.toString() +
                                        ': ' +
                                        question.questionText!,
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
                                      vertical: 5.0, horizontal: 5.0),
                                  child: Text(
                                    'Correct Answer: ' + question.correctAnswer!.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),

                                // Display an Edit Question and a Delete Question
                                // button per displayed question
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 0.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(200, 50),
                                      maximumSize: const Size(200, 50),
                                      primary:
                                      const Color.fromRGBO(22, 66, 139, 1),
                                    ),
                                    child: const Text('Edit Question'),
                                    // When tapped, navigate to the EditQuestion
                                    // Widget with the question's details being
                                    // passed as a parameter
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditQuestion(
                                                  question: question
                                              ),
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
                                      primary:
                                      const Color.fromRGBO(22, 66, 139, 1),
                                    ),
                                    child: const Text('Delete Question'),
                                    // When tapped delete the question from the
                                    // quiz
                                    onPressed: () async {
                                      _database.deleteQuestion(data['id']);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                              ],
                            ),
                          ),
                        );
                      }


                      // If the question type cannot be determined return the
                      // following error
                      else {
                        return const Text('Question type cannot be determined');
                      }
                    }).toList()),
                  ),
                );
              }),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    maximumSize: const Size(150, 50),
                    primary: const Color.fromRGBO(22, 66, 139, 1),
                  ),
                  child: const Text('Create Question'),
                  // When tapped navigate the user to the createQuestion Widget
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateQuestion(quizID: widget.quizID,
                              questionCount: widget.questionCount,),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    maximumSize: const Size(150, 50),
                    primary: const Color.fromRGBO(22, 66, 139, 1),
                  ),
                  child: const Text('Return'),
                  // When tapped return the user back to the EditQuizzes screen
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25.0),
        ],
      ),
    );
  }
}
