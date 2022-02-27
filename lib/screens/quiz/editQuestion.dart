import 'package:flutter/material.dart';
import 'package:student_union_app/models/Question.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class EditQuestion extends StatefulWidget {
  final Question question;

  const EditQuestion({Key? key, required this.question}) : super(key: key);

  @override
  _EditQuestionState createState() => _EditQuestionState();
}

// Widget to display a form to edit an existing question
class _EditQuestionState extends State<EditQuestion> {
  final DatabaseService _database = DatabaseService();

  String questionID = '';

  // Text field state
  String questionText = '';
  String answerA = '';
  String answerB = '';
  String answerC = '';
  String answerD = '';
  String error = '';

  // Radio button group state
  String correctAnswer = '';

  final _formKey = GlobalKey<FormState>();

  // Set initial values of text field and radio button states to the parameters
  // passed to this Widget
  @override
  void initState() {
    Question question = widget.question;

    questionID = question.id!;

    questionText = question.questionText!;
    answerA = question.answerA!;
    answerB = question.answerB!;
    answerC = question.answerC!;
    answerD = question.answerD!;
    correctAnswer = question.correctAnswer!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              child: buildTabTitle('Edit Question', 40),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: questionText,
                      decoration: const InputDecoration(
                        hintText: 'Question Text',
                      ),
                      // Question text cannot be empty and must be
                      // below 70 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Question Text cannot be empty!";
                        } else if (value!.length > 70) {
                          return "Question Text must be below 70 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          questionText = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: answerA,
                      decoration: const InputDecoration(
                        hintText: 'Answer A',
                      ),
                      // Answer A cannot be empty and must be
                      // below 50 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Answer A cannot be empty!";
                        } else if (value!.length > 50) {
                          return "Answer A must be below 50 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          answerA = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: answerB,
                      decoration: const InputDecoration(
                        hintText: 'Answer B',
                      ),
                      // Answer B cannot be empty and must be
                      // below 50 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Answer B cannot be empty!";
                        } else if (value!.length > 50) {
                          return "Answer B must be below 50 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          answerB = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: answerC,
                      decoration: const InputDecoration(
                        hintText: 'Answer C',
                      ),
                      // Answer C cannot be empty and must be
                      // below 50 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Answer C cannot be empty!";
                        } else if (value!.length > 50) {
                          return "Answer C must be below 50 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          answerC = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: answerD,
                      decoration: const InputDecoration(
                        hintText: 'Answer D',
                      ),
                      // Answer D cannot be empty and must be
                      // below 50 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Answer D cannot be empty!";
                        } else if (value!.length > 50) {
                          return "Answer D must be below 50 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          answerD = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Correct Answer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Radio buttons for the correct answer
                    ButtonBar(children: [
                      Row(
                        children: [
                          const Text('A:'),
                          Radio(
                            value: 'a',
                            groupValue: correctAnswer,
                            activeColor: const Color.fromRGBO(22, 66, 139, 1),
                            onChanged: (T) {
                              setState(() {
                                correctAnswer = 'a';
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('B:'),
                          Radio(
                            value: 'b',
                            groupValue: correctAnswer,
                            activeColor: const Color.fromRGBO(22, 66, 139, 1),
                            onChanged: (T) {
                              setState(() {
                                correctAnswer = 'b';
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('C:'),
                          Radio(
                            value: 'c',
                            groupValue: correctAnswer,
                            activeColor: const Color.fromRGBO(22, 66, 139, 1),
                            onChanged: (T) {
                              setState(() {
                                correctAnswer = 'c';
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('D:'),
                          Radio(
                            value: 'd',
                            groupValue: correctAnswer,
                            activeColor: const Color.fromRGBO(22, 66, 139, 1),
                            onChanged: (T) {
                              setState(() {
                                correctAnswer = 'd';
                              });
                            },
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 6.0),
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
                        primary: const Color.fromRGBO(22, 66, 139, 1),
                      ),
                      child: const Text('Submit Changes'),
                      // When the Submit Changes button is tapped, check
                      // whether the question details are valid and update the
                      // question document to the new validated details
                      // And return the user back to the EditQuiz screen
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {

                          // Question number is not updated or retrieved here so
                          // setting it to 0 is fine
                          // The same goes for the quizID being set to 'Not Set'
                          Question question = Question(
                            id: questionID,
                            answerA: answerA,
                            answerB: answerB,
                            answerC: answerC,
                            answerD: answerD,
                            correctAnswer: correctAnswer,
                            questionNumber: 0,
                            questionText: questionText,
                            quizID: 'Not Set',
                          );

                          await _database.updateQuestion(question);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
                primary: const Color.fromRGBO(22, 66, 139, 1),
              ),
              child: const Text('Return'),
              // Return the user back to the EditQuiz screen
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 25.0),
          ],
        ),
      ),
    );
  }
}
